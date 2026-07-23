---
name: The Focused Felt
description: A calm, real-time table for familiar card games, built on RoleModel Optics.
colors:
  primary: "hsl(200 50% 32%)"
  warning-amber: "hsl(47 100% 40%)"
  surface-white: "#ffffff"
typography:
  display:
    fontFamily: "'Noto Sans', sans-serif"
    fontSize: "2rem"
    fontWeight: 600
    lineHeight: 1.2
  headline:
    fontFamily: "'Noto Sans', sans-serif"
    fontSize: "1.8rem"
    fontWeight: 600
    lineHeight: 1.25
  title:
    fontFamily: "'Noto Sans', sans-serif"
    fontSize: "1.6rem"
    fontWeight: 500
    lineHeight: 1.4
  body:
    fontFamily: "'Noto Sans', sans-serif"
    fontSize: "1.6rem"
    fontWeight: 400
    lineHeight: 1.5
  label:
    fontFamily: "'Noto Sans', sans-serif"
    fontSize: "1.2rem"
    fontWeight: 600
    lineHeight: 1.4
    letterSpacing: "0.08em"
rounded:
  card: "6px"
  sm: "8px"
  md: "16px"
  lg: "24px"
  xl: "32px"
spacing:
  2x-small: "0.4rem"
  x-small: "0.8rem"
  small: "1.2rem"
  medium: "1.6rem"
  large: "2rem"
  x-large: "2.4rem"
components:
  button-primary:
    backgroundColor: "{colors.primary}"
    textColor: "{colors.surface-white}"
    rounded: "{rounded.sm}"
    padding: "1.2rem 1.6rem"
  button-secondary:
    backgroundColor: "{colors.surface-white}"
    rounded: "{rounded.sm}"
    padding: "1.2rem 1.6rem"
  meld:
    rounded: "{rounded.md}"
    padding: "0.8rem"
  player-row:
    backgroundColor: "{colors.surface-white}"
    rounded: "{rounded.sm}"
    padding: "1.2rem 1.6rem"
---

# Design System: The Focused Felt

> **Reference of record:** `docs/rummy-concepting/optics/piles-in-board-accent.html`.
> This is the visual world the whole app should converge on. The currently shipped
> Go Fish / Crazy Eights screens are **legacy** — treat them as work to bring in
> line with this system, not as authority. Everything below is extracted from the
> concept file, expressed in Optics tokens.

## Overview

**Creative North Star: "The Focused Felt"**

The table is a neutral stage, not a decorated one. Every screen reads as a quiet,
even-lit felt surface where the only things that carry weight are the cards, whose
turn it is, and what just happened. Chrome, panels, and labels recede into a
faintly cool near-white so the cards themselves are the loudest thing present.
This is an *Operate*-mode world: players arrive to take their turn with people
they already know, and the interface's job is to be exact and get out of the way.

Two accents do the signalling, and each has one clear meaning. **Teal** is the
cool, structural accent — it zones the play area (pale washes behind melds and the
feed rail) and marks the single next *action* (the solid primary button, the
layoff `+`). **Amber** is the warm accent — it marks what is *mine* and *now*: the
active player's row, the round badge, the meld a player is working, the cards
selected from a hand. Cool tells you where things are and what to do; warm tells
you what belongs to you and what is happening this moment. Neither ever fills a
large area; both earn their power by scarcity.

Depth is honest and nearly flat. Separation comes from hairline borders and gentle
tonal shifts between white, soft gray, and pale teal — not from shadow. The one
everyday shadow is barely-there (3–15% black), reserved for the objects that read
as physically liftable: cards and the small floating rows that hold them. Every
value in the system is a RoleModel **Optics** token (`--op-*`); this world is a
disciplined *configuration* of Optics, not hand-authored CSS.

**Key Characteristics:**
- Faintly teal-cool neutral stage; cards are the focus, chrome recedes.
- Two-accent logic: teal = structure + next action; amber = mine + now.
- 8px is the default corner almost everywhere; 16px groups a meld; 32px pills.
- Near-flat: hairline borders and soft tonal steps; shadow is whisper-quiet.
- Uppercase, letter-spaced micro-labels name every zone.
- Every value is an Optics token; no bespoke CSS values.

## Colors

