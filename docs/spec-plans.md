# Spec plans

Working doc for the test-first flow (see project rule 1 in `AGENTS.md`). Before a
spec is written, its logical flow is hashed out here and agreed on; only then is
the spec written, reviewed, and finally the production code implemented.

## Flow

1. Create the spec file (skeleton / pending examples).
2. Draft the plan below — for each example, the *given* (setup), *when* (the
   action under test), and *then* (assertion), following the Given/When/Then rule.
3. Agree the plan with the developer.
4. Write the spec to match the agreed plan.
5. Developer reviews the spec.
6. Only after review: implement the production code (red → green → refactor).

Keep this doc lean: prune a plan once its spec is merged and green.

## Template

### `<spec file path>` — <what it covers>

- **"<it description>"**
  - Given: <setup / factories / state>
  - When: <the action under test>
  - Then: <the assertion(s)>

(Repeat per example.)

## Active plans

### `spec/systems/go_fish_play_spec.rb` — win screen shows game data (Card 3)

Extends the existing "a completed game shows the winner" example (Given/When
unchanged) with more specific Then assertions.

- **"a completed game shows the winner"**
  - Given: unchanged — `override_go_fish_win` (deck empty, `player1.hand =
    [3S, 3H, 3D]`, `player2.hand = [3C]`, `active_player_index = 0`), logged in
    as `user1`, on `game_path`.
  - When: unchanged — `user1` asks for rank `3`; completes a book, empties both
    hands, deck is empty → `winner` is `user1`.
  - Then (extended):
    - `"#{user1.email_address} wins!"` (existing)
    - `"#{user2.email_address}"` — the opponent, labeled "Opponents:"
    - `"Turns played: 1"` — one `TurnResult` was recorded for this turn
    - `"Books made: 1"` — Go-Fish-only stat; user1's book from this turn
    - some duration text (`"less than a minute"`, via `distance_of_time_in_words`)

### `spec/systems/crazy_eights_play_spec.rb` — win screen shows game data (Card 3)

Extends the existing "a completed game shows the winner" example the same way.

- **"a completed game shows the winner"**
  - Given: unchanged — `override_crazy_eights_win` (`discard_pile = [5H]`,
    `player1.hand = [5S]`, `player2.hand = [6D]`, `active_player_index = 0`),
    logged in as `user1`, on `game_path`.
  - When: unchanged — `user1` plays `5 of Spades`; hand empties → `winner` is
    `user1`.
  - Then (extended):
    - `"#{user1.email_address} wins!"` (existing)
    - `"#{user2.email_address}"` — the opponent
    - `"Turns played: 1"`
    - some duration text (`"less than a minute"`)
    - **no** books-made line — Crazy Eights has no analogous stat

#### Implementation notes

- Both examples' turns complete in a single request within the same test, so
  `started_at`/`ended_at` are effectively simultaneous —
  `distance_of_time_in_words(game.started_at, game.ended_at)` deterministically
  renders `"less than a minute"` regardless of actual test wall-clock time.
- "Turns played" is `game.game_state.turn_results.length` — an existing public
  accessor on both `Implementation`s, not a new method.
- "Books made" is Go-Fish-only and rendered via a small per-game dispatch in
  the winners view (mirroring the existing `games/implementations/_<game>`
  convention), not a `case game` in the controller.
- No new public methods are introduced by this card — `started_at`, `ended_at`,
  `players`, `turn_results`, and `books` are all already public. If that changes
  while implementing, stop and write a driving spec for that method first.
