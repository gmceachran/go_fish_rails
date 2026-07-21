# Spec reliability — findings & strategy

Context doc for the "flaky/hanging test suite" work (roadmap top priority). It
records what the suite was actually doing, what we ruled out, the confirmed root
cause of the hang, and the plan for the remaining test-architecture work.

## TL;DR

- The intermittent **hang is a deterministic infinite loop in Crazy Eights game
  start**, not a Capybara/async problem. It fires ~8% of Crazy-Eights game
  starts (whenever the opening discard card is an 8). Fix is one line.
- The "browser/Capybara can't keep up" theory is **wrong** for the current
  hangs: nearly the whole system suite runs on `rack_test` (single-threaded,
  in-process), and the freeze reproduces with both `:js` specs disabled.
- The `sleep`s scattered around were band-aids over this ~8% hang and never
  fixed it.
- Separately worthwhile (deferred): push game-behavior assertions down to
  **model + request specs** and keep the browser only for genuine UI/JS. The
  game *logic* is already well-covered by model specs; the missing layer is
  request/controller specs.

## The symptom

Suite freezes intermittently, "randomly" on different tests. Refined
observation: it **always freezes at the start of a Crazy Eights game, never Go
Fish**. That observation is what pinpointed the cause.

## What we ruled out

- **Browser throughput / Capybara.** Only two examples ever start a real
  browser — `go_fish_play_spec.rb:79` (`:js`) and `offline_spec.rb:3`
  (`js: true`, and `pending`). Everything else in `spec/systems/` is `rack_test`
  (`spec/support/capybara_drivers.rb:14-20`). The hang persists with both
  commented out, and `rack_test` is synchronous/in-process — nothing to "keep up"
  with.
- **Stray interactive breakpoint** (`binding.pry`/`debugger` waiting on stdin) —
  grep of `app lib config spec` found none.
- **`after_commit` broadcasts / GoodJob threads.** `broadcast_refresh_later_to`
  (`game.rb:2-3`, `player.rb:2`) enqueues via GoodJob, but under
  `use_transactional_fixtures = true` (`rails_helper.rb:49`) the outer
  transaction never commits, so `_commit` callbacks don't fire; and GoodJob in
  test defaults to `:external` (no in-process worker/threads). Not a hang source
  as configured.

## Root cause (confirmed)

`CrazyEights::Implementation#flip_non_wild_discard`
(`app/models/crazy_eights/implementation.rb:120-127`):

```ruby
def flip_non_wild_discard
  card = deck.top_card              # top_card == cards.shift (removes front)
  while card&.wild? && !deck.empty?
    deck.cards.unshift(card)        # puts the SAME wild card back on the FRONT
    card = deck.top_card            # ...and shift draws that same card again
  end
  card
end
```

The opening discard must be a non-wild card, so `start`
(`crazy_eights/implementation.rb:74`) → `start_discard_pile` (l.113) flips cards
until it finds one. But `unshift` returns the wild card to the *front* of the
deck and the next `shift` immediately takes it back — the deck size never
changes, so `!deck.empty?` never breaks. When the post-deal top card is an 8
(`Card#wild?` is rank `"8"`), this loops forever.

Why it matches the symptom exactly:
- **Crazy Eights only** — Go Fish has no opening-discard flip.
- **At game start** — reached via `start` → `start_discard_pile`.
- **~8% "random"** — 4 eights / 52 cards; depends on the shuffle.
- **Explains the model-spec `sleep`s** — even `implementation_spec.rb:152`
  ("places a non-eight card on the discard pile") uses a real shuffle and so
  hangs ~8% of the time itself.

### Fix

Move the wild card to the **bottom** so each iteration advances (≤4 wilds, so it
terminates quickly):

```ruby
deck.cards.push(card)   # bottom, instead of unshift (front)
```

TDD: driven by a deterministic, timeout-guarded spec (developer-authored) that
forces an 8 into the opening slot and asserts `start` returns with a non-wild
discard.

## Secondary latent bug (noted, not the current freeze)

`GoFish::Implementation#advance_turn` (`go_fish/implementation.rb:84-92`) recurses
(l.91) whenever the next player `cant_play`, with **no base case for when every
player is stuck**. An all-`cant_play` end-game state recurses until
`SystemStackError`. It raises fast (not an infinite hang), so it isn't the suite
freeze, but it's a real crash on certain deck-exhausted states. Tracked in
`docs/roadmap.md`.

## Strategy going forward (deferred workstream)

Roadmap-aligned: stop driving the browser to assert game *state*; keep Capybara
for genuine UI/JS only.

1. **Add `type: :request` specs for the turn flow** — none exist today. Cover
   `POST /games/:game_id/turns` for both games: assert the resulting
   `game.reload.game_state` (hand moved, turn advanced, winner set) and the
   redirect. Replaces browser-driven turn assertions with fast, deterministic
   ones. See `TurnsController#create` (`turns_controller.rb:2-58`): game-type
   switch, `advance_turn unless go_again`/`play_again`, `declare_winner!`.
2. **Thin the system specs** to real UI smoke checks. The only system-spec
   assertions that are truly about game *state* are the Go Fish hand-length
   change (`go_fish_play_spec.rb:61,65`, redundant with the model spec) and the
   game-creation model assertions; the winner/stats specs already set state via
   `declare_winner!` at the model layer and only render text.
3. **For the few specs that truly need a browser** (Turbo real-time update,
   offline service worker), fix the infra so they *can* pass deterministically:
   - test env `queue_adapter = :inline` (currently inherits `:good_job` from
     `application.rb:42`, unset in `config/environments/test.rb`).
   - `config/cable.yml` test adapter `test` → `async` (the `test` adapter records
     broadcasts, it doesn't deliver them to a live browser subscriber).
   - AR pool > Puma threads (`config/puma.rb` threads = 3; AR pool defaults to 5)
     to avoid shared-connection contention under a real server.
   - replace `Timeout`/`wait_until` (`spec/support/helpers/capybara_helper.rb:21`,
     `action_cable_helper.rb:2`) with Capybara's auto-waiting matchers.
4. **Remove the `sleep`s** once the above make them unnecessary (AGENTS.md
   forbids adding new ones). Model-spec sleeps in `crazy_eights_game_spec.rb` and
   `crazy_eights/implementation_spec.rb` go away with the hang fix.

## Coverage map (reference)

- **Model specs already cover game logic well.** `spec/models/go_fish/
  implementation_spec.rb` covers `play_turn`/`advance_turn`/`winner` in depth;
  Crazy Eights, `Game`, and `Turn` model specs cover the rest. `CrazyEightsTurn`
  validations are the notable gap (no `crazy_eights_turn_spec.rb`).
- **No `type: :request` or `:controller` specs exist anywhere.**
- **State is directly inspectable** via `game.reload.game_state.<...>` (hands,
  deck, turn, `winner`) — no rendered page needed. `game_state` round-trips
  through POROs via `serialize ..., coder:`.

## Gotchas learned

- A red spec for an infinite loop must be **timeout-guarded** (e.g.
  `Timeout.timeout(2) { ... }`) or it hangs the runner instead of failing. That
  guard is an infinite-loop assertion, not an async `sleep` band-aid.
- Run flaky-hunt suites repeatedly with varied seeds (`--order random`); a single
  green run proves nothing when the failure is probabilistic.