A near-monochrome, faintly teal-cooled field with one cool accent and one warm
accent. Optics generates full tonal ramps per role (`-plus-N` surface tiers,
`-on-plus-N` contrast text); the project rehues the primary, derives neutrals from
the same hue, and defines a custom warm accent.

### Primary
- **Deep Muted Teal-Blue** (`hsl(200 50% 32%)`, `--op-color-primary-*`): The cool,
  structural accent. Set at the root via `--op-color-primary-h/s/l`; Optics derives
  the ramp. **Solid** (`-base`, ~`hsl(200 50% 40%)`) is reserved for *the next
  action* — the primary button (`Draw stock`) and the layoff `+`. Its **pale tiers**
  do the ambient work: `-plus-seven` washes the default meld surface, `-plus-eight`
  tints the full-height feed rail. Teal never marks state — only place and action.

### Tertiary
- **Warm Amber** (`hsl(47 100% 40%)`, `--op-color-alerts-warning-*`): The warm
  accent — always meaning *current / chosen / mine*, and rationed. It marks: the
  active player row (`.is-active`: `-base` border + turn dot, `-plus-eight` fill),
  the round badge and the focused meld's layoff (`-plus-seven` fill,
  `-on-plus-seven` text), the meld a player is working (`.meld--accent`:
  `-plus-eight` fill, `-base` border), and cards pulled from the hand
  (`.hand-selection`, same amber pair). It also covers genuine alerts (illegal
  moves, connection loss) — the same "pay attention to this" family.

### Neutral
- **Cool Table White** (`hsl(200 4% 100%)` ≈ `#ffffff`, `--op-color-neutral-plus-max`):
  The board work area and every floating row/card surface. Neutrals derive from the
  primary hue at 4% saturation, so grays are *faintly* teal-cool, never dead.
- **Soft Stage Grays** (`--op-color-neutral-plus-eight`/`-seven`): The hand tray, the
  piles column, secondary surfaces — a half-step off white.
- **Hairline Border** (`--op-color-border` = `--op-color-neutral-plus-five`): 1px
  separators everywhere; the primary means of dividing space instead of shadow.
- **Ink Tiers** (`--op-color-neutral-on-plus-*`, `--op-color-primary-on-plus-*`):
  Text is always the matching Optics `on-*` token for its surface, never a raw gray.

### Named Rules
**The Two-Accent Rule.** Teal is cool and structural: it zones the play area and
marks the next *action*. Amber is warm: it marks the *current / chosen / mine*
thing — your turn, your row, the meld you're building, the cards you picked — and
genuine alerts. Cool = where and what to do; warm = what is mine and now. If you
reach for an accent, first decide which of those two questions it answers.

**The Sparing Teal Rule.** Solid teal appears only on the next action (primary
button, layoff `+`). Everywhere else teal is a pale wash or nothing. Its rarity is
what makes the action obvious.

**The Optics-Only Rule.** Every color is an `--op-color-*` token. A raw hex or
`hsl()` literal outside `game-theme-core.css` is a bug.

## Typography

