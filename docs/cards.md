# Cards — game completion

Branch focus: make a game actually finish (the roadmap's Top priority). The IDOR
authorization issue surfaced alongside these is deferred to a dedicated security
branch and stays tracked under `## Security` in `docs/roadmap.md`.

Per project rule 1, each card runs through the gated spec flow (plan in
`docs/spec-plans.md` → agree → write spec → review → implement). Card 2's Crazy
Eights half depends on Card 1. Card 3 depends on Card 2 (needs a real win screen
to refactor).

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

## 2. Declare the winner from the turn flow (both games) — DONE

**Shipped.** `Game#declare_winner_if_over!` reads `game_state.winner`, maps it to
the persisted `Player` (`find_by(user_id:)`), and calls the existing
`declare_winner!`; both `TurnsController` turn paths call it after `save!`, and
the game-specific `declare_crazy_eights_winner` is gone. `GamesController#redirect_to_winner`
and `WinnersController#show` were also fixed — both now go through
`game.players.find_by(winner: true)` instead of reaching into `game_state`, and
the win screen renders the real `user.email_address` instead of the in-memory
`"Lord Farquad"` default. **Both games now finish end-to-end**, closing the
roadmap's "no game can finish" Top priority for good. Driven outside-in by two
system specs (`go_fish_play_spec.rb`, `crazy_eights_play_spec.rb`) plus a model
spec for `declare_winner_if_over!` itself. See `docs/roadmap-completed.md`.

- **Goal:** Both `GoFishGame` and `CrazyEightsGame` reach `state: :over` with the
  winning `Player` flagged, through one shared path. A new
  `Game#declare_winner_if_over!` reads the engine's `winner`, maps it to the
  persisted `Player`, and calls `declare_winner!`; both turn paths invoke it after
  advancing, and the controller no longer reaches into `game.game_state.winner`.
- **Why (original):** Go Fish's `#winner` is already computed correctly, but
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
  - `app/controllers/games_controller.rb:7-13,32-34` — `show` already
    `redirect_to_winner` when `over?`, but `redirect_to_winner` passes one arg to
    the two-segment `game_winner_path` route (`UrlGenerationError`).
  - `app/controllers/winners_controller.rb` — `#show` reads
    `game_state.winner.name` and `Game.find(params[:id])` treats the winner
    segment as a game id.
  - `app/views/winners/show.html.slim` — renders `.name`, which for Go Fish
    deserializes to the `"Lord Farquad"` default (in-memory Players are built with
    `user_id` only — `name` is unused everywhere).

### BRAVE breakdown

- **Brainstorm:** "Full win flow, both games" is three layers, only the top of
  which is the card's literal scope. (1) Go Fish computes `winner` correctly but
  the turn path never calls `declare_winner!` → never reaches `over`. (2) Crazy
  Eights reaches `over` (Card 1) but via a controller-private
  `declare_crazy_eights_winner` reaching into `game_state.winner`. (3) The win
  *screen* is orphaned & broken (route arg mismatch, wrong id lookup, `.name`
  trap). Driven outside-in from a system spec.
- **Approach:** New `Game#declare_winner_if_over!` maps engine `winner` →
  persisted `Player` (`find_by(user_id:)`) → existing `declare_winner!`; both turn
  paths call it **every turn** (no-op when `winner` is `nil`); delete
  `declare_crazy_eights_winner`. Then repoint `redirect_to_winner` +
  `WinnersController` at `game.players.find_by(winner: true)` and render
  `winner.user.email_address` — removing both `game_state.winner` reach-throughs
  and the name trap. Phases: (1) system spec driver, (2) `declare_winner_if_over!`,
  (3) win-screen render. Spec plan / Given-When-Then in `docs/spec-plans.md`.
- **Value:** Closes the roadmap's top-priority "no game can finish" gap for real,
  end-to-end, for both games — the payoff Card 1 set up. Optimize for quality
  (client-ready), on the gated-TDD groove Card 1 warmed up.
- **Estimate:** ~5 pts (M). Top risk: the deterministic-win system setup (Go
  Fish's all-hands-empty end condition vs. `handle_empty_hand` on an empty deck) —
  medium likelihood, low severity (spec-only, surfaces early). Incremental
  fallback: Phase 2 alone (games reach `over`) is a shippable green increment if
  Phase 3 slips.

---

## 3. Win screen: modal styling + game data — DONE

**Shipped**, but the final shape diverged from the original plan below in one
significant way: instead of reusing `layout: "modal"` on a separate
`WinnersController#show`, the win modal now renders **inline, overlaid on the
game board itself** (a follow-up ask after the first pass shipped). Concretely:

- `GamesController#show` no longer redirects when `over?` — it sets `@winner`
  and renders the board as usual. `WinnersController`, its view, and the
  `resources :winners` route are deleted entirely (nothing else referenced them
  once the redirect was gone).
- `app/views/layouts/application_no_sidebar.html.slim`'s (already-present, was
  empty) `turbo_frame_tag 'modal'` now yields `:modal_content` — a no-op for
  every other page, populated by `games/show.html.slim` via `content_for` only
  when `@game_model.over?`.
- New `app/views/games/_winner_modal.html.slim` holds the dialog markup:
  winner, opponents, turns played, Go-Fish-only books made, duration, and
  Close + "Back to Games" buttons.
- `dialogue_controller.js` switched from `.show()` to `.showModal()` (and the
  partial no longer hardcodes `open: true`) — this is what actually centers the
  dialog and unlocks the real native `::backdrop`, which Optics already styles.
  `.show()` never did either.
- New `components/optics-overrides/modal.css` adds a box-shadow (Optics's
  `--op-shadow-large` token) and a light `backdrop-filter: blur`.
- **Bonus find:** `application.scss` had zero `@import`s pulling in any of the
  17 files under `components/`/`core/` — they were completely dead in the
  build (815-byte compiled CSS). Fixed by importing them all; see
  `docs/roadmap-completed.md`.
- Verified with a real headless-browser screenshot (not just the `rack_test`
  specs) — centered, shadowed, blurred, zero console errors.
- Both win system specs needed **no assertion changes** for the overlay
  refactor — they only ever asserted on page content, not the redirect/URL, so
  the same text landing on one response instead of two still passes.

- **Goal (original):** `WinnersController#show` renders through the app's
  existing modal layout (`layout: "modal"` — Optics `.modal`/`.modal__header`/
  `.modal__body`/`.modal__footer`, the native `<dialog>` + `dialogue_controller`
  pattern already used by `UsersController#edit`) instead of a bare unstyled
  page, and the body shows more than just the winner's name: game duration,
  opponent(s), turns played, and — Go Fish only — the number of books the
  winner made (the actual reason they won, not just that they did).
- **Why (original):** The win screen is currently one unstyled line
  (`p #{@winner_name} wins!`), the only page in the app not going through
  `@rolemodel/optics` in some form. The modal layout/Stimulus/CSS already exist
  and are unused here — reusing them costs no new CSS or JS. Card 2 made the win
  path actually work end-to-end; Card 3 makes it worth looking at.
- **Files and code referenced:**
  - `app/controllers/winners_controller.rb` — `#show`, currently
    `render layout: "application_no_sidebar"`.
  - `app/views/winners/show.html.slim` — single line today; needs
    `content_for :modal_header` / body / `:modal_footer` slots.
  - `app/views/layouts/modal.html.slim`, `app/javascript/controllers/dialogue_controller.js`
    — the existing dialog pattern to reuse as-is (no changes expected here).
  - `app/models/game.rb` — `started_at`/`ended_at` (duration), `players` (winner
    + opponents via `winner: true/false`).
  - `app/models/go_fish/implementation.rb` / `crazy_eights/implementation.rb` —
    `turn_results` (both, for turn count); `go_fish/player.rb#books` (Go Fish
    only, for the books-made stat).
  - `app/views/games/implementations/_go_fish.html.slim` /
    `_crazy_eights.html.slim` — the existing per-game partial dispatch
    convention to mirror for the Go-Fish-only books stat, rather than
    special-casing games in `WinnersController` itself.

### BRAVE breakdown

- **Brainstorm:** Considered generic-only (duration, opponent(s), turns played)
  vs. adding a game-specific stat. Chose to go game-specific: Go Fish's win
  condition is "most books," so showing the books count explains *why* the
  winner won, which the generic stats alone don't. Crazy Eights has no
  analogous score/points concept, so it gets the generic set only — not
  imposing a fake symmetry between the two games. Considered and set aside:
  play-again/rematch (a real new feature, not a display change) and
  hand-contents-at-end (always empty by definition of winning — not
  informative).
- **Approach:** Reuse `layout: "modal"` as-is (already generic and full-page
  friendly per `UsersController#edit`); restructure `winners/show.html.slim`
  into `:modal_header`/body/`:modal_footer`. Footer needs an explicit "Back to
  Games" button (`root_path`) — the layout's default "Close" button just hides
  the `<dialog>` via JS, which would strand the user on a blank page here since,
  unlike the profile-edit case, there's no underlying page content beneath this
  modal. The Go-Fish-only books stat is rendered via a small per-game dispatch
  in the winners view, matching the existing `games/implementations/_<game>`
  convention rather than adding `case game` logic to the controller. No new
  public methods needed — everything (`started_at`, `ended_at`, `players`,
  `turn_results`, `books`) is already exposed; driven outside-in by updating the
  two win-screen system specs to assert on the new content (spec plan in
  `docs/spec-plans.md`, agreed before writing).
- **Value:** Polish + informativeness on the screen Card 2 just made reachable;
  brings the last unstyled page in the app onto Optics. Low technical risk (the
  modal pattern is proven elsewhere); the main care point is keeping the
  Go-Fish-only stat truly optional/isolated so Crazy Eights doesn't inherit
  irrelevant markup.
- **Estimate:** ~2-3 pts (S/M).
