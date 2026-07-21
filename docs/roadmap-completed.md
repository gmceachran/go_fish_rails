# Roadmap — completed work

Companion to `docs/roadmap.md`. That file tracks what's outstanding; this one
is the record of what started there and is now resolved, with what the fix
actually was — useful when a future item rhymes with one of these.

## Suite hang — Crazy Eights opening discard infinite loop

**Was:** `CrazyEights::Implementation#flip_non_wild_discard` `unshift`d a wild
opening card back onto the *front* of the deck and immediately re-drew the same
card, so when the post-deal top card was an 8 the `while` loop never
terminated (~8% of Crazy-Eights game starts). This was the cause of the
intermittent system-suite freeze, and the reason `sleep`s were sprinkled into
the Crazy Eights model specs. Full investigation in `docs/spec-reliability.md`.

**Fix:** not the originally-proposed "move the wild card to the bottom of the
deck" patch. Instead, `flip_non_wild_discard` was deleted outright and
`start_discard_pile` now just takes `deck.top_card` directly — an opening
discard being non-wild was never an actual Crazy Eights rule (see
`docs/crazy-eights.md`), so the simplest correct fix was to stop enforcing a
constraint the game doesn't have, rather than keep the skip logic and patch its
bug. The model spec asserting "places a non-eight card on the discard pile" was
removed along with it, since it was asserting a rule that doesn't exist. The full
suite now runs green over repeated back-to-back runs (~6s, 0 failures),
confirming the hang is gone.

## Crazy Eights end-of-game detection (Card 1)

**Was:** `CrazyEights::Implementation#winner` was hardcoded to `false`, so the
engine never detected a finished game. `TurnsController#declare_crazy_eights_winner`
already mapped `#winner` → persisted `Player` → `declare_winner!`, but was dead
because the return was always falsey — so a Crazy Eights game never ended.

**Fix:** `#winner` now returns the player whose hand is empty (`nil` otherwise),
guarded by `return nil if discard_pile.empty?` — the discard pile is the "started"
signal (`start` seeds it and it only grows), so an all-empty-hands *pre-deal* game
doesn't falsely name player 1. Reviving the return value revived the existing
controller path, so **Crazy Eights now declares a winner and ends.** Unit-tested
by `#winner` examples in `spec/models/crazy_eights/implementation_spec.rb`. Note:
the end-to-end CE finish is still not covered by a test (the `# it "the turn ends"`
system example remains commented out). The shared/refactored declaration path and
the Go Fish half stay open as Card 2 (`docs/cards.md`).

## `sleep`s removed from Crazy Eights model specs

**Was:** `crazy_eights_game_spec.rb` and `crazy_eights/implementation_spec.rb`
gated pure in-process Ruby/DB assertions on wall-clock delays — a band-aid over
the infinite-loop hang above, not a fix for it.

**Fix:** all `sleep` calls in both files were deleted once the underlying hang
was fixed; the assertions didn't need them.

## Games index no longer shows finished games

**Was:** completed games still appeared in the "Your Games" section of
`games#index`.

**Fix:** `ea35d3e` — scoped the index query to exclude finished games.

## Game CSS fitted to the full screen

**Was:** the game board didn't take up the full viewport.

**Fix:** `5b88a54` — style fix so the game board renders at 100% of the screen.
