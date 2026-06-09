#!/usr/bin/env sh
set -eu

ROOT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
PLAN="$ROOT_DIR/docs/plans/2026-06-08-finn-maintenance-baseline.md"
IMAGE_PLAN="$ROOT_DIR/docs/plans/2026-06-08-finn-image-loading-guards.md"
LOCATION_UPDATE_PLAN="$ROOT_DIR/docs/plans/2026-06-09-location-update-boundary.md"
TRANSPORT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-image-transport-preference-logs.md"
LOCATION_PAYLOAD_PLAN="$ROOT_DIR/docs/plans/2026-06-09-location-callback-payload.md"
ENDPOINT_PARTS_PLAN="$ROOT_DIR/docs/plans/2026-06-09-api-endpoint-url-parts.md"
RESTAURANT_FIELDS_PLAN="$ROOT_DIR/docs/plans/2026-06-09-api-restaurant-field-guard.md"
PICKER_RESTAURANT_PLAN="$ROOT_DIR/docs/plans/2026-06-09-picker-restaurant-state-guard.md"
COORDINATE_PARAMS_PLAN="$ROOT_DIR/docs/plans/2026-06-09-api-coordinate-parameter-guard.md"

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file missing: $path" >&2
    exit 1
  fi
}

for path in \
  ".gitignore" \
  "CHANGES.md" \
  "Makefile" \
  "Podfile" \
  "Podfile.lock" \
  "README.md" \
  "SECURITY.md" \
  "VISION.md" \
  "Finn.xcworkspace/contents.xcworkspacedata" \
  "Finn.xcodeproj/project.pbxproj" \
  "Finn/API.swift" \
  "Finn/Info.plist" \
  "Finn/FinnPickerView.swift" \
  "Finn/Picture.swift" \
  "Finn/ViewController.swift" \
  "FinnTests/FinnTests.swift" \
  "docs/plans/2026-06-09-api-coordinate-parameter-guard.md" \
  "docs/plans/2026-06-09-api-endpoint-url-parts.md" \
  "docs/plans/2026-06-09-api-restaurant-field-guard.md" \
  "docs/plans/2026-06-09-picker-restaurant-state-guard.md" \
  "docs/plans/2026-06-09-location-callback-payload.md" \
  "docs/plans/2026-06-08-finn-image-loading-guards.md" \
  "docs/plans/2026-06-09-location-update-boundary.md" \
  "docs/plans/2026-06-09-image-transport-preference-logs.md" \
  "docs/plans/2026-06-08-finn-maintenance-baseline.md"; do
  require_file "$path"
done

if ! grep -Fq "Alamofire (1.2.2)" "$ROOT_DIR/Podfile.lock" ||
  ! grep -Fq "MDCSwipeToChoose (0.2.2)" "$ROOT_DIR/Podfile.lock"; then
  printf '%s\n' "CocoaPods lockfile must preserve the legacy dependency baseline." >&2
  exit 1
fi

if ! grep -Fq "Finn.xcworkspace" "$ROOT_DIR/README.md" ||
  ! grep -Fq "make check" "$ROOT_DIR/README.md" ||
  ! grep -Fq "FINN_API_BASE_URL" "$ROOT_DIR/README.md" ||
  ! grep -Fq "location data" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document workspace usage, verification, API config, and location privacy." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "FINN_API_BASE_URL" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "location coordinates" "$ROOT_DIR/VISION.md"; then
  printf '%s\n' "VISION must describe the current API and location guardrails." >&2
  exit 1
fi

if ! grep -Fq "lint: check" "$ROOT_DIR/Makefile" ||
  ! grep -Fq "test: check" "$ROOT_DIR/Makefile" ||
  ! grep -Fq "build: check" "$ROOT_DIR/Makefile"; then
  printf '%s\n' "Makefile must expose lint, test, and build gates." >&2
  exit 1
fi

if ! grep -Fq "FinnAPIBaseURL" "$ROOT_DIR/Finn/Info.plist" ||
  ! grep -Fq '$(FINN_API_BASE_URL)' "$ROOT_DIR/Finn/Info.plist" ||
  grep -Fq "NSLocationAlwaysUsageDescription " "$ROOT_DIR/Finn/Info.plist"; then
  printf '%s\n' "Info.plist must expose the local API endpoint build setting." >&2
  exit 1
fi

if command -v python3 >/dev/null 2>&1; then
  python3 - "$ROOT_DIR/Finn/Info.plist" <<'PY'
import sys
import xml.etree.ElementTree as ET

ET.parse(sys.argv[1])
PY
else
  printf '%s\n' "Skipping Info.plist XML parse: python3 is not installed."
fi

api="$ROOT_DIR/Finn/API.swift"
if ! grep -Fq "FinnAPIBaseURL" "$api" ||
  ! grep -Fq "configuredAPIURL" "$api" ||
  ! grep -Fq "stringByTrimmingCharactersInSet" "$api" ||
  ! grep -Fq "configuredURL.isEmpty" "$api" ||
  ! grep -Fq 'configuredURL.hasPrefix("$(")' "$api" ||
  ! grep -Fq 'endpointURL.scheme == "https"' "$api" ||
  ! grep -Fq "endpointURL.user == nil" "$api" ||
  ! grep -Fq "endpointURL.password == nil" "$api" ||
  ! grep -Fq "endpointURL.query == nil" "$api" ||
  ! grep -Fq "endpointURL.fragment == nil" "$api" ||
  ! grep -Fq "if let host = endpointURL.host" "$api" ||
  ! grep -Fq "!host.isEmpty" "$api" ||
  grep -Fq 'let url = ""' "$api" ||
  grep -Eq 'r\["(name|image)"\]!' "$api"; then
  printf '%s\n' "API client must use parsed local HTTPS endpoint configuration and safe restaurant parsing." >&2
  exit 1
