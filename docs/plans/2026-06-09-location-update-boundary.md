# Location Update Boundary

date: 2026-06-09
status: completed

## Context

Finn requests the user's location to fetch nearby restaurants. The delegate
previously kept location updates active after a usable fix and logged the raw
location failure description. The sample should keep location handling narrow:
use one coordinate for the restaurant lookup, avoid raw location diagnostics,
and do not keep polling after the request is started.

## Completed Scope

- Added a nil guard before reading `manager.location`.
- Stopped location updates after the first usable location fix.
- Stopped location updates on location failure and replaced raw error text with
  a generic diagnostic.
- Extended `scripts/check-baseline.sh` to preserve the location boundary.
- Updated README, SECURITY, VISION, and CHANGES with the new privacy guardrail.

## Verification

- `make check`
- `git diff --check`

Full Xcode build and simulator verification are still skipped locally because
`xcodebuild` is not installed in this environment.
