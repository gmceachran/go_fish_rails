# Cards — game completion

Branch focus: make a game actually finish (the roadmap's Top priority). The IDOR
authorization issue surfaced alongside these is deferred to a dedicated security
branch and stays tracked under `## Security` in `docs/roadmap.md`.

Per project rule 1, each card runs through the gated spec flow (plan in
`docs/spec-plans.md` → agree → write spec → review → implement). Card 2's Crazy
Eights half depends on Card 1.

---

## 1. Crazy Eights end-of-game detection

- **Goal:** `CrazyEights::Implementation#winner` returns the player who has
  emptied their hand (and `nil`/falsey when no one has), so a finished Crazy
  Eights game can report a winner instead of running forever.
- **Why:** `#winner` is hardcoded to return `false`, so a Crazy Eights game never
  declares a winner or ends — half of the roadmap's "no game can finish" Top
  priority. The gap is untested: there is no `#winner` example under
  `crazy_eights/`, and the end-of-game system example is commented out — a "read
  the pending tests first" case.
- **Files and code referenced:**
  - `app/models/crazy_eights/implementation.rb:90-92` — `def winner` returns
    `false`; hands live on the in-memory `CrazyEights::Player` (`play_card`
    deletes the played card from `player.hand`).
  - `spec/models/crazy_eights/implementation_spec.rb` — no `#winner` example yet.
  - `spec/systems/crazy_eights_play_spec.rb:46` — commented-out
    `# it "the turn ends"`.

---

## 2. Declare the winner from the turn flow (both games)

- **Goal:** Both `GoFishGame` and `CrazyEightsGame` reach `state: :over` with the
  winning `Player` flagged, through one shared path. A new
  `Game#declare_winner_if_over!` reads the engine's `winner`, maps it to the
  persisted `Player`, and calls `declare_winner!`; both turn paths invoke it after
  advancing, and the controller no longer reaches into `game.game_state.winner`.
- **Why:** Go Fish's `#winner` is already computed correctly, but
  `declare_winner!` is never called on the Go Fish turn path — the controller only
  advances and saves — so a completed Go Fish game never ends. Crazy Eights has
  the declaration call, but buried in a game-specific private method that never
  fires (its `#winner` returns `false` — see Card 1). Unifying the two into a
  `Game` method closes both gaps and removes a `game_state` reach-through,
  advancing the roadmap's "finish delegating through `Game`" refactor. (CE half
  depends on Card 1.)
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
