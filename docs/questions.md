# Questions for instructors

A running list of things to raise during code reviews. This is for the
developer, **not** for agents — an agent shouldn't try to answer or act on these.

## CI / GitHub Actions

- The GitHub Actions workflow (`.github/workflows/ci.yml`) was generated with the
  Rails app. It runs Rubocop, Brakeman, and bundler-audit, but **does not run the
  RSpec suite**, and the `scan_js` job is empty. Was it intentionally set up this
  way? Is there any reason *not* to run the RSpec suite whenever that workflow
  runs? Should this be changed?