fi

if ! grep -Fq "let cleanName = name.stringByTrimmingCharactersInSet" "$api" ||
  ! grep -Fq "let cleanImage = image.stringByTrimmingCharactersInSet" "$api" ||
  ! grep -Fq "!cleanName.isEmpty" "$api" ||
  ! grep -Fq "!cleanImage.isEmpty" "$api"; then
  printf '%s\n' "API client must reject blank restaurant names and image URLs before card creation." >&2
  exit 1
fi

if ! grep -Fq "let cleanLat = lat.stringByTrimmingCharactersInSet" "$api" ||
  ! grep -Fq "let cleanLon = lon.stringByTrimmingCharactersInSet" "$api" ||
  ! grep -Fq "cleanLat.isEmpty || cleanLon.isEmpty" "$api" ||
  ! grep -Fq 'parameters: ["lat": cleanLat, "lon": cleanLon]' "$api"; then
  printf '%s\n' "API client must trim and reject blank coordinate parameters before requests." >&2
  exit 1
fi

view="$ROOT_DIR/Finn/ViewController.swift"
if grep -Fq "println(lat)" "$view" ||
  grep -Fq "println(lon)" "$view" ||
  grep -Fq "error.localizedDescription" "$view" ||
  grep -Fq "Error while updating location" "$view" ||
  grep -Fq "Restaurant saved!" "$view" ||
  grep -Fq "Restaurant skipped!" "$view" ||
  ! grep -Fq "if locations == nil || locations.count == 0" "$view" ||
  ! grep -Fq "as? CLLocation" "$view" ||
  ! grep -Fq "location.coordinate" "$view" ||
  grep -Fq "manager.location.coordinate" "$view" ||
  ! grep -Fq "manager.stopUpdatingLocation()" "$view" ||
  ! grep -Fq "self.restaurants.count < 2" "$view" ||
  grep -Eq '^[[:space:]]*createRestaurantView\(bottomCardViewFrame\(\), res: self\.restaurants\.removeAtIndex\(0\)\)' "$view"; then
  printf '%s\n' "View controller must avoid raw location logs, use callback locations, stop updates, and guard card removals." >&2
  exit 1
fi

picture="$ROOT_DIR/Finn/Picture.swift"
if grep -Fq "NSURL(string: url_string)!" "$ROOT_DIR/Finn/FinnPickerView.swift" ||
  grep -Fq "restaurant!" "$ROOT_DIR/Finn/FinnPickerView.swift" ||
  grep -Fq "UIImage(data: data)!" "$picture" ||
  ! grep -Fq "if let url = NSURL(string: url_string)" "$ROOT_DIR/Finn/FinnPickerView.swift" ||
  ! grep -Fq "if let restaurant = restaurant" "$ROOT_DIR/Finn/FinnPickerView.swift" ||
  ! grep -Fq "nameLabel.text = restaurant.name" "$ROOT_DIR/Finn/FinnPickerView.swift" ||
  ! grep -Fq '!url.absoluteString.hasPrefix("https://")' "$picture" ||
  ! grep -Fq "if let imageData = data" "$picture"; then
  printf '%s\n' "Image loading and picker rendering must guard invalid URLs, missing restaurants, and failed image decoding." >&2
  exit 1
fi

if ! grep -Fq "*.xcconfig" "$ROOT_DIR/.gitignore" ||
  ! grep -Fq ".env" "$ROOT_DIR/.gitignore"; then
  printf '%s\n' "Local API and signing config files must stay ignored." >&2
  exit 1
fi

if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -list -workspace "$ROOT_DIR/Finn.xcworkspace"
else
  printf '%s\n' "Skipping xcodebuild workspace listing: xcodebuild is not installed."
fi

if ! grep -Fq "status: completed" "$PLAN"; then
  printf '%s\n' "Plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$IMAGE_PLAN"; then
  printf '%s\n' "Image loading guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$LOCATION_UPDATE_PLAN"; then
  printf '%s\n' "Location update boundary plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$TRANSPORT_PLAN"; then
  printf '%s\n' "Image transport and preference log plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$LOCATION_PAYLOAD_PLAN"; then
  printf '%s\n' "Location callback payload plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$ENDPOINT_PARTS_PLAN"; then
  printf '%s\n' "API endpoint URL parts plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$RESTAURANT_FIELDS_PLAN"; then
  printf '%s\n' "API restaurant field guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$PICKER_RESTAURANT_PLAN"; then
  printf '%s\n' "Picker restaurant state guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$COORDINATE_PARAMS_PLAN"; then
  printf '%s\n' "API coordinate parameter guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$COORDINATE_PARAMS_PLAN"; then
  printf '%s\n' "API coordinate parameter guard plan must record make check verification." >&2
  exit 1
fi

printf '%s\n' "finn maintenance baseline checks passed."
