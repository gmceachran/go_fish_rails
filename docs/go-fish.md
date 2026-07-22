# Go Fish (as implemented)

Rules as they actually behave in `app/models/go_fish/`, not the abstract
Hoyle version. Where the code diverges from "standard" Go Fish, the code wins —
this documents the code.

## Setup

- Standard 52-card deck (`GoFish::Deck`): ranks `2 3 4 5 6 7 8 9 10 J Q K A`,
  suits `Spades Clubs Hearts Diamonds`.
- Deck is shuffled, then dealt. Starting hand size depends on player count
  (`Engine::STARTING_HAND`):
  - 1–2 players: 7 cards each
  - 3 players: 7 cards each
  - 4–5 players: 5 cards each
- Turn order is the players in `id` order of their join records; the first
  player (`active_player_index` 0) goes first.

## Taking a turn

The active player asks another player (the `opponent`) for a `rank`. A turn is
only valid if (see `Turn` validations):
- the game exists and is `active`,
- the opponent is a different player in this game,
- it is the asking player's turn,
- the asking player actually holds at least one card of that rank.

Resolution (`Engine#play_turn`):
- **Opponent has cards of that rank** → all of them transfer to the asker, and
  the asker **goes again** (`go_again: true`).
- **Opponent has none** → "Go Fish": the asker draws the top card of the deck.
  If the drawn card matches the asked rank, the asker goes again; otherwise the
  turn passes.
- If the deck is empty on a Go Fish, the result is flagged `deck_empty`.

## Books

Whenever a player collects **all four cards of a rank**, those four leave the
hand and become a `Book` (`Player#create_book_if_possible`, checked after taking
cards). A book's `value` is the rank's index (higher rank = higher value).

## Running out of cards mid-game

After each turn, any player whose hand is empty draws a card from the deck to
stay in the game (`handle_empty_hand`). If the deck is also empty, that player is
marked `cant_play` and is skipped by `advance_turn`.

## Ending & winner

The game is over when **every player's hand is empty** (`Engine#winner`
returns nil until then). The winner is the player with the most books, breaking
ties by highest single book value:

```
players.max_by { |p| [p.books.length, best_book_value(p)] }
```

After every turn, `Game#declare_winner_if_over!` (shared with Crazy Eights — see
`docs/architecture.md`) maps that player to the persisted `Player` and calls
`declare_winner!`, ending the game. The next render of `games#show` then
overlays the win modal on the board itself (`games/_winner_modal.html.slim`) —
no redirect to a separate screen.
End-to-end covered by `spec/systems/go_fish_play_spec.rb`.

## Turn feed

Each turn produces a `TurnResult` (`go_fish`, `cards`, `book_made`, `go_again`,
`deck_empty`) that the `games/feed` partial renders into the live game feed.
