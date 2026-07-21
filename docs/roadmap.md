# Roadmap & known issues

Running list of work to do, bugs, and tech debt worth tracking. Keep this
focused; if a category grows large, split it into its own doc.

## Top priority

Fixing up the specs in general — the single biggest lever on confidence in the
platform. Two related strands:

- **System suite is flaky and hangs.** The one confirmed deterministic cause
  (Crazy Eights opening-discard infinite loop) is fixed — see
  `docs/roadmap-completed.md`. The broader strategy is still open: stop leaning
  on Capybara so heavily and assert game state directly via the database
  (queries and factories) instead of driving the browser for everything. See
  `docs/spec-reliability.md` for the full investigation and go-forward plan.
- **No request/controller specs exist at all** (most severe). The entire
  turn-application flow — `TurnsController` dispatch, `advance_turn unless
  go_again`/`play_again`, winner declaration — is unverified except through the
  flaky browser suite. There is no `type: :request` spec anywhere. This is also
  the missing middle layer the flakiness fix wants: assert turn outcomes at the
  DB/model boundary (factories + `POST` a turn) instead of driving Capybara.

## Known bugs

- **No game can actually finish — for *either* game.** Two halves of the same
  gap:
  - Crazy Eights: `CrazyEights::Implementation#winner` returns `false`, so a game
    never declares a winner or ends. Needs real end-of-game detection (a player
    emptying their hand). See `docs/crazy-eights.md`.
  - Go Fish: `GoFish::Implementation#winner` computes the winner correctly, but
    **nothing ever calls `Game#declare_winner!`** — `TurnsController` only
    advances and saves on the Go Fish path. The lone caller of `declare_winner!`
    is the Crazy Eights branch (`turns_controller.rb:57`), so Go Fish never
    reaches `over?`.
  Good "read the pending tests first" case: there's no `#winner` spec under
  `crazy_eights/`, and `crazy_eights_play_spec.rb:46` has a commented-out
  `# it "the turn ends"`. Worth deciding, in-session, where the shared
  winner-declaration path should live (model turn-flow vs. the controller).
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
  scope for the near term.
- **Small latent cleanups.** `GoFish::GameBoard#discard_card`
  (`go_fish/game_board.rb:29`) reads an unassigned `@extras` — would raise if ever
  called. `implementation_key` is defined twice in `GoFish::Implementation`. The
  `Card#data` / `TurnResult#data` methods look like serializers but aren't in the
  dump/load path — dead lookalikes that can mislead a maintainer editing
  persistence.

## Done

Resolved items move to `docs/roadmap-completed.md`, with what the fix actually
was, instead of piling up here.