**Display / Body Font:** Noto Sans (with `sans-serif` fallback) — `--op-font-family`.
(The standalone concept file previews with `system-ui` only because it renders
without the app's font; the real system is Noto Sans via Optics.)

**Character:** One humanist sans across everything. There is no display face;
hierarchy comes entirely from size, weight, and — for the smallest labels — case
and tracking. Weight and case, not decoration, do the signalling.

### Hierarchy
- **Display** (600, `2rem` / `--op-font-x-large`): Reserved page-level titles. Rare.
- **Headline** (600, `1.8rem` / `--op-font-large`): Panel header bars — "Board",
  "Rummy", "Your Hand".
- **Title** (500, `1.6rem` / `--op-font-medium`): Player names, primary readable
  labels, the medium-weight middle of the hierarchy.
- **Body** (400, `1.6rem` / `--op-font-medium`): Default text.
- **Micro-label** (600, `1.2rem`–`1.4rem`, `letter-spacing 0.04–0.08em`, UPPERCASE):
  Zone titles — "YOUR MELDS", "STOCK", "DISCARD", "PLAYERS". Muted color, often
  slightly reduced opacity. This is the system's connective tissue.

### Named Rules
**The Uppercase Micro-Label Rule.** Every zone (a player's melds, a pile, a rail
block) is named by a small, uppercase, letter-spaced, muted semibold label — never
a full-size heading. These labels orient without competing with the cards.

**The Weight-Not-Face Rule.** Emphasis uses Optics weight tokens
(`--op-font-weight-normal` → `-semi-bold`) at one family. Never add a second
typeface for hierarchy.

## Layout

A single full-viewport board (`height: 100vh; overflow: hidden`) — a fixed,
self-contained table, not a scrolling document. One outer CSS grid, plus a nested
grid inside the main cell:

- **Outer grid** (`.game-board`): `grid-template-columns: 1fr 334px`,
  `grid-template-rows: 1fr 256px`.
  - **Main board** (top-left, white): the play area.
  - **Hand tray** (bottom-left, soft gray, 256px tall, top hairline border): the
    player's hand + action buttons, centered.
  - **Feed rail** (right, 334px, spans both rows, pale teal tint, left hairline
    border): panel header ("Rummy" + round badge) over stacked rail blocks
    (player list, log).
- **Nested main grid** (`.game-board__main-body`): `grid-template-columns: 1fr 210px`
  — the scrolling **melds** column beside a fixed **piles** column (stock + discard),
  divided by a hairline border.

Each panel is a `.gf-section`: a fixed **60px header bar** (`--op-font-large`
semibold title, space-between, bottom hairline) over a scrolling content area. That
60px horizon line is consistent across all panels.

Spacing is the Optics scale (`--op-space-*`, scale unit `1rem` at a 62.5% root):
`2x-small` 0.4rem → `x-large` 2.4rem. Panels pad generously at `--op-space-large`
(2rem); tight groupings (melds, selections) use `x-small`/`2x-small`.

## Elevation & Depth

Near-flat by design. Separation is carried by 1px `--op-color-border` hairlines and
by tonal steps between white, soft gray, and pale teal. Shadow is a whisper — a hint
that an element is a liftable object, never decoration. Note the concept
deliberately *softens* Optics' default shadows to 3–15% black.

### Shadow Vocabulary
- **Resting lift** (`--op-shadow-x-small`: `0 1px 2px hsl(0 0% 0% / 3%), 0 1px 3px
  hsl(0 0% 0% / 15%)`): The only everyday shadow. On playing cards and the small
  floating rows that carry them (player-list rows). That's it.
- **Overlay lift** (`--op-shadow-medium` and up): Reserved for true overlays
  (winner/confirm dialog), which also gets a backdrop blur.

### Named Rules
**The Whisper-Shadow Rule.** Surfaces are flat and bordered at rest. Apply
`--op-shadow-x-small` only to something that reads as a liftable object (a card, a
card-bearing row). Reserve anything heavier for floating overlays.

## Shapes

One dominant corner, with two deliberate exceptions. Borders are uniformly
`--op-border-width` (1px) in `--op-color-border` and are the primary structural
line of the whole system.

- **The default — 8px (`--op-radius-small`):** Buttons, player-list rows,
  hand-selection groups, the layoff `+`. Nearly everything interactive or
  informational uses 8px. Crisp, calm, slightly softened.
- **Meld grouping — 16px (`--op-radius-medium`):** The one step up, used to visually
  bundle a run/set of cards into a single meld object.
- **Pills — 32px (`--op-radius-x-large`):** Fully-round chips: the round badge and
  feed bubbles.
- **Card faces — 6px (`calc(--op-radius-small * 0.75)`):** Playing-card corners;
  backs a touch rounder at 12px (`* 1.5`).

### Named Rules
**The Soft-Eight Rule.** 8px is the answer unless there's a reason: step up to 16px
only to group a meld, go full-round (32px) only for a pill/badge. Don't introduce
intermediate radii or reach for 24px — the target world doesn't use it.

## Components

### Meld (signature)
The defining object: a horizontal row of small card faces
(`.playing-card--meld`, 54px) plus a trailing layoff `+`, bundled at 16px radius.
- **Default:** pale teal fill (`--op-color-primary-plus-seven`), `-plus-six` border,
  `x-small` padding, `2x-small` gaps.
- **Focused (`--accent`):** amber fill (`-plus-eight`) + `-base` border; its layoff
  `+` deepens to the amber `-plus-seven`/`-on-plus-seven` pair. This is amber's
  "the meld you're working" state.
- Melds group under an uppercase per-player label ("YOUR MELDS", "DANA'S MELDS"),
  players separated by a top hairline + `medium` padding.

### Layoff button (`.layoff`)
A 28×28 square-ish (8px) icon button, solid teal (`-base`) with white glyph — a
compact "next action" living inside each meld. Brightness lift on hover.

### Playing cards (`.playing-card`)
SVG card art (`app/assets/images/cards_light/*.svg`), 6px face radius, `x-small`
resting shadow. Sizes: `--meld` 54px (in melds), `--large` 54px (hand — matches
meld size), `--medium` 82px (piles). Backs use 12px radius.

### Piles (stock & discard)
A fixed 210px column beside the melds, hairline-divided, soft-gray. Each pile: an
uppercase label, a centered `--medium` card (card back for stock, face-up for
discard), and a small muted count ("31 left").

### Hand tray + actions
The bottom band. Hand cards (`--large`) wrap centered in `.card-tray`.
- **Hand-selection:** cards picked to form a meld are grouped on the *left* in an
  amber-outlined 8px box (`-plus-eight` fill, `-base` border) — amber's "mine,
  chosen" state, mirroring `.meld--accent`.
- **Action row (`.tray__actions`):** up to three buttons, `medium` gap, max 760px.

### Buttons
- **Shape:** 8px (`--op-radius-small`).
- **Secondary (default `.btn`):** white fill, hairline border, muted ink, medium
  weight — "Take discard", "Discard ▾". Neutral hover.
- **Primary (`.btn--primary`):** solid teal (`-base`), white text, transparent
  border, semibold, and visually wider (`flex: 1.66`) so the main action dominates
  the row. Brightness lift on hover. One per action row (**Sparing Teal Rule**).

### Player list (`.player-list` — signature rail block)
Combined turn + score rows in the feed rail. Each `li`: a 9px round **turn dot**,
the name, and "Score: **N**", on a white 8px row with hairline border and `x-small`
shadow.
- **Active (`.is-active`):** amber `-base` border, amber `-plus-eight` fill, amber
  turn dot, and a semibold amber-ink name — the unmistakable "your turn / this is
  you" marker.

### Feed bubble / round badge (`.bubble`)
A 32px amber pill (`-plus-seven` fill, `-on-plus-seven` text, medium weight,
`fit-content`). Used for the round badge in the rail header and for short warm feed
lines. Warm because it reports *what's happening now*.

### Rail blocks
Stacked sections in the feed rail, each opened by an uppercase, extra-tracked
(`0.08em`) micro-title in teal ink at reduced opacity.

## Do's and Don'ts

### Do:
- **Do** treat `docs/rummy-concepting/optics/piles-in-board-accent.html` as the
  reference of record and bring legacy screens toward it.
- **Do** express every color, space, radius, type, and shadow as an `--op-*` token;
  put any new project override in `core/theme/game-theme-core.css`, not inline.
- **Do** apply the **Two-Accent Rule**: teal for structure + the next action, amber
  for the current/chosen/mine thing and alerts. Decide which question the accent
  answers before using it.
- **Do** default to 8px corners; step to 16px only to group a meld, 32px only for a
  pill (**Soft-Eight Rule**).
- **Do** name every zone with an uppercase, letter-spaced, muted micro-label.
- **Do** keep depth near-flat: hairline borders and soft tonal steps; whisper-quiet
  `x-small` shadow only on cards and card-bearing rows.
- **Do** pair color turn-cues with a non-color cue (the turn dot, the name, an
  icon) so turn state never depends on color alone.

### Don't:
- **Don't** treat the shipped Go Fish / Crazy Eights styling as the target; it's
  legacy to be reconciled with this system.
- **Don't** hand-roll CSS or introduce raw hex / `hsl()` literals outside the theme
  file.
- **Don't** flood a screen with solid teal — solid teal is the next action only.
- **Don't** use amber for anything that isn't current/chosen/mine or an alert; it's
  never decorative.
- **Don't** add ambient drop-shadows to flat surfaces, or reach past `x-small` for
  anything that isn't a true overlay (**Whisper-Shadow Rule**).
- **Don't** introduce 24px or other intermediate radii, or a second typeface for
  hierarchy.
