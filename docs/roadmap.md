# Roadmap & known issues

Running list of work to do, bugs, and tech debt worth tracking. Keep this
focused; if a category grows large, split it into its own doc.

## Top priority

- **Go Fish can't finish; the winner-declaration path is still game-specific.**
  Originally both games failed to complete; the Crazy Eights half is now resolved
  (see `docs/roadmap-completed.md`). What remains:
  - Go Fish: `GoFish::Implementation#winner` computes the winner correctly, but
    **nothing ever calls `Game#declare_winner!`** — `TurnsController` only
    advances and saves on the Go Fish path. The lone caller of `declare_winner!`
    is the Crazy Eights branch (`turns_controller.rb:52-58`), so Go Fish never
    reaches `over?`.
  - The one caller that exists is `declare_crazy_eights_winner`, a game-specific
    private method that reaches into `game.game_state.winner`. The shared fix
    (Card 2 in `docs/cards.md`) is a `Game#declare_winner_if_over!` both turn paths
    call — closing Go Fish and removing the reach-through in one move.
  End-to-end coverage is still thin: no request spec exists, and
  `crazy_eights_play_spec.rb:46` (`# it "the turn ends"`) is still commented out.

## Security

Surfaced in an assessment pass; none are behind any authorization.

- **Any authenticated user can view any game's board (IDOR).**
  `GamesController#show` (`app/controllers/games_controller.rb:7-13`) does
  `Game.find(params[:id])` with no check that the current user is a participant,
  then builds a board for a `user_id` that may not be in the game — a
  non-participant's `player(user_id)` is `nil` (latent view crashes) and a private
  game's state leaks. Same unscoped `Game.find` in `WinnersController#show`
  (`winners_controller.rb:3`) and `TurnsController#create` (`turns_controller.rb:3`).
  Scope through the current user (`Current.session.user.games.find(...)`) or a
  membership `before_action`.
- **GoodJob dashboard mounted with no auth.** `config/routes.rb:37-38`
  (`mount GoodJob::Engine => "good_job"`) — the code's own comment says it should
  be behind admin validation. Anyone can browse `/good_job`, read job args, and
  retry/discard jobs. Wrap in an authenticated constraint or basic auth.
- **Joining a game skips the `joinable?` guard.** `PlayersController#create`
  (`players_controller.rb:2-15`) never calls `Game#joinable?` (`game.rb:16`), so a
  user can join a game that is already full/active/over. There is also no
  save-failure branch, so a failed `save` (e.g. re-join uniqueness) falls through
  to a missing `create` template.

## Known bugs

