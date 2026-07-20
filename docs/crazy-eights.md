# Crazy Eights (as implemented)

Rules as they actually behave in `app/models/crazy_eights/`. Where the code
diverges from "standard" Crazy Eights, the code wins.

## Setup

- Standard 52-card deck (`CrazyEights::Deck`): ranks `2 3 4 5 6 7 8 9 10 J Q K A`,
  suits `Spades Clubs Hearts Diamonds`.
- **8s are wild** (`Card#wild?`, `WILD_RANK = "8"`).
- Deck is shuffled, then dealt. Starting hand size by player count
  (`Implementation::STARTING_HAND`):
  - 1–2 players: 7 cards each
  - 3–5 players: 5 cards each
- The discard pile is started by flipping the top card, **skipping wild (8)
  cards** so the game never opens on a wild (`flip_non_wild_discard`).
- Turn order follows player `id` order; `active_player_index` 0 goes first.

## Taking a turn

A turn is either **play a card** or **draw** (`CrazyEightsTurn#draw?`, driven by
the `action` field). Validity (see `CrazyEightsTurn` validations):
- game exists and is `active`, and it is this user's turn;
- **draw:** only valid if the deck is not empty;
- **play a card:** `rank` and `suit` must be present and valid, the player must
  hold that exact card, and the card must be **wild (an 8), or match the rank or
  suit of the top discard**.

Resolution (`Implementation#play_turn`):
- **Play** → the card moves from hand to the discard pile; `TurnResult` records
  `played_card` and whether it was `wild`.
- **Draw** → the player takes the top deck card and **plays again**
  (`play_again: true`), so the turn does not advance.

`advance_turn` moves to the next player (wrapping around) unless the result says
play again.

## Wild cards (8s)

An 8 can be played on anything. The code flags the resulting `TurnResult` as
`wild`, which the board surfaces (`board_for` passes `wild:` through). Suit
re-selection after a wild is a known rough edge — see `docs/roadmap.md`.

## Ending & winner

**Incomplete.** `Implementation#winner` currently returns `false` (no winner
detection in the game engine). The `TurnsController` calls `declare_winner!`
based on that return, so as written a Crazy Eights game does not end itself. This
is a known gap — see `docs/roadmap.md`.

## Turn feed

Each turn produces a `TurnResult` (`drew_card`, `played_card`, `play_again`,
`wild`) rendered by the `games/crazy_eights_feed` partial.
