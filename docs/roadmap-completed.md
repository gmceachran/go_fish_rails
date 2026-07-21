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
the Crazy Eights model specs.

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

## Declare the winner from the turn flow, both games (Card 2)

**Was:** Go Fish's `#winner` computed correctly but nothing called
`declare_winner!` on that turn path, so a completed Go Fish game never reached
`over?`. Crazy Eights (Card 1) did declare a winner, but through a game-specific
`TurnsController#declare_crazy_eights_winner` that reached into
`game.game_state.winner`. Even when a game did reach `over`, the win screen was
broken: `GamesController#redirect_to_winner` passed one positional arg into the
nested `game_id`+`id` `winners` route, and `WinnersController#show` read
`params[:id]` (wrong segment) and `game_state.winner.name` (the unset in-memory
`"Lord Farquad"` default rather than the real user).

**Fix:** new `Game#declare_winner_if_over!` (`app/models/game.rb`) maps the
engine's `winner` to the persisted `Player` and calls `declare_winner!`; both
`apply_go_fish_turn` and `apply_crazy_eights_turn` call it after `save!`, and
`declare_crazy_eights_winner` was deleted. `redirect_to_winner` now passes both
route segments (`game_winner_path(game, game.players.find_by(winner: true))`),
and `WinnersController#show` reads `params[:game_id]` and renders
`game.players.find_by(winner: true).user.email_address` — no more `game_state`
reach-through on the win path. Driven outside-in by system specs in
`go_fish_play_spec.rb` and `crazy_eights_play_spec.rb` (each: force a hand empty,
submit the winning turn, assert the win-screen text), plus a model spec for
`declare_winner_if_over!` covering the winner/no-winner branches directly. Both
games now finish end-to-end, closing the roadmap's "no game can finish" Top
priority.

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
