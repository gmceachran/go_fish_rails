# AGENTS.md

This file is the always-loaded guidance for Claude Code (claude.ai/code) in this
repository. **Keep it lean:** include only the context an agent needs to work
here, and keep the whole file **under 200 lines** — it loads into every session,
so the space is expensive. Push specific or deep material into a focused doc
under `docs/` and link it from *Key context* below instead of inlining it here;
don't accumulate resolved bugs or finished work in this file (that's what
`docs/roadmap-completed.md` is for).

## What this is

A multiplayer, turn-based card game platform. Players sign up, create or join
games in a lobby, and play in real time. Two games are implemented: **Go Fish**
and **Crazy Eights**. It is also a Progressive Web App (installs to the home
screen, serves an offline page with no connection).

This is a **RoleModel apprenticeship training exercise**, not headed to
production. Even so, treat it as **client-ready code** — the project rules below
are held to that standard. Only these two games are expected to ever exist. The
shared game interface exists for clean design, **not** as an invitation to build
speculative multi-game features; avoid scope creep that would only pay off if
more games were added.

## Tech stack

- **Ruby on Rails 8.1**, PostgreSQL, Puma
- **Hotwire** (Turbo + Stimulus) for real-time UI over Action Cable
- **Slim** templates, **SimpleForm**, SCSS via **jsbundling-rails** + webpack/esbuild
- **@rolemodel/optics** design system
- **GoodJob** for background jobs
- **RSpec** + **Capybara** + **Playwright** for tests; **FactoryBot** for fixtures
- **Kamal** + Docker for deployment

## Running the app

```sh
bin/setup    # install deps, prepare DB (execs bin/dev at the end)
bin/dev      # web + JS watcher + GoodJob worker (Procfile.dev), port 3000
```

## Testing

```sh
bundle exec rspec                               # full suite
bundle exec rspec spec/models/game_spec.rb      # one file
bundle exec rspec spec/models/game_spec.rb:42   # one example (by line)
bin/turbo_tests                                 # parallelized run
```

- `spec/models/` — unit specs, incl. per-game logic under `spec/models/go_fish/`
  and `spec/models/crazy_eights/`.
- `spec/systems/` — full-stack Capybara + Playwright browser specs;
  `spec/systems/smoke_tests/` are lightweight page-render checks.

- Prefer asserting on state over `sleep`-based waits in specs. The main open
  test-architecture item is adding a request/controller spec layer (assert turn
  outcomes at the DB/model boundary) — see `docs/roadmap.md`.

## Linting & security

```sh
bin/rubocop         # rubocop-rails-omakase style
bin/brakeman        # static security analysis
bin/bundler-audit   # gem CVE audit
bin/ci              # setup + rubocop + bundler-audit + brakeman (no specs — see roadmap)
```

## Project rules (do not break these)

These are hard constraints. They must hold on **every commit that will remain in
history** (a throwaway WIP commit you'll delete later is exempt). They cannot be
inferred from the code and an agent will get them wrong by default:

1. **TDD, always: red → green → refactor.** No production code without a failing
   test driving it. You may now write specs, but only through this gated flow:
   (a) create the spec file; (b) in `docs/spec-plans.md`, write out the logical
   flow — what each example sets up and asserts — and agree it with the developer;
   (c) write the spec to match; (d) the developer reviews the spec; (e) **only
   after that review** do you write the production code to make it pass. Never
   jump ahead to implementation before the spec is reviewed.
2. **No method longer than 7 lines** — this includes RSpec `it` blocks and Ruby
   blocks generally.
3. **No instance variables**, with two exceptions: initializers, and Rails
   controller actions exposing state to a Slim view. Everywhere else use a
   getter/setter.
4. **Given / When / Then specs** (context, for when you're reading them): *given*
   → `before`/`let`; *when* (the action under test) → in the `it` block, may
   delegate to a helper; *then* (the assertion) → in the `it` block.
5. **All UI goes through `@rolemodel/optics`** — don't hand-roll CSS. (Existing
   hand-rolled styles are flagged for refactor in the roadmap.)
6. **Every commit is green-or-pending.** Pending is only for a feature genuinely
   split across several commits.

Commit workflow: branch per feature (no squashing yet); before committing, review
every changed file and confirm new code has a driving spec.

## Architecture (big picture)

`Game` is an ActiveRecord model using **single-table inheritance** (`type`
column): `GoFishGame` and `CrazyEightsGame`. The full game state (deck, hands,
discard pile, turn results) is **not** relational — it is serialized as JSONB
into the `game_state` column via `serialize ..., coder:`, round-tripping through
plain-Ruby domain objects under `app/models/go_fish/` and
`app/models/crazy_eights/`. Those POROs (`Implementation`, `Deck`, `Card`,
`Player`, `Book`, `TurnResult`, `GameBoard`) hold all card-game rules and know
nothing about the database; each `Implementation` subclasses the shared
`GameImplementation` and exposes a common interface (`start`, `play_turn`,
`advance_turn`, `winner`, `board_for`). See `docs/architecture.md`.

Turn flow: a controller builds a non-persisted `ActiveModel` form object (`Turn`
for Go Fish, `CrazyEightsTurn` for Crazy Eights), validates it, calls
`game.play_turn` then `advance_turn`, and saves. `broadcast_refresh_later_to`
callbacks push Turbo Stream refreshes to connected clients.

## Conventions worth knowing

- **`game_state` is serialized, not relational.** To change game data, edit the
  POROs and their `from_json` — no migrations. Serialization is *meant* to be
  symmetric, but mind the trap: `dump` is the implicit `Object#as_json` (it
  serializes every instance variable) while `from_json` is hand-written, so
  **adding or renaming an ivar on a `game_state` PORO is silently dropped on
  reload unless you also update `from_json`.** Already bitten twice
  (`GoFish::Player#name`, `CrazyEights::TurnResult#wild`) — see `docs/roadmap.md`.
- **New/changed game logic lives in the `Implementation` + STI subclass**; don't
  special-case games in shared controllers/views beyond the existing `case game`
  dispatch.
- `Current.session` / `Current.user` carry the authenticated user (see
  `app/controllers/concerns/authentication.rb`) — no Devise.
- The `Player` join model auto-starts the game once full (`start_if_full!` via an
  `after_create` callback).
- **Two different "Player" types exist**: the persisted `Player` join record and
  the in-memory `GoFish::Player` / `CrazyEights::Player`. This naming is known-bad
  and slated for a refactor — see `docs/roadmap.md`.
- Implicit block param `it` (Ruby 3.4) is used intentionally (e.g.
  `players.detect { it.user_id == id }`) — leave it, don't rewrite to explicit.

## Key context

- `docs/architecture.md` — models, STI, JSONB serialization, turn/broadcast flow
- `docs/go-fish.md` — Go Fish rules as implemented
- `docs/crazy-eights.md` — Crazy Eights rules as implemented
- `docs/roadmap.md` — **open** known issues, tech debt, and refactors to tackle;
  keep it to outstanding work only — move resolved items out to
  `docs/roadmap-completed.md` rather than leaving them here marked done
- `docs/roadmap-completed.md` — resolved roadmap items and what the fix was
- `docs/spec-reliability.md` — write-up of the (now-resolved) suite-hang investigation and the go-forward test-architecture plan
- `docs/spec-plans.md` — where the logical flow of a spec is hashed out and agreed before the spec is written (see project rule 1)
- `docs/questions.md` — running questions for instructors (for the developer, not agents)
