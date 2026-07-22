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

_None currently active._ Phase 1 (serialization contract + card primitives) is
implemented and green (pending commit), so its plan was pruned per the "keep this
doc lean" note above. Next up is dedup-plan Phase 2 (shared in-memory `Player` base).
