# BRAVE Breakdown: Implement Rummy

Whole-feature breakdown for adding **Rummy** as the third game. Rules:
`docs/rummy.md`. Design decisions and their rationale: `docs/rummy-decisions.md`
(D1–D5). Prerequisite platform changes: `docs/pre-rummy-architecture.md`.

## Brainstorm

Rummy is a materially more complex game than Go Fish or Crazy Eights, in three
ways that shape the whole build:

- **Multi-step turns.** A turn is draw → (optional) create meld / lay off, any
  number of times → discard. Modeled as one POST per action (D1), so the engine
  must carry serialized *turn-phase state* — whose turn, and which phase — that
  survives each reload (D5).
- **Communal melds.** Groups and runs live on the table, owned by no player, and
  anyone may lay off onto any of them. A `Rummy::Meld` PORO owns the rules for
  what is a valid meld and what may be added (D2).
- **The break-in rule.** A player may not lay off until they have laid down their
  own meld — tracked by a `has_melded` flag on the player, not by meld ownership
  (D3). This rule was missing from the rules doc and has been added.

Scope boundary: the first Rummy is a **single hand** — winner is the first player
to empty their hand. Multi-hand pip scoring and the rummy bonus are the one
deferred rule (D4); a single hand is fully rules-correct on its own.

Edge cases in scope: drawing from stock vs. discard; not discarding the card just
taken from the discard pile on the same turn; extending runs at either end;
adding a fourth to a group; going out without a final discard; **stock
exhaustion** (flip the discard pile into a new stock *without shuffling*).

## Approach

Follow the existing per-game pattern exactly — STI subclass + `Engine`
fulfilling the `Games::Engine` contract, POROs mixing in `Games::Serializable`,
a form object subclassing `Games::Turn`, a `GameBoard` + implementation partial.
Nothing here needs a new paradigm; Crazy Eights is the closest template (draw /
discard / multi-POST turn via the unified advance signal).

**Reuse:** `Games::Serializable` (melds/discard/turn-state all serialize for
free), `Games::Deck`/`Card` bases, the STI `engine_class`/`player_class`/
`turn_class` hooks, `broadcast_refresh_later_to` for real-time board updates, and
the shared winner-modal / feed partials.

**Depends on** the pre-Rummy branch (Phases 1–3): the unified turn-advance
predicate (Phase 1) is what lets draw/meld/lay-off keep the turn open while
discard advances it; the Game-level turn dispatch (Phase 2) is where
`RummyGame#turn_class` plugs in.

**Initial spike:** the `Rummy::Meld` rules (group?/run?/valid?/accepts?) and
`Rummy::Card` sequence ordering — they're pure, high-value, and de-risk the
trickiest correctness area first.

**Mid-way check we're on track:** the engine can play a full turn loop end to end
in a model spec (deal → draw → meld → lay off → discard → advance → win) before
any UI exists.

**Error / recovery states:** invalid actions (out-of-phase, illegal meld,
lay-off before breaking in, discarding the just-drawn upcard) fail form-object
validation and drop silently with a redirect back — same as the other games.

## Value

Rummy is the confirmed third game (`PRODUCT.md`). Beyond shipping a game, it's the
real test of the platform's design goal: proving the shared abstraction extends
to a game with table-owned state and multi-step turns without special-casing the
shared controllers/views. Players get a complete, real-time multiplayer Rummy in
the lobby alongside the other two. Given the deadline, optimize for **speed and
rules-correctness**; the project's TDD/quality rules still hold.

## Estimate

**Large — 16 points (~2 days), leaning X-Large.** The engine is well-patterned,
but two things push uncertainty up: the new per-turn phase state (a pattern
neither existing game has) and the meld-building UI (richer than any current
view). Under a hard one-day deadline this is a compressed Large; the standard 15%
review/pairing buffer is moot against a fixed date — instead pair on the two
uncertain areas below.

**Top risks (likelihood / severity):**
- **Meld-building UI within Optics + minimal JS, on deadline — High / High.** The
  biggest schedule risk. Mitigate: build against the `docs/rummy-concepting/
  optics/` meld-in-progress mock, keep JS minimal, start it early, treat it as
  the item most likely to compress.
- **Ace-low run ordering — Medium / High.** The shared `Card::RANKS` is
  `2 … K A`, but runs need ace *low* (`A 2 3 … K`). `Rummy::Card` must own its own
  sequence order; a wrong ordering is a silent rules violation. Mitigate: spec
  runs at both ends, including `A 2 3`, and reject wrap-around (`K A 2`).
- **Per-turn phase state serialize + reset — Medium / Medium.** New pattern, drift
  risk. Mitigate: `Serializable` fields + explicit reset on `advance_turn`, and a
  system spec that plays across the separate POSTs.
- **Break-in + discard-source rules interacting in validation — Medium / Medium.**
  Mitigate: unit-spec the form object per action.

**Incremental fallback (if time runs short):** the plan is already the single-hand
game (D4); the only further cut that stays rules-correct is UI polish, never a
rule.

## Implementation Plan

Prerequisite: land `docs/pre-rummy-architecture.md` Phases 1–3.

Each step is TDD- and spec-plan-gated per project rule 1 (spec file → agreed flow
in `docs/spec-plans.md` → spec → review → production code).

- [ ] `Rummy::Card` + `Rummy::Deck` — ranks/suits, **ace-low sequence ordering**, Serializable
- [ ] `Rummy::Meld` — `group?` / `run?` / `valid?` class predicates + `accepts?(card)` for lay-offs, Serializable
- [ ] `Rummy::Player` — hand + `has_melded` flag, Serializable
- [ ] `Rummy::Engine#start` — deal by player count (constant), form stock + turn the upcard onto the discard
- [ ] `Rummy::Engine` draw — from stock or discard; record the card taken from the discard this turn
- [ ] `Rummy::Engine` create-meld — validate via `Meld`, set `has_melded`
- [ ] `Rummy::Engine` lay-off — break-in gate + `Meld#accepts?`
- [ ] `Rummy::Engine` discard — reject discarding the just-drawn upcard; end the turn
- [ ] `Rummy::Engine` per-turn phase state (D5) + `advance_turn` reset
- [ ] `Rummy::Engine#winner` — first empty hand
- [ ] `Rummy::Engine` stock exhaustion — flip discard into new stock, no shuffle
- [ ] `Rummy::Engine#board_for` + `Rummy::GameBoard`
- [ ] Engine serialization — `nested_many :melds`, `nested_many :discard_pile`, turn-phase state
- [ ] `RummyGame` STI subclass — `serialize` coder, `engine_class`, `player_class`, `turn_class` + permitted params
- [ ] `RummyTurn` form object — per-action validation reading turn phase; card-collection params
- [ ] Controller wiring — through the generic dispatch path (Phase 2)
- [ ] Views — hand, stock count, discard/upcard, communal melds area, draw-source choice, meld-build + lay-off UI (Optics), discard, feed, reuse winner modal
- [ ] System spec — play a full hand to a win (asserts the user story)
