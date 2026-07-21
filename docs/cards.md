# Cards — game completion

Branch focus: make a game actually finish (the roadmap's Top priority). The IDOR
authorization issue surfaced alongside these is deferred to a dedicated security
branch and stays tracked under `## Security` in `docs/roadmap.md`.

Per project rule 1, each card runs through the gated spec flow (plan in
`docs/spec-plans.md` → agree → write spec → review → implement). Card 2's Crazy
Eights half depends on Card 1.

---

## 1. Crazy Eights end-of-game detection — DONE

**Shipped.** `CrazyEights::Implementation#winner` now returns the empty-handed
player (`nil` otherwise), guarded by `discard_pile.empty?` so a not-yet-dealt game
(all hands empty) doesn't falsely name player 1. Because the pre-existing
`TurnsController#declare_crazy_eights_winner` already mapped `#winner` → persisted
`Player` → `declare_winner!` and was dead only because `#winner` returned `false`,
**this also made Crazy Eights actually declare a winner and end** — the CE half of
the top-priority gap is closed. Unit-tested via `#winner` specs; the end-to-end CE
finish is still not covered by a test (system example remains commented out). See
`docs/roadmap-completed.md`.

- **Goal:** `CrazyEights::Implementation#winner` returns the player who has
  emptied their hand (and `nil` when no one has), so a finished Crazy
  Eights game can report a winner instead of running forever.
- **Why (original):** `#winner` was hardcoded to return `false`, so a Crazy Eights
  game never declared a winner or ended — half of the roadmap's "no game can
  finish" Top priority. The gap was untested: no `#winner` example existed under
  `crazy_eights/`, and the end-of-game system example was commented out — a "read
  the pending tests first" case.
- **Files and code referenced:**
  - `app/models/crazy_eights/implementation.rb:90-94` — `def winner`, now the
    guarded detect; hands live on the in-memory `CrazyEights::Player` (`play_card`
    deletes the played card from `player.hand`).
  - `spec/models/crazy_eights/implementation_spec.rb` — `#winner` examples added.
  - `spec/systems/crazy_eights_play_spec.rb:46` — end-of-game system example still
    commented out (`# it "the turn ends"`); end-to-end CE finish remains untested.

### BRAVE breakdown

- **Brainstorm:** Pure detection — `#winner` answers "has anyone emptied their
  hand, and who?" with no persistence or controller involvement. In Crazy Eights
  a player wins the instant their hand is empty. Spec plan and Given/When/Then
  live in `docs/spec-plans.md`.
- **Approach:** `return nil if discard_pile.empty?` then
  `players.detect { it.hand.empty? }`, mirroring the existing `player(user_id)`
  detect. Returns a `CrazyEights::Player` on a win, `nil` otherwise — matching
  `GoFish::Implementation#winner`, so Card 2 needs no per-game special-casing. The
  `discard_pile.empty?` guard (discard pile is the "started" signal — `start`
  seeds it, and it only grows) keeps `#winner` safe to call anytime, including on
  `show` render, without falsely naming a winner before the deal.
- **Value:** Primarily process — a low-risk litmus test of the card-oriented
  gated-TDD workflow before Card 2's real complexity. Product value is secondary
  and purely as an enabler: it unlocks Card 2. Optimize for learning, not speed.

---

## 2. Declare the winner from the turn flow (both games)

- **Goal:** Both `GoFishGame` and `CrazyEightsGame` reach `state: :over` with the
  winning `Player` flagged, through one shared path. A new
  `Game#declare_winner_if_over!` reads the engine's `winner`, maps it to the
  persisted `Player`, and calls `declare_winner!`; both turn paths invoke it after
  advancing, and the controller no longer reaches into `game.game_state.winner`.
- **Why:** Go Fish's `#winner` is already computed correctly, but
  `declare_winner!` is never called on the Go Fish turn path — the controller only
  advances and saves — so a completed Go Fish game never ends. Crazy Eights now
  *does* declare a winner (Card 1 revived its `declare_crazy_eights_winner` path),
  but through a game-specific private method that reaches into
  `game.game_state.winner`. So Card 2 is now: (a) close the remaining Go Fish gap,
  and (b) unify both games behind one `Game` method, removing the `game_state`
  reach-through — advancing the roadmap's "finish delegating through `Game`"
  refactor. (Card 1 is done.)
- **Files and code referenced:**
  - `app/controllers/turns_controller.rb:27-31` — `apply_go_fish_turn`
    (`play_turn` → `advance_turn` → `save!`, no winner declaration).
  - `app/controllers/turns_controller.rb:45-58` — `apply_crazy_eights_turn` and
    the game-specific `declare_crazy_eights_winner` that reads
    `game.game_state.winner`.
  - `app/models/game.rb:27-30` — existing `declare_winner!(player)` (sets
    `winner: true`, `ended_at`, `state: :over`); `game.rb:9` state enum.
  - `app/models/go_fish/implementation.rb` — `#winner` (already correct).
  - `app/models/crazy_eights/implementation.rb:90` — `#winner` (fixed by Card 1).
