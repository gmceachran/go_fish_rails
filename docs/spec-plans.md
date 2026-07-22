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

### Phase 0 — `Implementation` → `Engine` rename (dedup-plan Phase 0)

**Not a normal spec plan.** This phase changes no behavior and adds no public
methods, so there are **no new Given/When/Then examples**. The "spec work" is a
reference sweep: rename the two per-game engine spec files and update every
`Implementation` constant reference to `Engine`. Red-first still holds — the
spec renames reference `Games::Engine` / `GoFish::Engine` / `CrazyEights::Engine`
before those constants exist (red); the production rename makes them exist
(green). No shared examples or base engine spec yet — those land in Phases 1/3.

**Spec sweep (leads, goes red):**

- Rename `spec/models/go_fish/implementation_spec.rb` →
  `spec/models/go_fish/engine_spec.rb`; `GoFish::Implementation` →
  `GoFish::Engine` (lines 3, 32, 37, 45, 52). Assertions unchanged.
- Rename `spec/models/crazy_eights/implementation_spec.rb` →
  `spec/models/crazy_eights/engine_spec.rb`; `CrazyEights::Implementation` →
  `CrazyEights::Engine` (lines 3, 31, 36, 45, 52). Assertions unchanged.
- `spec/models/game_spec.rb:63` — `GoFish::Implementation` → `GoFish::Engine`.
- `spec/models/crazy_eights_game_spec.rb:17,27` — `CrazyEights::Implementation`
  → `CrazyEights::Engine`.
- `spec/systems/game_creation_spec.rb:61` — `CrazyEights::Implementation` →
  `CrazyEights::Engine`.

**Production rename (follows, makes it green):**

- Create `app/models/games/engine.rb` — **hand-written** pure rename of
  `GameImplementation` to `Games::Engine` (`players` accessor, `initialize`,
  `self.load`, `self.dump`, `implementation_key` `NotImplementedError` stub,
  `opponent_partial`). Do **not** lift the stash's `games/engine.rb` — that's the
  Phase-3 extracted engine.
- Delete `app/models/game_implementation.rb`.
- Rename `app/models/go_fish/implementation.rb` → `go_fish/engine.rb`;
  `GoFish::Implementation < ::GameImplementation` → `GoFish::Engine <
  Games::Engine`; internal `Implementation.new` → `Engine.new` (line 37).
- Rename `app/models/crazy_eights/implementation.rb` → `crazy_eights/engine.rb`;
  same class-line change; internal `Implementation.new` → `Engine.new` (line 42).
- `app/models/go_fish_game.rb` lines 2 & 12 — `GoFish::Implementation` →
  `GoFish::Engine`.
- `app/models/crazy_eights_game.rb` lines 2 & 12 — `CrazyEights::Implementation`
  → `CrazyEights::Engine`.

**Unchanged** (view-partial dispatch string, not the class): `implementation_key`
methods, the `implementation:` board key, and `render
"games/implementations/#{...}"` in `show.html.slim`.

**Green verification:** full suite green after the rename; the per-phase
comment-out dance is trivial here (a rename can't be coincidentally green).
