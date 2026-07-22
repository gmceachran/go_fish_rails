# Dedup execution strategy (temporary)

**Delete this file when the dedup refactor lands.** It captures the *how* of
executing `docs/dedup-plan.md` across the next several commits — the spike, the
stash, the per-commit loop, and the decisions already made. `dedup-plan.md`
stays the durable strategy; this is throwaway scaffolding for the in-flight work.

## Where we are

A **full end-to-end spike** of every phase (0–6) was built directly in
`app/models/` and verified: it eager-loads, round-trips through serialization,
and both target bugs are fixed by construction (`GoFish::Player#name` and
`CrazyEights::TurnResult#wild` now survive reload). The spike is **not committed**
— it's deliberately red against the current specs (they still reference
`GoFish::Implementation`, call the removed `data` methods, etc.), and we don't
commit on red.

The spike is the **destination reference**. We now rebuild it green, **one phase
= one commit**, in dependency order, lifting code back out of the spike as each
phase's implementation step.

## The spike lives in a stash

Scoped to `app/models` only (so docs and anything else stay put):

```sh
git stash push -u -- app/models        # how it was stashed
git stash list                         # find it by message: "dedup full spike (reference)"
```

Pull one file out of the stash without un-stashing everything:

```sh
git checkout stash@{0} -- app/models/games/card.rb   # lift a single file
git show 'stash@{0}:app/models/games/deck.rb'        # or just view it
```

> Reference the stash **by its message**, not a fixed `stash@{0}` — the index
> shifts if other stashes get pushed. `git stash list | grep 'dedup full spike'`.

## The per-commit loop (per phase)

Each phase follows project rule 1 (gated TDD) **and** the red-green verification
dance the developer wants:

1. **Reorganize the specs first** (they lead the code — see `dedup-plan.md`
   "Spec strategy"). New base specs under `spec/models/games/`; shared behavior
   into `spec/support/shared_examples/`; game specs shrink to the delta.
   **Read the stash as reference while doing this** (`git show
   'stash@{0}:app/models/...'` — don't apply it) to see the destination shape
   and make correct calls on where behavior belongs. This doesn't weaken the
   red/green proof in step 4 below, which re-verifies against the actual
   working tree regardless of what was consulted here.
2. Write the logical flow in `docs/spec-plans.md`, **agree it with the developer**,
   then write the spec. Developer reviews the spec.
3. Lift the implementation for this phase out of the stash (see file map below).
4. **Verify each green is real:** comment out the new implementation → run the
   spec → confirm it fails **for the right reason** → uncomment → confirm it
   passes. This proves the test drives the code, not coincidence.
5. Commit — green. Move to the next phase.

## Commit order = phase order (dependency-driven)

`0 → 1 → 2 → 3 → 4 → 5 → 6`. This is not arbitrary: the engine (Phase 3) is a
subclass of `Games::Engine`, includes `Games::Serializable` (Phase 1), and
declares `nested_many :players, GoFish::Player` where `GoFish::Player <
Games::Player` (Phase 2). So the engine **cannot** go first — primitives and
player must land before it. **Phase 0 (the pure `Implementation → Engine`
rename) is the one standalone-first commit** — green on its own with just a
spec-name sweep.

## File → phase map (what to lift, and when)

| Phase | Files (end state in the stash) |
| --- | --- |
| 0 rename | `games/engine.rb` (**rename only — see caveat**), `go_fish/engine.rb` + `crazy_eights/engine.rb` (renamed from `implementation.rb`), `serialize` coder line in both STI game classes, delete `game_implementation.rb` |
| 1 serialize + cards | `games/serializable.rb`, `games/card.rb`, `games/deck.rb`, `go_fish/card.rb`, `crazy_eights/card.rb`, `go_fish/deck.rb`, `crazy_eights/deck.rb`, + apply the concern to `go_fish/turn_result.rb` & `crazy_eights/turn_result.rb` |
| 2 player | `games/player.rb`, `go_fish/player.rb`, `crazy_eights/player.rb` |
| 3 engine | `games/engine.rb` (queries pulled up + contract), `go_fish/engine.rb` & `crazy_eights/engine.rb` (trimmed to rules) |
| 4 STI template | `game.rb` (`start_if_full!` + `update_with_starting_game_state`), `go_fish_game.rb`, `crazy_eights_game.rb` |
| 5 turn base | `games/turn.rb`, `turn.rb`, `crazy_eights_turn.rb` |
| 6 delegators | `game.rb` (`advance_turn` / `board_for` delegators) + `turns_controller.rb` / `games_controller.rb` |

**Two caveats — the spike collapsed phases, so its files are END STATE:**
- **`games/engine.rb`**: the stash version is the Phase-3 *extracted* engine
  (all the shared queries). Phase 0's `games/engine.rb` must be **hand-written as
  a pure rename** of the old `GameImplementation` (just `players`, `load`/`dump`,
  `implementation_key` stub, `opponent_partial`). Don't lift the stash version at
  Phase 0.
- **`game.rb`**: the stash version bundles the Phase-4 template *and* the Phase-6
  delegators. At Phase 4, take only `start_if_full!` / `update_with_starting_game_state`;
  leave `advance_turn` / `board_for` for Phase 6.

Everything else (Card, Deck, Player, TurnResult, STI subclasses, Turn form
objects) reaches end state in a single phase and can be lifted from the stash
directly.

## Decisions already made this session (don't re-litigate)

- **`Games::` namespace, not `app/models/concerns/`.** The serialization concern
  is `Games::Serializable` under `app/models/games/`, colocated with the POROs it
  serves. It's a PORO mixin (not an ActiveRecord concern) and only ever used
  in-game, so it's namespaced under `Games` rather than polluting the global
  namespace from the concerns root. Confirmed keep.
- **`scalar` vs `nested_one`/`nested_many`.** Scalars are JSON-native primitives
  (`rank`, `user_id`, `wild`); nested are POROs needing rebuild. One declared
  field list drives both `as_json` and `from_json` so they can't drift — this is
  the whole point (kills the drop-on-reload bug class). Needs **two** nested
  forms: single object vs. collection.
- **Serialization changes nothing in memory.** The declarations are metadata for
  read/write; the object graph and ivars are unchanged after load.
- **Engine boundary** (see `dedup-plan.md` Phase 3): queries + `deal` +
  serialization move up; `start`, `board_for`, `play_turn`, `winner`,
  `advance_turn` stay per-game. `start`/`board_for` are deliberately *not*
  template methods.

## Open questions to resolve during implementation

- **Deck card-class redundancy** (Phase 1): subclass names its card class twice
  (`card_class` + `nested_many :cards`). Derive one from the other, or accept it.
- **Turn rule-3 memoization** (Phase 5): accessor-memo (`game_record`) vs. drop
  the memo and look up each call. See `dedup-plan.md` Phase 5.

## Pointers (read these before starting)

- `AGENTS.md` — auto-loaded every session; project rules (esp. rule 1, the gated
  TDD flow), the architecture big-picture, and the serialization trap this
  refactor fixes.
- `docs/architecture.md` — models, STI, JSONB serialization, turn/broadcast flow.
  Read this to understand the *current* code you're refactoring.
- `docs/dedup-plan.md` — the durable strategy, target architecture, and phase
  definitions (with the spike's refinements folded in).
- `docs/spec-plans.md` — where each phase's spec logic is agreed before writing.
- The spike itself — the destination code, in `stash@{0}` (see "The spike lives
  in a stash" above). Read it alongside `dedup-plan.md` to see the end state.
