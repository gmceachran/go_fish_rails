# Roadmap & known issues

Running list of work to do, bugs, and tech debt worth tracking. Keep this
focused; if a category grows large, split it into its own doc.

## Top priority

- **Test suite is flaky and hangs.** System specs freeze regularly (the original
  note pointed at Crazy Eights). `sleep` calls were sprinkled through the code as
  band-aids — they don't fix it and should be removed as part of the real fix.
  The likely direction: stop leaning on Capybara so heavily and set up / assert
  game state directly via the database (queries and factories) instead of driving
  the browser for everything. Worth a dedicated branch and a thorough
  investigation.

## Known bugs

- **Crazy Eights win condition doesn't work.** `CrazyEights::Implementation#winner`
  returns `false`, so a game never declares a winner or ends. Needs real
  end-of-game detection (a player emptying their hand). See `docs/crazy-eights.md`.
- **Navigation out of `games#show`** is awkward / missing a clean path back.

## Refactors

- **Rename the `Player` ActiveRecord model.** The persisted join model `Player`
  collides confusingly with the in-memory `GoFish::Player` / `CrazyEights::Player`
  POROs. Candidate name: `GameUser`. One of several naming decisions to revisit.
- **Move hand-rolled CSS onto `@rolemodel/optics`.** UI should go through the
  design system; there's existing custom CSS to migrate.
- **Crazy Eights wild-card (8) flow** — suit re-selection after playing a wild is
  a rough edge worth cleaning up.

## Worth noting, not necessary

Low-priority items that would only matter with a significant refactor and are
likely out of scope for the current work. If these start to pile up, give them
their own doc.

- **`ArchiveGamesJob` / `archived_at`.** Built to satisfy an assignment
  requirement; it stamps `archived_at` but isn't doing anything genuinely useful
  yet. Making it worthwhile would take a meaningful refactor — probably out of
  scope for the near term.

## Done

- Games index no longer shows finished games.
- Game CSS fitted to the full screen.