- **Go Fish `advance_turn` unbounded recursion (latent).**
  `GoFish::Implementation#advance_turn` (`go_fish/implementation.rb:84-92`)
  recurses (l.91) whenever the next player `cant_play`, with no base case for
  when *every* player is stuck — an all-`cant_play` end-game state recurses until
  `SystemStackError`. Not the current suite freeze (that's Crazy Eights), but a
  real crash waiting on certain deck-exhausted states.
- **`game_state` silently loses data on reload.** `dump` is the implicit
  `Object#as_json` (every ivar) while `from_json` is hand-written, so the two
  drift by construction — and already have: `GoFish::Player#name`
  (`go_fish/player.rb:19-31`) and `CrazyEights::TurnResult#wild`
  (`crazy_eights/turn_result.rb:12-21`) are written on save but dropped on load.
  The `wild` drop visibly breaks the wild/suit UI after any refresh
  (`crazy_eights/implementation.rb:71` reads it). No schema versioning, and
  missing-key guards are inconsistent between the two games.
- **Navigation out of `games#show`** is awkward / missing a clean path back.
- **`GamesController#create` ignores the save result.**
  (`games_controller.rb:19-24`) calls `@game.save` without checking it, then
  `@game.players.create(...)` against a possibly-unpersisted game, and always
  redirects to root — a validation failure is silently swallowed. Branch on
  `@game.save`.
- **Go Fish feed shows hardcoded fake data.**
  `app/views/games/_feed.html.slim:1-17` is static placeholder markup (a fictional
  "Joby asked Natalie for 9s…") shown to every player; the real `turn_results`
  machinery (`go_fish/implementation.rb:138,144`) is populated but ignored. The
  Crazy Eights feed (`_crazy_eights_feed.html.slim`) likewise never iterates
  `turn_results`.
- **`_crazy_eights_feed.html.slim:5` references an undefined form builder `f`** →
  `NameError` whenever `@board.wild` is true. Ties into the unfinished eights/suit
  feature listed under Refactors.
- **Winner redirect uses the wrong route params.**
  `GamesController#redirect_to_winner` (`games_controller.rb:33`) calls
  `game_winner_path(...winner.user_id)` — one positional arg for a nested
  `game_id`+`id` route → `UrlGenerationError` — and `WinnersController#show`
  (`winners_controller.rb:3`) then does `Game.find(params[:id])` on what is
  actually a user id. Distinct from the "`declare_winner!` never called" gap
  above; both sit on the same broken path.

## Refactors

- **Rename the `Player` ActiveRecord model.** The persisted join model `Player`
  collides confusingly with the in-memory `GoFish::Player` / `CrazyEights::Player`
  POROs. Candidate name: `GameUser`. One of several naming decisions to revisit.
- **Move hand-rolled CSS onto `@rolemodel/optics`.** UI should go through the
  design system; there's existing custom CSS to migrate.
- **Crazy Eights is missing its namesake feature.** Suit selection on eights is
  only half-built: the `:suit`/`:action` turn params exist, `board_for` passes a
  `wild:` flag for the UI, and `crazy_eights/implementation_spec.rb:206` is a
  stubbed `xit` ("plays an eight / choose a new suit"). But `playable?`
  (`implementation.rb:150-153`) still compares against the discard's own suit, and
  the chosen suit is never persisted anywhere — so a played 8 doesn't actually
  change the required suit. Finish the flow (persist the chosen suit; have
  `playable?` honor it).
- **Massive copy-paste between the two `Implementation`s.** `active_player`,
  `player`, `opponents`, `number_of_players`, `deal`, the `from_json`
  players/deck-decoding shape, and the STI `start_if_full!` /
  `update_with_starting_game_state` override are duplicated per game; `Card` and
  `Deck` are ~90% identical across `go_fish/` and `crazy_eights/`. A third game
  would copy all of it again. Candidate for a shared base — but only two games
  will ever exist, so keep the abstraction conservative (see `AGENTS.md`).
- **`GameImplementation` isn't an enforced base class.** It abstracts almost
  nothing beyond `players` + `load`/`dump`, with no `NotImplementedError` stubs
  for `start`/`play_turn`/`advance_turn`/`winner`/`board_for`. The interface is
  convention-only, so a new game reverse-engineers it from the two existing
  examples rather than filling in a documented contract.

- **Finish delegating engine calls through `Game`.** `Game#play_turn`
  (`game.rb:23-25`) already delegates to `game_state`, but every other call
  reaches two levels deep into the serialized PORO —
  `game.game_state.advance_turn` / `.winner` / `.board_for` in
  `turns_controller.rb:29,47,53`, `games_controller.rb:10,33`, and
  `winners_controller.rb:3`. Add matching one-line `Game` delegators so the web
  layer stops depending on the internal `game_state` name and the engine's full
  surface.
- **Extract a shared base for `Turn` / `CrazyEightsTurn`.** `game`,
  `game_is_active`, and `user_is_active_player` are copy-pasted between
  `app/models/turn.rb:19-21,27-30,42-45` and
  `app/models/crazy_eights_turn.rb:19-21,27-30,32-35`. The shared `game` memoizer
  also uses `@game ||= Game.find_by(...)` — an instance variable outside an
  initializer or controller action, which **violates project rule 3**; fold it
  into a getter/setter in the shared base.

## Performance & cleanup

- **N+1 on the games index.** `GamesController#index` (`games_controller.rb:2-5`)
  does `Game.waiting - @user_games`, loading every waiting game and diffing arrays
  in Ruby; then each row (`_open_game.html.slim:8-11`, `_user_game.slim:8-11`)
  calls `joinable?` / `players.count`, firing a `COUNT` per game. Exclude the
  user's games in SQL and preload/counter-cache the player counts.
- **Stimulus `turn_timer` leaks its interval.**
  `app/javascript/controllers/turn_timer_controller.js:8-13` starts a
  `setInterval` in `connect()` with no `disconnect()` to clear it. Because the
  board is driven by `broadcast_refresh_later_to` Turbo refreshes, the view is
  torn down/re-rendered often, so intervals accumulate and the countdown
  accelerates. Add `disconnect() { clearInterval(this.timer) }`.
- **Missing indexes on `games.type` and `games.state`** (`db/schema.rb:17-27`).
  STI filters on `type` and the app filters on `state` constantly (`Game.waiting`,
  `not_over`, `ArchiveGamesJob`, `User#games_played_count`). Cheap migration.

## Testing

Lower priority now that the suite is green. These were elevated when the browser
layer was suspected of causing the hang; that's resolved, so treat them as
confidence/quality work rather than urgent.

- **No request/controller specs exist at all.** The entire turn-application flow
  — `TurnsController` dispatch, `advance_turn unless go_again`/`play_again`,
  winner declaration — is unverified except through the browser suite. There is
  no `type: :request` spec anywhere. A request-spec layer asserting turn outcomes
  at the DB/model boundary (factories + `POST` a turn) is the natural place to
  lock down the turn flow — and the winner-declaration fix in Top priority.
- **Reduce reliance on the browser suite.** Stop leaning on Capybara so heavily
  and assert game state directly via the database instead of driving the browser
  for everything. See `docs/spec-reliability.md` for the full investigation and
  go-forward plan.

## Worth noting, not necessary

Low-priority items that would only matter with a significant refactor and are
likely out of scope for the current work. If these start to pile up, give them
their own doc.

- **Branch-level task tracking.** The roadmap captures the app's trajectory and
  shared context (bugs, refactors, priorities). For individual branches, consider
  maintaining a separate checklist (e.g., `TODO.md` in the branch) with
  implementation details: step-by-step substeps, progress, verification notes,
  and decisions made along the way. This keeps the roadmap focused on the big
  picture while letting a developer (or future reader) follow granular progress
  without cluttering the main artifact. Worth prototyping on the next branch to
  see if it improves clarity.
- **`ArchiveGamesJob` / `archived_at`.** Built to satisfy an assignment
  requirement; it stamps `archived_at` but isn't doing anything genuinely useful
  yet. Making it worthwhile would take a meaningful refactor — probably out of
  scope for the near term. It also has a latent correctness/perf bug:
  `Game.where(state: :over) + Game.where("updated_at <= ?", …)`
  (`app/jobs/archive_games_job.rb:5-10`) unions two relations into a Ruby Array,
  so a game that is both over and stale gets stamped twice, then updates
  row-by-row — collapse to a single relation + `update_all`.
- **Small latent cleanups.** `GoFish::GameBoard#discard_card`
  (`go_fish/game_board.rb:29`) reads an unassigned `@extras` — would raise if ever
  called. `implementation_key` is defined twice in `GoFish::Implementation`. The
  `Card#data` / `TurnResult#data` methods look like serializers but aren't in the
  dump/load path — dead lookalikes that can mislead a maintainer editing
  persistence. The `pages#index` route (`config/routes.rb:29`,
  `resources :pages, only: [:index]`) points at an action/view that don't exist
  (`PagesController` has only `rules`) — a route to a 500. `GoFish::Player#initialize`'s
  default `user_id: user_id` (`go_fish/player.rb:6`) is self-referential (resolves
  to `nil`), while `CrazyEights::Player` defaults to `0` — pick one.
