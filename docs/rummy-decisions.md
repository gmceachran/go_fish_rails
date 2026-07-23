# Rummy — architecture decisions

A running log of the design decisions behind the Rummy implementation, and *why*
we made them. This is the source of truth for "why is Rummy built this way."
Rules live in `docs/rummy.md`; the pre-Rummy prep branch lives in
`docs/pre-rummy-architecture.md`.

Each entry: context → decision → why → implications. Decisions are dated and can
be superseded (note it explicitly, no silent reversals).

---

## D1 — A turn is multiple POSTs, one per action (2026-07-23)

**Context.** A Rummy turn is ordered: draw → (optional) create meld / lay off,
any number of times → discard (which ends the turn, unless going out). We had to
choose between one atomic POST carrying the whole turn vs. a POST per action.

**Decision.** One POST per action (`draw`, `meld`, `lay_off`, `discard`), each
validated and persisted independently, each re-rendering the board.

**Why.** It's the app's existing grain — Crazy Eights already models a turn as
separate POSTs, with `play_again` keeping the turn from advancing. Each action
becomes a small, independently-testable form object + engine method (fits the
7-line rule and TDD). The `broadcast_refresh_later_to` machinery gives free
incremental feedback. The alternative (one POST) forces a heavy client-side
turn-composer in JS, cutting against the "minimal JS / Optics-only" constraint.

**Implications.**
- Leans directly on `pre-rummy-architecture.md` Phase 1 (unified turn-advance
  signal): draw / meld / lay_off set `go_again`; only `discard` (or going out)
  advances the turn.
- Introduces a small **per-turn phase state** that must live in `game_state`
  (survives across POSTs, since each POST reloads state): at minimum "has the
  active player drawn yet this turn?" and "which card (if any) came from the
  discard pile this turn?" (may not be discarded back the same turn).

---

## D2 — Melds are communal, held on the engine, and own their own rules (2026-07-23)

**Context.** A meld (group or run) sits on the table and can be extended by any
player via lay-off. We chose between engine-owned (a shared array) vs.
player-owned (like Go Fish books).

**Decision.** `Rummy::Meld` is a PORO stored `nested_many :melds` on the engine —
communal table state, no owner reference. The Meld owns the knowledge of what a
valid meld is: class predicates that take cards (`group?`, `run?`, `valid?`) and
an instance check for lay-offs (`accepts?`/`can_add?`).

**Why.** The moment any player can extend any meld, it stops being "a player's" —
storing it on the engine matches its real ownership. The Book pattern misleads
here: a book is *locked and never touched again*, whereas a meld is mutable and
grows with cards from multiple players, so a player-owned meld's ownership
dissolves the instant an opponent lays off onto it. Putting the meld rules on the
Meld keeps one authority for both form-object validation and engine logic
(DRY-about-ideas), matching how `Games::Card` and `GoFish::Book` already work.

**Implications.**
- Rendering reads a shared `engine.melds` array, not per-player collections.
- Turn params must carry a *collection* of cards (a meld is N cards), unlike the
  single-card params of Go Fish / Crazy Eights.

---

## D3 — The "break-in" rule is enforced via a per-player flag, not meld ownership (2026-07-23)

**Context.** Per instructor, this implementation includes the rule: a player may
not lay off onto any meld until they have laid down at least one meld of their
own ("breaking in"). This rule was missing from `docs/rummy.md` (now added).

**Decision.** Track "has this player melded yet?" as a `has_melded` boolean on the
`Rummy::Player` PORO (set true when they create their first meld). Gate lay-offs
on it. Do **not** make melds player-owned.

**Why.** The rule is a fact about the player's history, not about which meld
belongs to whom — a boolean answers it directly. This preserves D2 (communal
melds) while satisfying the rule, and the same flag would later power the
rummy-bonus check if scoring returns.

---

## D4 (scope) — Scoring is descoped from the first Rummy (2026-07-23)

**Context.** `docs/rummy.md` describes pip scoring and a rummy bonus (opponents
pay double). The persisted layer only records a boolean `winner` on `Player`.

**Decision.** First Rummy ships **"first to empty their hand wins,"** matching the
single-hand model of the other two games. No pip scoring, no rummy bonus.

**Why.** The winner-by-going-out half fits the existing `winner` /
`declare_winner_if_over!` seam perfectly; scoring needs a numeric score concept
with no home today (no column, no PORO) and is a separate later feature. Keeps
the first Rummy branch light.

---

## D5 — Per-turn phase state is serialized on the engine (2026-07-23)

**Context.** D1 (multi-POST turns) means each action reloads `game_state` from
the JSONB blob, so the engine must be able to resume a turn mid-flight after a
reload.

**Decision.** The engine carries serialized turn-progress state answering two
questions: (1) whose turn is it, and (2) what phase of that turn are they in
(e.g. awaiting-draw vs. draw-done/melding vs. awaiting-discard). On load, the
game knows exactly which action is next.

**Why.** The information can't be request-local — it has to survive between the
separate POSTs of a single turn. Reconstructing it from the `turn_results` feed
would be fragile; making it explicit engine state is simpler and authoritative.

**Implications.** Reset this state on `advance_turn`. The turn form object reads
it to validate action ordering ("must draw before melding," "must discard to
end"). Exact shape (sub-object vs. fields, phase enum) is left to implementation.

---

## Deferred / open

- **Meld-building UI.** Deferred — the multi-POST contract (D1) decouples the UI
  from the engine, so the client can assemble the card list any way. Reference
  for when we build it: `docs/rummy-concepting/optics/` (meld-in-progress mock).
- **Stock exhaustion.** Rule is defined in `docs/rummy.md` (flip the discard pile
  to form a new stock *without shuffling*); implementation approach not yet
  decided.
