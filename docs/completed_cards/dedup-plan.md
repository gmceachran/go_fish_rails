# Domain de-duplication plan

The backend domain layer carries heavy copy-paste between the two games. This
doc is the single, ordered strategy for removing it. The driving goal: **adding
the next card game should mean subclassing a documented contract, not copying an
existing game.**

Scope is the domain models (`app/models/**` POROs, the STI game classes, and the
`Turn` form objects). Phase-level here on purpose — per-change detail is written
per session via the `docs/spec-plans.md` gated TDD flow, one phase at a time.

> **Shipped.** All phases (0–6) are committed. A full end-to-end spike of every
> phase was built and verified first, then stashed to serve as the destination
> reference while each phase was rebuilt green, one phase = one commit; the
> stash was dropped once every phase had been lifted from it. See
> `docs/roadmap-completed.md` ("Domain de-duplication") for the summary. This
> file is kept as the durable record of the strategy and the per-phase
> decisions made along the way.

## Guiding constraints

- **TDD gating (project rule 1)** applies to every phase: spec file → logical
  flow agreed in `docs/spec-plans.md` → spec → developer review → production
  code. A refactor is still red→green→refactor; leaning on the existing specs to
  stay green is expected, but any *new* public method gets its own driving spec.
- **One phase ≈ one session.** Phases are ordered so each is independently
  shippable and leaves the suite green.
- **Earn each abstraction.** Pull a method up only when both games (or a
  concrete third) actually share it. No hooks that only pay off for a
  hypothetical game.
- Respect the 7-line method limit and the no-instance-variable rule (rule 3) —
  Phase 5 exists partly because the current `Turn` base violates rule 3.

## Target architecture (end state)

Base POROs live in a `games/` folder under the `Games::` module — a plain
module, deliberately **not** the ActiveRecord `Game` class, so the DB-free POROs
aren't namespaced under an ActiveRecord constant (keeps the "POROs know nothing
about the database" line clean). The two game folders keep their existing
`GoFish::` / `CrazyEights::` names, so the base extraction adds a folder rather
than renaming ~27 files. Subclassing is by inheritance, not nesting — flat
siblings, one level deep.

```
app/models/
  game.rb                  # Game < ApplicationRecord            (AR, unchanged)
  games/
    serializable.rb        # Games::Serializable — declared attrs drive as_json/from_json
    card.rb                # Games::Card   — rank/suit, RANKS, SUITS, names, ==, to_s, value
    deck.rb                # Games::Deck   — cards, shuffle, top_card, empty?, cards_left
    player.rb              # Games::Player — user_id, name, hand, hand_size
    engine.rb              # Games::Engine — runs the game; shared queries + NotImplementedError contract
    turn.rb                # Games::Turn — ActiveModel base: game/game_state, active-player
  go_fish/…                # GoFish::Card < Games::Card, etc. — game-specific rules only
  crazy_eights/…           # CrazyEights::…
```

