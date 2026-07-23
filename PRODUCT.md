# Product

<!-- impeccable:product-schema 1 -->

## Platform

web

## Users

Primary: casual social players — friends and family who want to play familiar
card games together online, in real time, from wherever they are. They arrive to
play a specific game with people they already know, not to browse or configure.

Secondary: RoleModel apprentices and instructors, who evaluate the work as a
craft benchmark. When priorities conflict, the player's experience wins; the
review context never justifies a worse experience for players.

## Product Purpose

A multiplayer, turn-based card game platform. Players sign up, create or join a
game in a lobby, and play together in real time as turns and results push live
to every connected player. Success is a game that fills, starts, and plays
through to a winner smoothly — with the state every player sees staying correct
and in sync throughout.

## Positioning

A focused real-time home for a small, curated set of well-known card games,
built so each new game plugs into one shared, contract-driven game engine rather
than being a bespoke one-off. The differentiator is architectural discipline: a
documented shared game interface that makes "add another game" a subclassing
exercise, keeping every game consistent in feel and correctness.

## Operating Context

- Real-time, multi-device sessions: several players on separate devices in one
  game, each acting on their turn while the board refreshes live for everyone.
- Installable as a Progressive Web App (home-screen install; serves an offline
  page with no connection).
- Core flows: authenticate → lobby (create/join a game) → auto-start when the
  game is full → take turns → reach a winner. Supporting surfaces: game history,
  stats, and a rules reference page.

## Capabilities and Constraints

- Implemented games: **Go Fish** and **Crazy Eights**. **Rummy** is a confirmed
  third game, in design (see `docs/rummy-concepting/`, `docs/rummy.md`).
- Turn-based play with live updates over Action Cable (Turbo Streams); a game
  auto-starts once enough players have joined.
- Player-facing surfaces: lobby/index, in-game board, game history, stats, rules.
- Authentication is built-in (no third-party identity provider).
- Terminology note: two distinct "Player" concepts exist — the persisted join
  record and the in-memory per-game player. This is known-confusing and slated
  for a rename; keep user-facing language unambiguous about whose turn it is and
  who is in the game.
- Technical stack (durable constraints for now): Rails, Hotwire (Turbo +
  Stimulus), Slim templates, SimpleForm, SCSS. This is a training exercise, not
  production-bound, but is held to a client-ready standard.

## Brand Commitments

- **All UI goes through `@rolemodel/optics`.** This is a hard, standing
  constraint — the design system is the required component and styling
  vocabulary; hand-rolled CSS is not permitted (existing hand-rolled styles are
  flagged for refactor).
- The platform has **no committed product name or standalone identity of its
  own yet** — that is an open decision, deliberately left undecided here.
- Voice/personality: undecided.

## Evidence on Hand

- Working implementation of two full games with real turn flow, live sync, and
  win detection.
- In-repo documentation of rules and architecture: `docs/go-fish.md`,
  `docs/crazy-eights.md`, `docs/architecture.md`.
- No real end-user testimonials, usage metrics, customer names, or player counts
  exist; future work must not fabricate any.

## Product Principles

1. **Players first.** The apprenticeship origin and review audience never justify
   a worse experience for the people actually playing.
2. **Correct, shared state above all.** In a real-time multiplayer game, every
   player seeing the same true board state is the product working; drift or
   confusion about whose turn it is is a failure.
3. **One shared game engine.** Consistency across games comes from a documented
   shared contract, not per-game bespoke code — new games subclass it.
4. **Client-ready craft.** Even as a training exercise, treat every surface as if
   a client will use it.
5. **Familiar games, low friction.** Players come to play a game they already
   know; get them from lobby to playing with as little ceremony as possible.

## Accessibility & Inclusion

No product-specific accessibility standard has been established yet. As a
real-time, turn-based game, turn state and game feedback must not rely on color
alone; confirm a target standard before treating it as settled.
