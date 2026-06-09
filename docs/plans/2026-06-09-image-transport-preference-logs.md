# Image Transport And Preference Logs

date: 2026-06-09
status: completed

## Context

Finn receives restaurant image URLs from the API response and records swipe
events in the card delegate. The app already avoids raw location and API
payload logging, so image downloads and preference events should follow the
same privacy boundary.

## Completed Scope

- Rejected non-HTTPS restaurant image URLs before starting an image request.
- Removed console logs for saved and skipped restaurant swipe events.
- Extended `scripts/check-baseline.sh` to preserve HTTPS image loading and
  preference-log guardrails.
- Updated README, SECURITY, VISION, and CHANGES with the transport and logging
  boundary.

## Verification

- `make check`
- `git diff --check`

Full Xcode build and simulator verification are still skipped locally because
`xcodebuild` is not installed in this environment.
