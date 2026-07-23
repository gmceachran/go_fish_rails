# Rummy concepting

Throwaway design exploration for the Rummy UI — **not** wired to the app. These
are here to look at and react to, not to ship. The `non-optics-concepts/` set is
deliberately built *outside* the design system to explore look-and-feel freely;
the `optics/` set is built on the real Optics theme. Real UI will go through
`@rolemodel/optics` (project rule 5).

- [`layout-ansi.md`](layout-ansi.md) — the agreed layout (right-rail dashboard)
  and the decisions baked into it. Start here.

Five styling iterations of that same layout — identical markup, different CSS
(padding, radius, shadow, palette, type). Open in a browser:

1. [`concept-1-card-room.html`](non-optics-concepts/concept-1-card-room.html) — felt-green card room;
   warm wood rail, ivory cards, gold accents, tactile shadows, serif.
2. [`concept-2-clean-dashboard.html`](non-optics-concepts/concept-2-clean-dashboard.html) — light
   SaaS dashboard; white panels, indigo accent, hairline borders, airy padding.
3. [`concept-3-neon-arcade.html`](non-optics-concepts/concept-3-neon-arcade.html) — dark neon arcade;
   cyan/magenta glow, luminous pips on dark card faces, tight radius.
4. [`concept-4-vintage-paper.html`](non-optics-concepts/concept-4-vintage-paper.html) — vintage paper;
   cream stock, oxblood + ink, serif, near-flat with hairline rules.
5. [`concept-5-aurora-glass.html`](non-optics-concepts/concept-5-aurora-glass.html) — aurora glass;
   vibrant gradient, frosted blur panels, large radius, soft shadows.
Concepts 1–5 are look-and-feel exploration and sit deliberately outside the
Optics theme.

## `optics/` — the app's own theme

The chosen direction, built from the real Optics tokens (`--op-color-primary`
H200, radius/spacing/shadow scales) and BEM classes echoing the existing
`game-board` / `game-actions` / `stat-card` / `bubble` / `playing-card`
components; renders the app's actual `cards_light/*.svg` art. This is the
variant that would translate most directly into real views. Two layouts of the
same theme, differing only in where the stock/discard live:

- [`optics/piles-in-sidebar.html`](optics/piles-in-sidebar.html) — stock/discard
  stacked at the top of the right sidebar (the main feature there), Players
  pinned to the bottom; melds get the full main width.
- [`optics/piles-in-board.html`](optics/piles-in-board.html) — stock/discard in
  their own dedicated column inside the board, beside the melds; Players sits at
  the top of the sidebar.

**Decision: going with `piles-in-board`** (stock/discard on the game board), for
two reasons:

1. **Layout sense** — the stock and discard piles are part of the core game
   idea (they're on the table), so they belong in the board section alongside
   the melds, not off in the sidebar.
2. **Reserving the sidebar** — keeping the piles out of the sidebar frees it for
   information worth keeping on screen as the game progresses. Most likely a
   **game feed** (like the other games have) narrating turns as they happen.

- [`optics/piles-in-board-accent.html`](optics/piles-in-board-accent.html) — the
  `piles-in-board` layout with a **warm accent** worked in, so the screen isn't
  wall-to-wall blue. Borrows the go-fish feed's brown/amber (`alerts-warning`,
  hue 47) in three spots: the **Round** badge (mirroring that feed's warning
  bubble), the **active player's turn** highlight (warm = "your turn"), and a
  **focused meld** on the board (one of Dana's melds is warm-tiled to show the
  meld the player is honing in on — pulling the accent onto the board, not just
  the sidebar). The primary action button stays blue so the accent never
  competes with the main call to action.

  It also demos **meld selection from the hand**: the 6♥ 7♥ 8♥ run is pulled to
  the left of the hand into a warm selection group — the cards the player has
  picked to lay down as a meld. (In the real app this state would be
  toggled by clicking hand cards, not baked into the markup.)
