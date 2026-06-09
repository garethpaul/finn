# Location Callback Payload

date: 2026-06-09
status: completed

## Context

Finn already stops location updates after one usable foreground fix and avoids
logging raw coordinates. The delegate still read `manager.location.coordinate`
inside `didUpdateLocations`, which can be stale relative to the callback payload
that triggered the delegate method.

## Completed Scope

- Guarded empty `locations` callbacks before starting a restaurant lookup.
- Extracted the latest callback location as `CLLocation`.
- Used the callback location coordinate for the API request.
- Preserved the existing one-shot `stopUpdatingLocation()` boundary and card
  queue guard.
- Extended `scripts/check-baseline.sh` to reject `manager.location.coordinate`
  and require callback-location handling.
- Updated README, VISION, and CHANGES with the new location payload guardrail.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`

Full Xcode build and simulator verification are still skipped locally because
XcodeBuildMCP and `xcodebuild` are not installed in this environment.
