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

### Phase 5 — shared `Turn` form-object base

Target shape (per `docs/dedup-plan.md` Phase 5 and the stashed spike): a new
`Games::Turn` holds `game_id`/`user_id`, the `game`/`game_state` accessors (with
the rule-3 accessor-memo fix — `self.game_record ||= Game.find_by(...)`), and
the two validations both games share (`game_is_active`, `user_is_active_player`).
`Turn` and `CrazyEightsTurn` become thin subclasses holding only their
game-specific validations. A new shared example carries the inherited-behavior
assertions so they're proven once and reused by all three specs (base +
both subclasses), matching the existing `card_spec.rb` / `player_spec.rb`
pattern. **This also closes a real coverage gap**: `CrazyEightsTurn` currently
has no dedicated spec at all — it's only exercised incidentally as a fixture
inside `spec/models/crazy_eights/engine_spec.rb`.

#### `spec/support/shared_examples/turn_requires_active_player.rb` (new)

Shared example `"a turn for an active game and the active player's turn"`.
Including context must define `subject` (a valid turn instance), `game` (the
backing AR `Game`), and `opponent_player` (a joined player who is not the
active player).

- **"is valid with valid attributes"**
  - Given: `subject` built from valid attributes for a started, active game
  - When: validity is checked
  - Then: `subject` is valid
- **"requires a game_id"**
  - Given: `subject` valid
  - When: `subject.game_id = nil`
  - Then: `subject` is invalid
- **"requires a user_id"**
  - Given: `subject` valid
  - When: `subject.user_id = nil`
  - Then: `subject` is invalid
- **"rejects a game_id that does not exist"**
  - Given: `subject` valid
  - When: `subject.game_id = -1` (no `Game` with that id)
  - Then: `subject` is invalid
- **"rejects a game that is not active"**
  - Given: a second `Game` of the same type created but not yet full (`state ==
    "waiting"`)
  - When: `subject.game_id` is set to that waiting game's id
  - Then: `subject` is invalid
- **"rejects a user who is not the active player"**
  - Given: `subject` valid
  - When: `subject.user_id = opponent_player.user_id`
  - Then: `subject` is invalid

#### `spec/models/games/turn_spec.rb` (new)

Direct tests of `Games::Turn` itself (mirrors `games/card_spec.rb` /
`games/player_spec.rb` testing the base class directly), backed by a real
started `GoFishGame` (any concrete game works — the base only touches
`game.active?` / `game_state.active_player?`).

- **it_behaves_like "a turn for an active game and the active player's turn"**
  - Given: `game` = a started 2-player `GoFishGame`; `subject` =
    `Games::Turn.new(game_id: game.id, user_id: active_player.user_id)`;
    `opponent_player` = the non-active joined player
  - (examples as defined in the shared example above)
- **"#game memoizes the lookup"**
  - Given: `subject` valid, with `Game.find_by` spied on
  - When: `subject.game` is called twice
  - Then: `Game.find_by` is invoked exactly once, and both calls return the
    same object

#### `spec/models/turn_spec.rb` (trim to the Go Fish delta)

Keep the existing `create :game` / `player1` / `player2` / `active_player` /
`opponent_player` setup (unchanged — it already matches what the shared example
needs). Replace the "presence", "game state", and "turn order" `describe`
blocks with the shared example; keep only what's specific to asking-an-opponent.

- **it_behaves_like "a turn for an active game and the active player's turn"**
  - Given: `game` = started 2-player `GoFishGame`; `subject` = `Turn.new(rank:
    held_rank, opponent: opponent_player.user_id, game_id: game.id, user_id:
    active_player.user_id)`
- **"rank inclusion" — "rejects a rank not in GoFish::Card::RANKS"** (kept as-is)
  - Given: `subject` valid
  - When: `subject.rank = "11"`
  - Then: `subject` is invalid
- **"opponent validity" — "rejects an opponent not in the game"** (kept as-is)
  - Given: `subject` valid; an unrelated `User` not joined to `game`
  - When: `subject.opponent = outside_user.id`
  - Then: `subject` is invalid
- **"opponent validity" — "rejects the asking player as their own opponent"** (kept as-is)
  - Given: `subject` valid
  - When: `subject.opponent = subject.user_id`
  - Then: `subject` is invalid
- **"hand possession" — "rejects a rank the asking player does not hold"** (kept as-is)
  - Given: `subject` valid; `unheld_rank` = a rank absent from `active_player`'s hand
  - When: `subject.rank = unheld_rank`
  - Then: `subject` is invalid

#### `spec/models/crazy_eights_turn_spec.rb` (new)

Mirrors the trimmed `turn_spec.rb` structure for the other game. Setup: a
started 2-player `CrazyEightsGame`; `held_card` chosen deterministically as a
card in `active_player`'s hand that already matches the discard pile's rank,
suit, or is wild (forcing the discard pile's top card to match one held card
if the random deal doesn't already produce one, so the "valid attributes" case
isn't flaky).

- **it_behaves_like "a turn for an active game and the active player's turn"**
  - Given: `game` = started 2-player `CrazyEightsGame`; `subject` =
    `CrazyEightsTurn.new(rank: held_card.rank, suit: held_card.suit, game_id:
    game.id, user_id: active_player.user_id)`
- **"#draw?"**
  - Given: `subject.action = "draw"`
  - When: `draw?` is called
  - Then: returns `true` (and `false` when `action` is anything else)
- **"draw validation" — "rejects a draw when the deck is empty"**
  - Given: `subject.action = "draw"`; the engine's `deck` forced empty
  - When: validity is checked
  - Then: `subject` is invalid with an error on `:action`
- **"card fields" — "requires a rank and suit when playing a card"**
  - Given: `subject` valid, `action` not `"draw"`
  - When: `subject.rank = nil` (and separately `subject.suit = nil`)
  - Then: `subject` is invalid with the corresponding presence error
- **"card fields" — "rejects a rank/suit outside CrazyEights::Card::RANKS/SUITS"**
  - Given: `subject` valid
  - When: `subject.rank = "11"` (and separately `subject.suit = "Minecraft"`)
  - Then: `subject` is invalid
- **"card possession" — "rejects a card the asking player does not hold"**
  - Given: `subject` valid; a rank/suit combination absent from `active_player`'s hand
  - When: `subject.rank`/`subject.suit` set to that combination
  - Then: `subject` is invalid
- **"discard match" — "accepts a wild card regardless of the discard pile"**
  - Given: `active_player` holds an "8" (wild); `subject.rank`/`suit` set to it
  - When: validity is checked
  - Then: `subject` is valid even if rank/suit differ from the discard pile
- **"discard match" — "rejects a held card matching neither the discard pile's rank nor suit"**
  - Given: a held card chosen to mismatch the discard pile on both rank and suit
  - When: `subject.rank`/`subject.suit` set to it
  - Then: `subject` is invalid

