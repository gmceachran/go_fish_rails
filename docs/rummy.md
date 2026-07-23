# Rummy (target rules)


## Setup

- Standard 52-card deck: ranks `A 2 3 4 5 6 7 8 9 10 J Q K`, suits
  `Spades Clubs Hearts Diamonds`. Rank order for sequences is
  `A 2 3 ... 10 J Q K` (ace low).
- Deck is shuffled, then dealt. Starting hand size depends on player count:
  - 2 players: 10 cards each
  - 3–4 players: 7 cards each
  - 5–6 players: 6 cards each
- The remaining cards form the **stock** (face down). The top card of the stock
  is turned face up to start the **discard pile** (the upcard).
- Turn order is the players in join order; the player to the dealer's left goes
  first.

## Taking a turn

On their turn, the active player:

1. **Draws** exactly one card — either the top of the stock (face down) or the
   top of the discard pile (face up).
2. **Optionally melds and/or lays off** (see below).
3. **Discards** one card face up onto the discard pile — *unless* they go out by
   melding/laying off their entire hand (see Going out).

A turn is only valid if the game is `active` and it is the drawing player's
turn. If the player drew from the discard pile, they **may not discard that same
card on the same turn**.

## Melds

A **meld** is a matched set laid face up on the table:

- **Group** — three or four cards of the same rank (e.g. three 7s).
- **Sequence (run)** — three or more consecutive cards of the same suit (e.g.
  `4 5 6` of hearts).

A player may lay down any number of valid melds on their turn, from cards in
their hand.

## Laying off

A player may add cards from their hand to **any meld already on the table**
(their own or an opponent's) — **but only once they have laid down at least one
meld of their own this game** ("breaking in"). A player who has not yet melded
may not lay off onto anyone's meld.

- Add a fourth card to a three-of-a-kind group.
- Extend a sequence at either end (e.g. with `10 9 8` showing, add `J`, or
  `Q J`, or `7`, or `7 6`).

A laid-off card must keep the target meld valid (same rank for a group;
consecutive same-suit for a sequence).

## Going out

A player **goes out** (and wins the hand) when they get rid of every card in
their hand. On the final turn they may lay down all remaining cards as melds
and/or lay-offs **without discarding**. This ends the hand immediately — no
further play.

## Running out of stock

If the last card of the stock is drawn and no one has gone out, the next player
in turn may either take the top of the discard pile, or turn the discard pile
over to form a new stock (**without shuffling**) and draw the top card. Play
then continues as before.

## Scoring

Each losing player pays the winner the **pip value** of the cards left in their
hand, whether or not those cards form matched sets:

- Face cards (K, Q, J) — 10 each
- Aces — 1 each
- All other cards — their pip (face) value

**Rummy bonus:** if the winner gets rid of their entire hand in one turn without
having previously melded or laid off any cards, they go "rummy" and every
opponent pays **double**.

## Ending & winner

The hand ends when a player goes out (or, in a scored match, when a target score
is reached). The engine's `winner` returns nil until a player has gone out, then
returns that player. As with the other games, `Game#declare_winner_if_over!`
maps the winning PORO player to the persisted `Player` and ends the game; the
next `games#show` render overlays the win modal on the board.