(`Games::Player` also sidesteps the top-level `::Player` collision with the AR
join model — the base can be named `Player` because it's namespaced.)

**Adding a game, after this plan lands**, becomes roughly:

1. `NewGame::Card < Games::Card` (+ any wild/value quirk), `NewGame::Deck < Games::Deck`.
2. `NewGame::Player < Games::Player` (+ game-specific hand logic).
3. `NewGame::Engine < Games::Engine` — implement the required contract methods
   (`start`, `play_turn`, `advance_turn`, `winner`, `board_for`); shared queries
   come for free.
4. `NewGameGame < Game` — declare `serialize` + `engine_class` / `player_class`.
5. `NewGame::Turn < Games::Turn` — add game-specific validations only.
6. A per-game partial set under `app/views/games/`.

## Spec strategy (specs lead)

Per project rule 1, specs come first in every phase — and the suite carries the
*same* duplication as the code (`spec/models/go_fish/card_spec.rb` ↔
`spec/models/crazy_eights/card_spec.rb` are near-identical). So each extraction
has a matching spec reorganization that **leads** it, not trails it:

- **Reorganize into the right files.** New base specs mirror the new base files
  under `spec/models/games/`: `engine_spec.rb`, `card_spec.rb`, `deck_spec.rb`,
  `player_spec.rb`, `serializable_spec.rb`. There is **no base engine spec
  today** — that gap closes here. The AR `Game` keeps its existing
  `spec/models/game_spec.rb` (Phase 4 extends it, no new file).
- **Shared behavior → shared examples.** Behavior both games must satisfy moves
  into RSpec shared examples under `spec/support/shared_examples/` (already
  auto-required by `rails_helper.rb:32`) — e.g. "a serializable round-trip", "a
  standard 52-card deck", "a game engine contract". Each game's spec
  `it_behaves_like` them.
- **Game specs shrink to the delta.** Once the shared examples exist,
  `go_fish/card_spec.rb` / `crazy_eights/card_spec.rb` assert only what the
  subclass adds (`value` vs. `wild?`), not the inherited behavior.
- **Lead with a shared-example pass.** The first concrete spec work — landing
  with Phase 0/1 — is extracting shared examples from the *current* duplicated
  game specs over the *current* code. This is a pure test refactor (suite stays
  green) that pins the shared contract **before** any code moves, so every later
  extraction is verified the instant it lands.
- **Order within a phase:** relocate/author the spec (base spec + shared
  example) and agree it in `docs/spec-plans.md` → developer review → extract the
  code to green. The spec move is red; the extraction is green.

## Phases

Ordered leaf-first: primitives → aggregates → engine → persistence glue →
request layer. Each phase is spec-led per the strategy above. Risk rises with
phase number; the "easier to add a game" payoff concentrates in Phases 3–4.

### Phase 0 — Introduce the `games/` namespace + rename the engine (mechanical, no behavior change)
- **Goal:** Create the `app/models/games/` folder, move the base
  `game_implementation.rb` → `games/engine.rb`, and rename the engine class
  family `Implementation` → `Engine` (`GameImplementation` → `Games::Engine`,
  `GoFish::Implementation` → `GoFish::Engine`, `CrazyEights::Implementation` →
  `CrazyEights::Engine`). `Implementation` named *that it is an implementation*;
  `Engine` names what it does — holds the pieces and runs the game. The two game
  folders keep their `GoFish::` / `CrazyEights::` names.
- **Blast radius:** ~10 files / ~23 references (the engine files, the `serialize`
  coder line in both STI game classes, and the specs). `implementation_key`
  stays — it's the view-partial dispatch string, not the class. Later phases add
  sibling base files (`games/serializable.rb`, `games/card.rb`, …) here.
- **Depends on:** nothing. **Risk:** very low — pure move + rename, suite stays
  green with no spec logic changes.

### Phase 1 — Serialization contract + card primitives
- **Goal:** Introduce a `Serializable` concern where a declared attribute list
  drives *both* `as_json` and `from_json`, so they can't drift. Prove it on the
  simplest POROs while extracting a shared `Card` and `Deck` base (thin
  subclasses keep only `value` / `wild?` and the card class the deck builds).
- **Absorbs:** `Card`/`Deck` ~90% duplication; the root cause of the
  `game_state`-loses-data-on-reload bug (`dump` = all ivars vs. hand-written
  `from_json`).
- **Depends on:** nothing. **Risk:** low — pure POROs, no request path.
- **TDD entry:** serialization round-trip specs (`as_json` → `from_json` yields
  an equal object) for `Card`/`Deck`.
- **Deck specifics (from the spike):** `Games::Deck` holds the whole class —
  `cards`, `shuffle`, `top_card`, `empty?`, `cards_left`, and the 52-card build.
  The build needs to know which card class to instantiate, so the base exposes a
  `self.card_class` hook (`NotImplementedError`) and each subclass overrides it
  (`GoFish::Deck.card_class = GoFish::Card`). **Decided:** a subclass names its
  card class twice — once as `card_class`, once in `nested_many :cards,
  GoFish::Card` — and this redundancy is accepted rather than derived from one
  another, matching the spike.

**Why a concern, not per-field patches.** All eleven serialized POROs use the
same drift-prone mechanism: save is automatic (`dump` = `as_json` = every ivar),
load is hand-written. Only two currently disagree (`GoFish::Player#name`,
`CrazyEights::TurnResult#wild`) — the other nine are correct by vigilance, not by
construction, so every future field is one forgotten line from silent data loss.
The concern makes save and load derive from **one declared field list**, so they
can't disagree:

```ruby
module Games
  module Serializable
    extend ActiveSupport::Concern

    included do
      class_attribute :scalar_attrs, default: []
      class_attribute :nested_attrs, default: {}   # name => { class:, collection: }
    end

    class_methods do
      def scalar(*names) = self.scalar_attrs += names
      def nested_one(name, klass)  = register_nested(name, klass, false)
      def nested_many(name, klass) = register_nested(name, klass, true)

      def from_json(json)
        new(**scalar_values(json), **nested_values(json))
      end
      # scalar_values / nested_values / load_nested elided — see the spike.
    end

    def as_json(*)
      scalar_attrs.index_with { |name| send(name) }
        .merge(nested_attrs.to_h { |name, cfg| [ name, dump_nested(send(name), cfg) ] })
        .stringify_keys
    end
  end
end

# usage
module Games
  class Card
    include Games::Serializable
    scalar :rank, :suit
  end
end

module GoFish
  class Player < Games::Player
    scalar :cant_play                     # adds to inherited :user_id, :name
    nested_many :hand, GoFish::Card       # collection
    nested_many :books, GoFish::Book
  end
end
```

Inherits cleanly for the subclassing in later phases (`CrazyEights::Card < Games::Card`
keeps `scalar :rank, :suit`, adds `wild?`). Three consequences to plan for,
**all confirmed by the spike**:
(1) PORO initializers standardize on keyword args matching the declared names, so
`new(**values)` works — a mechanical change to `Card#initialize` and friends
(and it ripples into `Deck`'s card build, which now uses `Card.new(rank:, suit:)`);
(2) nested types need **two** declarations, not one — `nested_one` for a single
nested PORO (`deck`, `drew_card`, `played_card`) and `nested_many` for a
collection (`hand`, `books`, `players`, `turn_results`, `discard_pile`). The
original single-`nested` sketch couldn't tell an object from an array. These
replace the hand-written `.map { Card.from_json … }` loops;
(3) the dead `data` methods on `Card`/`TurnResult` are removed by this phase, not kept.

### Phase 2 — Shared in-memory player base
- **Goal:** Extract the base player (`user_id`, `name`, `hand`, `hand_size`,
  serialization) onto the Phase 1 contract; Go Fish keeps `books` / `cant_play`
  / book logic, Crazy Eights adds nothing.
- **Absorbs:** the `GoFish::Player#name` drop-on-reload bug; the inconsistent
  `user_id` default (`user_id: user_id` self-reference vs. `0`) — pick one.
- **Depends on:** Phase 1 (uses the concern). **Risk:** low–medium.
- **TDD entry:** round-trip specs incl. `name`; existing player specs stay green.

### Phase 3 — `Games::Engine` base + enforced contract
- **Goal:** Pull the shared engine queries up (`active_player`,
  `active_player?`, `player`, `opponents`, `number_of_players`, `deal`,
  `turn_result`), template-method the `from_json` players/deck decode, and add
  `NotImplementedError` stubs for the real contract (`start`, `play_turn`,
  `advance_turn`, `winner`, `board_for`) so a new game fills in a documented
  interface instead of reverse-engineering two examples.
- **Absorbs:** "massive copy-paste between engines"; the base engine
  (`Games::Engine`) not being an enforced contract.
- **Depends on:** Phases 1–2 (players/deck already shared). **Risk:** medium —
  the engine is the heart of the rules; lean on existing model specs. Keep
  `advance_turn` / `winner` / `play_turn` / `STARTING_HAND` per game.
- **TDD entry:** contract specs asserting the base raises `NotImplementedError`;
  shared-query specs.
- **Boundary settled by the spike.** The split is: *up* → the queries
  (`active_player`, `active_player?`, `player`, `opponents`, `number_of_players`,
  `turn_result`), `deal`, and serialization; *per-game* → `start`, `board_for`,
  `play_turn`, `winner`, `advance_turn`. Notably `start` and `board_for` stay
  **fully per-game — not template methods**: both share a skeleton, but the
  game-specific tail (CE seeds a discard pile; the `board_for` args differ) isn't
  worth the hook indirection. The base also needs a `self.deck_class` hook for
  the default deck. A subclass that adds state (CE's `discard_pile`) does so with
  a `nested_many` declaration plus an `initialize(discard_pile: [], **rest);
  super(**rest)` override — the pattern a third game would follow.

### Phase 4 — STI game-class template
- **Goal:** Collapse the near-identical `start_if_full!` /
  `update_with_starting_game_state` into `Game`, driven by class-level
  `engine_class` / `player_class`. Subclasses shrink to `serialize` + those two
  declarations.
- **Absorbs:** the STI `start_if_full!` duplication.
- **Depends on:** Phase 3. **Risk:** medium — touches game start-up and `save!`.
- **TDD entry:** `Game` spec that a full game builds and starts its state via
  the declared classes.

### Phase 5 — Shared `Turn` form-object base
- **Goal:** Extract `Games::Turn` (ActiveModel) holding `game`, `game_state`,
  `game_is_active`, `user_is_active_player`; `Turn` / `CrazyEightsTurn` subclass
  and add only game-specific validations. Fold `@game ||=` into a getter/setter.
- **Absorbs:** `Turn`/`CrazyEightsTurn` copy-paste; the **rule-3 violation** in
  the shared `game` memoizer.
- **Depends on:** none strictly, but do after Phase 3 so `game_state` surface is
  stable. **Risk:** medium — request-path validation; covered by system specs
  today, so this phase is a good motivator for the request-spec layer
  (see roadmap Testing).
- **TDD entry:** turn-validation specs at the model boundary.
- **Rule-3 memoization: resolved — accessor-memo.** `@game ||=` is replaced
  with `attr_accessor :game_record` plus `self.game_record ||= Game.find_by(...)`
  in `Games::Turn#game`, matching the spike. Decided over dropping memoization
  and looking the game up on every validation call.

### Phase 6 — Finish delegating engine calls through `Game`
- **Goal:** Add `Game#advance_turn` and `Game#board_for` delegators so the web
  layer stops reaching two levels deep into `game_state`
  (`turns_controller.rb`, `games_controller.rb`).
- **Absorbs:** the "finish delegating engine calls through `Game`" item.
- **Depends on:** Phase 3. **Risk:** low.
- **TDD entry:** `Game` delegator specs.

## Cross-cutting bugs this plan resolves as a side effect

| Bug (from roadmap) | Resolved by |
| --- | --- |
| `game_state` silently loses data on reload | Phase 1 (serialization contract) |
| `GoFish::Player#name` dropped on reload | Phase 1–2 |
| `CrazyEights::TurnResult#wild` dropped on reload | Phase 1 contract, applied to `TurnResult` |
| `Player#initialize` `user_id: user_id` self-reference | Phase 2 |
| `Turn` base `@game ||=` rule-3 violation | Phase 5 |

Note: `TurnResult` (Go Fish vs. Crazy Eights) diverges enough in fields that it
is **not** slated for a shared base — only the serialization concern (Phase 1)
applies to it. Don't force symmetry there.
