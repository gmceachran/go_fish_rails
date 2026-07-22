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

### dedup-plan Phase 2 — shared in-memory `Games::Player` base

Same shape as Phase 1: a **new base spec** under `spec/models/games/`, the
existing `"a serializable round-trip"` shared example reused, and the two game
specs **shrink to their delta**. Two decisions baked in from the plan/stash:
`user_id` default → `nil` (kills the `user_id: user_id` self-reference), and no
new shared example (shared player behavior is inherited from `Games::Player` and
tested once in the base spec; the deltas genuinely differ).

#### `spec/models/games/player_spec.rb` (NEW) — `Games::Player` base

Closes the gap: there is no base player spec today.

- **"#hand_size returns the number of cards in the hand"**
  - Given: `Games::Player.new(user_id: 1, name: "Ana", hand: [ two Games::Cards ])`
  - When: `player.hand_size`
  - Then: `eq 2`
- **".from_json preserves user_id and name through a dump/load"** — the direct
  bug-fix pin. The round-trip example below compares `as_json` before/after, so an
  *undeclared* field is absent from both sides and passes anyway; it can't catch
  `name`/`user_id` being dropped. This asserts concrete values, so removing
  `scalar :user_id, :name` fails it.
  - Given: `Games::Player.new(user_id: 7, name: "Ana")`
  - When: `Games::Player.from_json(player.as_json)`
  - Then: `restored.user_id eq 7`, `restored.name eq "Ana"`
- **`it_behaves_like "a serializable round-trip"`**
  - subject: `Games::Player.new(user_id: 1, name: "Ana")` — **empty hand on
    purpose.** The base declares only `scalar :user_id, :name`; `hand`'s nested
    declaration lives in each subclass because the card class varies. So the base
    round-trip pins `user_id`/`name` survival; hand survival is a subclass concern.

(No attr-reading test — rule "don't test initializer state." No
`NotImplementedError` contract — the base player is fully concrete.)

#### `spec/models/go_fish/player_spec.rb` — delta only

Drop `#hand_size` (→ base) and both generic `#from_json` examples (field survival
→ round-trip).

- **`it_behaves_like "a serializable round-trip"`**
  - subject: `GoFish::Player.new(user_id: 1, name: "Ana", hand: [ one GoFish::Card ], books: [ GoFish::Book.new("4") ], cant_play: true)`
  - Bug-fix pin: `name`, `hand`, `books`, and `cant_play` all survive reload in
    one assertion.
- **"rebuilds books as GoFish::Book objects"** (the one type-reconstruction
  assertion round-trip's `as_json`-equality can't make)
  - Given: json with a `books` entry
  - When: `GoFish::Player.from_json(json)`
  - Then: `books.first` is a `GoFish::Book` with the right rank
- **`#cards_of_rank_given`** — both contexts, unchanged (Go Fish rule).
- **`#create_book_if_possible`** — both contexts, unchanged (Go Fish rule).

#### `spec/models/crazy_eights/player_spec.rb` — delta only

CE adds nothing but the hand's card type, so its spec collapses to two examples.

- **`it_behaves_like "a serializable round-trip"`**
  - subject: `CrazyEights::Player.new(user_id: 2, name: "Player Two", hand: [ one CrazyEights::Card ])`
- **"rebuilds hand as CrazyEights::Card objects"**
  - Given: json with a `hand` entry
  - When: `CrazyEights::Player.from_json(json)`
  - Then: `hand` equals `[ CrazyEights::Card.new(...) ]`
