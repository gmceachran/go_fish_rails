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

_None — Card 1's `#winner` plan is merged and green (pruned per the "keep this
doc lean" note above). Card 2's plan goes here when it's picked up._
