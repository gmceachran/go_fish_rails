# Architecture

How the game platform is put together, and why. Read this alongside `AGENTS.md`.

## The core idea

The database stores as little game-specific structure as possible. A single
`games` table holds every game of every type; the moment-to-moment state of a
game (whose turn it is, what's in each hand, the deck, the discard pile, the
history of turn results) lives as a **JSONB blob** in `games.game_state`. All
the actual rules live in plain-Ruby objects (POROs) that serialize into and out
of that blob.

This keeps the Rails/ActiveRecord layer thin and game-agnostic, and keeps the
game rules in ordinary, fast-to-test Ruby objects with no database dependency.

## Persisted models (ActiveRecord)

- **`User`** — `has_secure_password`; `has_many :players`, `has_many :games,
  through: :players`. Also carries profile/location data (see `Data::State`,
  `Data::Country`, used on the profile page). Exposes stats helpers
  (`games_played_count`, `games_won_count`, `win_percentage`).
- **`Game`** — single-table inheritance via the `type` column.
  - `state` enum: `waiting` / `active` / `over`.
  - `joinable?`, `start_if_full!`, `play_turn`, `declare_winner!`,
    `declare_winner_if_over!` (reads the engine's `winner`, maps it to the
    persisted `Player`, and calls `declare_winner!` — a no-op if no one's won
    yet).
  - Validations keep timestamps (`started_at`, `ended_at`) consistent with
    `state`, and `ended_at` consistent with whether a winner exists.
  - `after_create_commit` / `after_update_commit` → `broadcast_refresh_later_to`
    drive Turbo Stream updates to clients.
- **`GoFishGame` / `CrazyEightsGame`** — STI subclasses. Each declares
  `serialize :game_state, coder: <Game>::Engine` and overrides
  `start_if_full!` to build and `start` the initial `Engine` once the
  game fills up.
- **`Player`** — join between `User` and `Game`. Uniqueness scoped to
  `[game_id, user_id]`. `after_create :start_game_if_full` triggers game start.
  Holds the `winner` boolean. **Note the naming clash with the in-memory
  `<Game>::Player` POROs** (roadmap item).
- **`Session` / `Current`** — authentication. `Current.session` / `Current.user`
  are the authenticated identity; see `app/controllers/concerns/authentication.rb`.

## In-memory game state (POROs)

Under `app/models/go_fish/` and `app/models/crazy_eights/`:

- **`Engine`** (subclasses shared `Games::Engine`) — the engine.
  Common interface across games:
  - `start` — shuffle + deal (+ start discard pile for Crazy Eights).
  - `play_turn(turn)` — apply a validated turn, return a `TurnResult`.
  - `advance_turn` — move to the next eligible player.
  - `winner` — the winning PORO player, or nil/false if the game isn't over.
  - `board_for(user_id:, game_id:)` — build a `GameBoard` view object for one
    client (what that player can see this turn).
  - `active_player?(user_id)`, `player(user_id)`, `opponents`.
- **`Deck`** — 52 `Card`s by default; `shuffle`, `top_card` (shift), `empty?`.
- **`Card`** — `rank`, `suit`, value, display name. Crazy Eights' card adds
  `wild?` (rank `8`).
- **`Player`** (PORO) — `user_id`, `hand`, and game-specific bits (Go Fish adds
  `books`, `cant_play`, `create_book_if_possible`).
- **`TurnResult`** — a serializable record of what happened on a turn, used to
  render the feed. Go Fish: `go_fish`, `cards`, `book_made`, `go_again`,
  `deck_empty`. Crazy Eights: `drew_card`, `played_card`, `play_again`, `wild`.
- **`GameBoard`** — a per-request view object handed to the Slim templates.

## Serialization contract

`serialize :game_state, coder: <Game>::Engine` means Rails calls
`Engine.dump(obj)` when writing and `Engine.load(json)` when
reading. `Games::Engine.dump` is `obj.as_json`; `load` delegates to each
`Engine.from_json`.

**The round trip must be symmetric.** `Card`, `Deck`, and both `TurnResult`s now
include `Games::Serializable` (`app/models/games/serializable.rb`): they declare
their fields once with `scalar` / `nested_one` / `nested_many`, and both `as_json`
and `from_json` derive from that one list, so they can't drift. The still-hand-written
POROs (`Player`, `Engine`, `Book`) must keep `from_json` in sync with what
`as_json`/`dump` writes by hand, or state silently drops on reload. There are no
migrations for this data — the "schema" is the serialization code.

## Turn flow (request lifecycle)

1. Client submits a turn form to `TurnsController#create`.
2. The controller dispatches on game class (`case game`), builds the matching
   non-persisted `ActiveModel` form object — `Turn` (Go Fish) or
   `CrazyEightsTurn` — merging in `user_id`/`game_id`, and validates it. Invalid
   turns are dropped silently (redirect back).
3. On valid: `game.play_turn(turn)` mutates the in-memory state and returns a
   `TurnResult`; the controller calls `advance_turn` unless the result says the
   player goes again; `game.save!` persists the JSONB.
4. Both games then call `game.declare_winner_if_over!` — a no-op unless the
   engine's `winner` is set, in which case it flags the persisted `Player` and
   moves the game to `state: :over`.
5. The `after_update_commit` broadcast refreshes connected clients via Turbo.

## Views

`GamesController#show` builds a `GameBoard` via `board_for` and renders with the
`application_no_sidebar` layout. Shared partials live in `app/views/games/`
(`shared/`, `implementations/`), dispatching to per-game partials named by the
implementation key (`go_fish`, `crazy_eights`).

## Background jobs

`GoodJob` (see the `worker` line in `Procfile.dev`). `ArchiveGamesJob` stamps
`archived_at` on finished/stale games — see the roadmap for its status.
