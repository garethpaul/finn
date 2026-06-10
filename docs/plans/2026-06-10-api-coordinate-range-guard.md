# API Coordinate Range Guard

status: completed

## Context

Restaurant lookup parameters rejected blank strings but still allowed
nonnumeric values, parser leftovers, and impossible latitude or longitude.

## Work Completed

- Added exact `NSScanner` numeric parsing with no trailing input.
- Required latitude within -90 to 90 and longitude within -180 to 180.
- Kept invalid values on the existing empty-result path before Alamofire runs.
- Extended the baseline and privacy documentation.

## Verification

- `make check`
- `make lint`
- `make test`
- `make build`
- `git diff --check`
