# Rummy — locked layout concept (ANSI)

This is the agreed layout the HTML concepts in this folder are built from. It is a
**right-rail dashboard**: a scrollable meld area on the left, a fixed
stock/discard column, the player's hand pinned across the bottom, and an
informational rail on the right.

```
┌──────────────────────────────────────────┬──────────┬────────────┐
│ Your meld                                 │┌────────┐│ RUMMY      │
│  4♠ 5♠ 6♠ [+]   J♦ J♣ J♥ [+]              ││        ││ ┌────────┐ │
│                                           ││ STOCK  ││ │Round 3 │ │
│ Dana's melds                              ││  31    ││ └────────┘ │
│  7♣ 7♦ 7♥ [+]   2♠ 3♠ 4♠ [+]   9♥10♥J♥[+] ││        ││            │
│  Q♣ Q♦ Q♥ [+]                             │└────────┘│ TURN       │
│                                           │┌────────┐│  ● You     │
│ Tom's melds                               ││        ││  ○ Dana    │
│  K♠ K♦ K♣ [+]                             ││ DISCARD││  ○ Tom     │
│                                           ││  9♦    ││            │
│  ⋮  (rows scroll vertically)              ││        ││ SCORES     │
│                                           │└────────┘│  You    19 │
├───────────────────────────────────────────┴──────────┤  Dana   30 │
│ HAND                                                  │  Tom    23 │
│  A♠ 3♠ 7♥ 7♦ 7♣ 10♦ J♦ Q♦ K♣                          │            │
│  [ Draw stock ]  [ Take discard ]  [ Discard ▾ ]      │            │
└───────────────────────────────────────────────────────┴────────────┘
```

> The sketch above is the initial locked layout. The built concepts refined it:
> the rail's separate **TURN** and **SCORES** blocks became one **Players** list
> (turn dot + name + score per row), and the dealer readout was dropped. The
> chosen theme + stock/discard placement lives in [`README.md`](README.md) and
> [`optics/`](optics/).

## Decisions baked in

- **One meld row per player**, stacked vertically. The meld area is the only
  region that scrolls, and it scrolls **vertically only**.
- **No horizontal scrolling anywhere.** When a player has more melds than fit on
  a line, their melds **wrap** onto additional lines; the row grows taller and
  the vertical scroll absorbs it. This is what lets the layout survive a large
  game (6 players, many melds) without any one player crowding out the rest.
- **Layoff is per meld, not per player.** Each meld carries its own `[+]`
  affordance because a layoff targets one specific meld. Intended interaction:
  select card(s) in hand → legal `[+]` buttons light up (illegal ones disable) →
  click the one on the meld being extended.
- **Stock and discard are stacked in a fixed column** to the right of the melds,
  wide enough for a full card plus label/count. They never move or shrink as
  melds accumulate — the failure mode of the earlier center-piles layout.
- **Hand spans the bottom** of the work area with the turn actions beneath it.
- **Right rail is informational**: brand, round, and a combined **Players** list
  (each row is turn order + running score together). No dealer is tracked. Turn
  actions live under the hand, not in the rail.

## Still open

- **Scoring standard** — per-hand settlement is specified (losers pay the winner
  pip value: face 10, ace 1, else pip; doubled on a "rummy"). How hands
  accumulate into a match is not: leaning winner-credited, play to a target
  (100 or 500). The rail's running "Scores" assume some accumulation. See
  `docs/rummy.md`.
- **Whole-meld vs `[+]` as the layoff target** — kept the explicit `[+]` for
  discoverability; the whole meld as a click/drop target is cleaner and better
  for drag-and-drop, revisit once players are familiar.
- **`[+]` position when a row wraps** — pin to the meld it belongs to (as drawn),
  which the per-meld model makes automatic.
