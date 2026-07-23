# Pre-Rummy architecture prep

A small, targeted branch of architecture changes made *before* implementing
Rummy — now that we have the actual rules (`docs/rummy.md`) in hand. The goal is
to tighten a few seams so Rummy slots into the existing abstraction cleanly,
**not** to refactor broadly. Findings came from a Rails-audit pass scoped to a
single question: what in the current structure makes Rummy harder than it needs
to be?

The shared abstraction is already in good shape — `Games::Serializable`,
`Games::Engine`, `Games::Card`/`Deck`, STI + `engine_class`/`player_class` — so
most of Rummy is net-new files. These phases only address the seams where the
current code would force Rummy into a bespoke fourth branch or replicate a
latent bug.

Each phase is TDD-gated (red → green → refactor) like everything else; the
changes are mechanical and driven by the specs already covering the two games.

---

## Phase 1 — Unify the turn-advance signal (done)

Go Fish's `TurnResult` exposes `go_again` (`app/models/go_fish/turn_result.rb`);
Crazy Eights' exposes `play_again` (`app/models/crazy_eights/turn_result.rb`).
Same idea, two names. `TurnsController` carries two near-identical apply methods
that differ *only* in that predicate (`turns_controller.rb:29` vs `:48`).

- Introduce **one** shared predicate name for "this turn action does not advance
  the turn" (e.g. `go_again?`) at the base level both `TurnResult`s share.
- Update both engines, the views that read the flag, and the controller to use it.

**How this benefits Rummy:** Rummy's turn is inherently multi-step — draw →
(optional melds / lay-offs) → discard — so "this action doesn't end my turn" is
the central piece of its control flow. A single shared predicate means the Rummy
engine implements one well-understood interface instead of inventing a third
name, and its turn loop is exercised by the same controller path the other two
games already prove works.

---

## Phase 2 — Push per-game turn dispatch onto the Game model (done)

`TurnsController#create` hardcodes `case game when GoFishGame / CrazyEightsGame`
(`turns_controller.rb:5-8`), with per-game `handle_*` / `apply_*` / `*_params`
methods. Each branch encodes three things that are really *knowledge about a
game*: which form-object class, which params to permit, and the advance
predicate from Phase 1.

- Add `Game#turn_class` (each STI subclass returns its form object) and a
  permitted-turn-keys method, mirroring the existing `engine_class` /
  `player_class` pattern already on the subclasses.
- Collapse `TurnsController#create` to a single generic path.

**How this benefits Rummy:** Rummy contributes a form object plus two tiny
methods on `RummyGame` instead of a fourth clump in an ever-growing controller
`case`. There's less to touch, less risk, and all three games flow through one
shared, tested code path — so Rummy's turn handling is correct by construction
rather than by copy.

---

## Phase 3 — Standardize `user_id` identity comparison

The base `Games::Engine#player` / `active_player?` compare `it.user_id ==
user_id` with no coercion (`app/models/games/engine.rb:22-23`), but every engine
and form object compares with `.to_s ==` (e.g. `crazy_eights/engine.rb:38`,
`turn.rb:20`). The convention is inconsistent and only works today because of
how ids happen to arrive.

- Pick one identity convention (coerce once at the boundary, then compare
  consistently) and apply it across `Games::Engine`, the subclass engines, and
  the turn form objects.

**How this benefits Rummy:** Rummy performs constant player lookups — laying off
onto opponents' melds means resolving "whose meld is this" and "whose turn" all
over the engine. Settling on one identity convention now kills a latent
type-mismatch bug class before it multiplies across every new lookup site Rummy
adds.

---

## Scope decisions (deliberately *not* in this branch)

- **Scoring is descoped from the first Rummy.** `declare_winner_if_over!` records
  only a boolean `winner` on the persisted `Player`; Rummy's pip scoring + rummy
  bonus (opponents pay double) needs a numeric score concept that has no home
  today (no column, no PORO). The winner-by-going-out half fits the existing
  `winner` seam perfectly. First Rummy ships **"first to empty their hand
  wins,"** matching the single-hand model of the other two games; scoring is a
  separate later feature.
- **`board_for` boilerplate is left alone.** Each engine rebuilds a bespoke
  `GameBoard` with the same shared fields; Rummy will add a third. The
  consolidation win is small and the keyword-arg constructors are rigid, so it's
  not worth the churn on a lightweight branch.

---

## Next step

After this branch lands, the next piece of work is **implementing Rummy itself**
— the confirmed third game (rules in `docs/rummy.md`). Implementation notes for
that work live in `docs/roadmap.md`.
