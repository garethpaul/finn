# Finn Image Loading Guards

date: 2026-06-08
status: completed

## Context

Restaurant cards load remote image URLs from the API response. The card view
force-unwrapped URL creation, and the image downloader force-unwrapped decoded
image data, so a malformed URL or failed image response could crash the app.

## Completed Scope

- Guarded `NSURL(string:)` before requesting a restaurant image.
- Returned early from image requests that complete with an error.
- Guarded response data and `UIImage(data:)` before invoking the image handler.
- Extended the static baseline to preserve these image-loading checks.

## Verification

- `scripts/check-baseline.sh`
- `make check`
- `git diff --check`
