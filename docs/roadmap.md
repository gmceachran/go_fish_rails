# Roadmap & known issues

Running list of work to do, bugs, and tech debt worth tracking. Keep this
focused; if a category grows large, split it into its own doc.

## Features

- **Collect a username at sign-up.** `User` has no `username` column at all
  (`db/schema.rb:149-157`); only `email_address`/`password` are collected
  (`app/views/users/new.html.slim`). Needs a migration plus a form field and
  uniqueness validation.
- **Collect location at sign-up.** `country`/`state` already exist on `User`
  and are editable after the fact via the profile edit modal
  (`app/views/users/edit.html.slim`), but `users/new.html.slim` never asks for
  them — sign-up only collects email/password. Add the same `country`/`state`
  inputs to the sign-up form.
- **Show how many cards are left in the deck.** Both engines already compute
  this (`GoFish::Engine#deck_length`, `deck.cards_left` on both
  `Deck`s) but neither `GameBoard` (`go_fish/game_board.rb`,
  `crazy_eights/game_board.rb`) carries it through, so it's never rendered.
  Add a `deck_count` (or similar) to `board_for` and surface it in the
  templates.

## Security

Surfaced in an assessment pass; none are behind any authorization.

- **Any authenticated user can view any game's board (IDOR).**
  `GamesController#show` (`app/controllers/games_controller.rb:7-13`) does
  `Game.find(params[:id])` with no check that the current user is a participant,
  then builds a board for a `user_id` that may not be in the game — a
  non-participant's `player(user_id)` is `nil` (latent view crashes) and a private
  game's state leaks. Same unscoped `Game.find` in `TurnsController#create`
  (`turns_controller.rb:3`) — the win-screen path no longer has its own lookup
  (`WinnersController` is gone; it reuses the same `@game_model`) but inherits
  this same exposure. Scope through the current user
  (`Current.session.user.games.find(...)`) or a membership `before_action`.
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
  `GoFish::Engine#advance_turn` (`go_fish/engine.rb:36-39`)
  recurses (l.38) whenever the next player `cant_play`, with no base case for
  when *every* player is stuck — an all-`cant_play` end-game state recurses until
  `SystemStackError`. Not the current suite freeze (that's Crazy Eights), but a
  real crash waiting on certain deck-exhausted states.
- **`game_state` silently loses data on reload (mostly resolved).** Where a
  PORO hand-writes `from_json`, it can drift from `dump` (the implicit
  `Object#as_json`, every ivar). `Card`, `Deck`, both `TurnResult`s, `Player`,
  and `Engine` now include `Games::Serializable` and are safe by construction —
  this fixed the `CrazyEights::TurnResult#wild` drop that broke the wild/suit UI
  after a refresh and the `GoFish::Player#name` drop. Only `GoFish::Book` still
  hand-writes `from_json`. Still no schema versioning.
- **No way to navigate out of `games#show` while a game is in progress.**
  Neither `games/show.html.slim` nor `layouts/application_no_sidebar.html.slim`
  has any link back to the games list — a player has to use the browser back
  button. Card 3's win modal (`games/_winner_modal.html.slim`) added a "Back to
  Games" button, but only for the *finished*-game case; an active game is
  still a dead end.
- **`GamesController#create` ignores the save result.**
  (`games_controller.rb:19-24`) calls `@game.save` without checking it, then
  `@game.players.create(...)` against a possibly-unpersisted game, and always
  redirects to root — a validation failure is silently swallowed. Branch on
  `@game.save`.
- **Go Fish feed shows hardcoded fake data.**
  `app/views/games/_feed.html.slim:1-17` is static placeholder markup (a fictional
  "Joby asked Natalie for 9s…") shown to every player; the real `turn_results`
  machinery (`go_fish/engine.rb:68,74`) is populated but ignored. The
  Crazy Eights feed (`_crazy_eights_feed.html.slim`) likewise never iterates
  `turn_results`.
- **`_crazy_eights_feed.html.slim:5` references an undefined form builder `f`** →
  `NameError` whenever `@board.wild` is true. Ties into the unfinished eights/suit
  feature listed under Refactors.

## Refactors

- **Rename the `Player` ActiveRecord model.** The persisted join model `Player`
  collides confusingly with the in-memory `GoFish::Player` / `CrazyEights::Player`
  POROs. Candidate name: `GameUser`. One of several naming decisions to revisit.
- **Move hand-rolled CSS onto `@rolemodel/optics`.** UI should go through the
  design system; there's existing custom CSS to migrate.
- **Crazy Eights is missing its namesake feature.** Suit selection on eights is
  only half-built: the `:suit`/`:action` turn params exist, `board_for` passes a
  `wild:` flag for the UI, and `crazy_eights/engine_spec.rb:147` is a
  stubbed `xit` ("plays an eight / choose a new suit"). But `playable?`
  (`crazy_eights/engine.rb:82-83`) still compares against the discard's own suit, and
  the chosen suit is never persisted anywhere — so a played 8 doesn't actually
  change the required suit. Finish the flow (persist the chosen suit; have
  `playable?` honor it).
- **Domain de-duplication — see `docs/dedup-plan.md`.** Phases 0–4 are landed:
  `Card`/`Deck`, the in-memory `Player`, the shared `Engine` queries, the
  enforced `Games::Engine` contract, and the STI start-up template (subclasses
  now declare only `serialize` + `engine_class`/`player_class`) are all
  consolidated. Remaining: the `Turn` form objects (Phase 5) and the remaining
  `Game` engine delegators (Phase 6). That doc is the entry point for this work;
  it also absorbs several serialization bugs listed under *Known bugs*.

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
  winner declaration — is unverified except through the browser suite (system
  specs) and, for `declare_winner_if_over!` itself, a model spec. There is no
  `type: :request` spec anywhere. A request-spec layer asserting turn outcomes at
  the DB/model boundary (factories + `POST` a turn) is the natural place to lock
  down the turn flow more cheaply than full browser specs.
- **Reduce reliance on the browser suite.** Stop leaning on Capybara so heavily
  and assert game state directly via the database instead of driving the browser
  for everything. See the "Suite hang" entry in `docs/roadmap-completed.md` for
  the investigation that motivated this.

## Worth noting, not necessary

Low-priority items that would only matter with a significant refactor and are
likely out of scope for the current work. If these start to pile up, give them
their own doc.

- **Show a country flag next to the username.** Once usernames exist (see
  Features), display a flag icon for the user's `country` next to it wherever
  the username is rendered. Tie into that refactor rather than doing it
  separately.
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
  called. The
  `pages#index` route (`config/routes.rb:29`,
  `resources :pages, only: [:index]`) points at an action/view that don't exist
  (`PagesController` has only `rules`) — a route to a 500.
