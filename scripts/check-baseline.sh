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
IMAGE_URL_PARTS_PLAN="$ROOT_DIR/docs/plans/2026-06-09-image-url-parts-guard.md"
COORDINATE_RANGE_PLAN="$ROOT_DIR/docs/plans/2026-06-10-api-coordinate-range-guard.md"
CI_PLAN="$ROOT_DIR/docs/plans/2026-06-10-hosted-project-validation.md"
BRIDGING_HEADER_PLAN="$ROOT_DIR/docs/plans/2026-06-12-portable-bridging-header-path.md"
IMAGE_PAYLOAD_PLAN="$ROOT_DIR/docs/plans/2026-06-13-image-decode-payload-limit.md"
CI_WORKFLOW="$ROOT_DIR/.github/workflows/check.yml"

require_file() {
  path=$1
  if [ ! -f "$ROOT_DIR/$path" ]; then
    printf '%s\n' "Required file missing: $path" >&2
    exit 1
  fi
}

for path in \
  ".github/workflows/check.yml" \
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
  "Finn/BridgeHeader.h" \
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
  "docs/plans/2026-06-09-image-url-parts-guard.md" \
  "docs/plans/2026-06-10-api-coordinate-range-guard.md" \
  "docs/plans/2026-06-09-location-callback-payload.md" \
  "docs/plans/2026-06-08-finn-image-loading-guards.md" \
  "docs/plans/2026-06-09-location-update-boundary.md" \
  "docs/plans/2026-06-09-image-transport-preference-logs.md" \
  "docs/plans/2026-06-08-finn-maintenance-baseline.md" \
  "docs/plans/2026-06-10-hosted-project-validation.md" \
  "docs/plans/2026-06-12-portable-bridging-header-path.md" \
  "docs/plans/2026-06-13-image-decode-payload-limit.md"; do
  require_file "$path"
done

if ! grep -Fq "Alamofire (1.2.2)" "$ROOT_DIR/Podfile.lock" ||
  ! grep -Fq "MDCSwipeToChoose (0.2.2)" "$ROOT_DIR/Podfile.lock"; then
  printf '%s\n' "CocoaPods lockfile must preserve the legacy dependency baseline." >&2
  exit 1
fi

project_file="$ROOT_DIR/Finn.xcodeproj/project.pbxproj"
bridging_header_setting="SWIFT_OBJC_BRIDGING_HEADER = Finn/BridgeHeader.h;"

if [ "$(grep -Fc "$bridging_header_setting" "$project_file")" -ne 2 ] ||
  grep -Fq "/Users/" "$project_file"; then
  printf '%s\n' "Finn Debug and Release builds must use the tracked repository-relative bridging header." >&2
  exit 1
fi

if ! grep -Fq "Finn.xcworkspace" "$ROOT_DIR/README.md" ||
  ! grep -Fq "make check" "$ROOT_DIR/README.md" ||
  ! grep -Fq "FINN_API_BASE_URL" "$ROOT_DIR/README.md" ||
  ! grep -Fq "location data" "$ROOT_DIR/README.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/README.md" ||
  ! grep -Fq "parsed URL parts" "$ROOT_DIR/README.md"; then
  printf '%s\n' "README must document workspace usage, verification, API config, and location privacy." >&2
  exit 1
fi

if ! grep -Fq "scripts/check-baseline.sh" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "FINN_API_BASE_URL" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "location coordinates" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "parsed image URL validation" "$ROOT_DIR/VISION.md"; then
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
  ! grep -Fq "func coordinateInRange" "$api" ||
  ! grep -Fq "!scanner.scanDouble(&parsedValue) || !scanner.atEnd" "$api" ||
  ! grep -Fq "coordinateInRange(cleanLat, minimum: -90, maximum: 90)" "$api" ||
  ! grep -Fq "coordinateInRange(cleanLon, minimum: -180, maximum: 180)" "$api" ||
  ! grep -Fq 'parameters: ["lat": cleanLat, "lon": cleanLon]' "$api"; then
  printf '%s\n' "API client must parse and range-check coordinate parameters before requests." >&2
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
  ! grep -Fq "if let scheme = url.scheme" "$picture" ||
  ! grep -Fq 'scheme != "https"' "$picture" ||
  ! grep -Fq "if let host = url.host" "$picture" ||
  ! grep -Fq "host.isEmpty" "$picture" ||
  ! grep -Fq "url.user != nil || url.password != nil" "$picture" ||
  ! grep -Fq "if let imageData = data" "$picture"; then
  printf '%s\n' "Image loading and picker rendering must guard invalid URLs, missing restaurants, and failed image decoding." >&2
  exit 1
fi

if [ "$(grep -Fc "private let maxImageDataBytes = 5 * 1024 * 1024" "$picture")" -ne 1 ] ||
  ! grep -Fq "imageData.length == 0 || imageData.length > self.maxImageDataBytes" "$picture" ||
  grep -Eq 'println\(|NSLog\(' "$picture"; then
  printf '%s\n' "Image decoding must enforce the reviewed 5 MiB data boundary without logging remote content." >&2
  exit 1
fi

python3 - "$picture" <<'PY'
import re
import sys
from pathlib import Path

source = Path(sys.argv[1]).read_text()
limits = re.findall(r"private let maxImageDataBytes = ([^\n]+)", source)
if limits != ["5 * 1024 * 1024"]:
    raise SystemExit("Picture must define one exact 5 MiB image-data limit.")

contract = (
    "if let imageData = data",
    "imageData.length == 0 || imageData.length > self.maxImageDataBytes",
    "UIImage(data: imageData)",
    "handler(image: image, error)",
)
positions = [source.find(fragment) for fragment in contract]
if -1 in positions or positions != sorted(positions) or len(set(positions)) != len(positions):
    raise SystemExit("Image byte validation must remain ahead of UIKit decoding and callbacks.")
PY

if ! grep -Fq "*.xcconfig" "$ROOT_DIR/.gitignore" ||
  ! grep -Fq ".env" "$ROOT_DIR/.gitignore"; then
  printf '%s\n' "Local API and signing config files must stay ignored." >&2
  exit 1
fi

if command -v xcodebuild >/dev/null 2>&1; then
  xcodebuild -list -project "$ROOT_DIR/Finn.xcodeproj" >/dev/null
else
  printf '%s\n' "Skipping xcodebuild project listing: xcodebuild is not installed."
fi

if ! awk '
  /^[[:space:]]*uses:[[:space:]]*actions\/checkout@/ {
    checkout_count++
    if ($0 == "        uses: actions/checkout@df4cb1c069e1874edd31b4311f1884172cec0e10 # v6.0.3") {
      checkout_state = 1
    } else {
      invalid = 1
    }
    next
  }

  /^[[:space:]]*persist-credentials[[:space:]]*:/ {
    credential_count++
  }

  /^        with:[[:space:]]*(#.*)?$/ {
    with_count++
  }

  checkout_state == 1 && /^[[:space:]]*(#.*)?$/ {
    next
  }

  checkout_state == 1 {
    if ($0 == "        with:") {
      checkout_state = 2
    } else {
      invalid = 1
      checkout_state = 0
    }
    next
  }

  checkout_state == 2 && /^[[:space:]]*(#.*)?$/ {
    next
  }

  checkout_state == 2 {
    if ($0 == "          persist-credentials: false") {
      credential_contract_count++
    } else {
      invalid = 1
    }
    checkout_state = 0
  }

  END {
    if (checkout_count != 1 || with_count != 1 || credential_count != 1 ||
        credential_contract_count != 1 || invalid != 0) {
      exit 1
    }
  }
' "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions checkout must be uniquely pinned with credential persistence disabled." >&2
  exit 1
fi

if ! grep -Fq "workflow_dispatch:" "$CI_WORKFLOW" ||
  ! grep -Fq "contents: read" "$CI_WORKFLOW" ||
  ! grep -Fq "cancel-in-progress: true" "$CI_WORKFLOW" ||
  ! grep -Fq "runs-on: macos-15" "$CI_WORKFLOW" ||
  ! grep -Fq "timeout-minutes: 10" "$CI_WORKFLOW" ||
  ! grep -Fq "run: make check" "$CI_WORKFLOW"; then
  printf '%s\n' "GitHub Actions must keep the bounded, least-privilege macOS check contract." >&2
  exit 1
fi

if ! grep -Fq "GitHub Actions" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "no persisted checkout credentials" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "GitHub Actions" "$ROOT_DIR/CHANGES.md" ||
  ! grep -Fq "without persisted checkout credentials" "$ROOT_DIR/README.md" ||
  ! grep -Fq "docs/plans/2026-06-10-hosted-project-validation.md" "$ROOT_DIR/README.md"; then
  printf '%s\n' "Project docs must record the hosted project validation baseline." >&2
  exit 1
fi

if ! grep -Fq "larger than 5 MiB are rejected before UIKit decoding" "$ROOT_DIR/README.md" ||
  ! grep -Fq "still buffers the full response" "$ROOT_DIR/README.md" ||
  ! grep -Fq "image data over 5 MiB should be rejected before UIKit decoding" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "still buffers the whole response" "$ROOT_DIR/SECURITY.md" ||
  ! grep -Fq "image decoding rejects empty data and payloads over 5 MiB" "$ROOT_DIR/VISION.md" ||
  ! grep -Fq "Rejected empty and over-5-MiB restaurant image data" "$ROOT_DIR/CHANGES.md"; then
  printf '%s\n' "Project docs must record the image decode boundary and legacy buffering limitation." >&2
  exit 1
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

if ! grep -Fq "status: completed" "$IMAGE_URL_PARTS_PLAN"; then
  printf '%s\n' "Image URL parts guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$COORDINATE_RANGE_PLAN"; then
  printf '%s\n' "API coordinate range guard plan must be marked completed." >&2
  exit 1
fi

if ! grep -Fq "make check" "$IMAGE_URL_PARTS_PLAN"; then
  printf '%s\n' "Image URL parts guard plan must record make check verification." >&2
  exit 1
fi

if ! grep -Fq "status: completed" "$CI_PLAN" ||
  ! grep -Fq "make check" "$CI_PLAN"; then
  printf '%s\n' "Hosted project validation plan must be completed and record verification." >&2
  exit 1
fi

python3 - "$BRIDGING_HEADER_PLAN" <<'PY'
import re
import sys
from pathlib import Path

plan = Path(sys.argv[1]).read_text()
frontmatter = plan.split("---", 2)[1]
statuses = re.findall(r"^status: .+$", frontmatter, flags=re.MULTILINE)
verification = plan.split("## Verification Completed\n", 1)[-1]
required = (
    "all four Make gates",
    "push run `27392252049`",
    "pull-request run `27392255196`",
    "push run `27392268849`",
    "CodeQL run `27402319989`",
)

if (
    statuses != ["status: completed"]
    or any(item not in verification for item in required)
    or re.search(r"\b(?:pending|todo|tbd|not run)\b", verification, re.IGNORECASE)
):
    raise SystemExit(
        "Portable bridging header plan must remain completed with actual verification recorded."
    )
PY

python3 - "$IMAGE_PAYLOAD_PLAN" <<'PY'
import re
import sys
from pathlib import Path

plan = Path(sys.argv[1]).read_text()
frontmatter = plan.split("---", 2)[1]
statuses = re.findall(r"^status: .+$", frontmatter, flags=re.MULTILINE)
required = (
    "size guard mutation failed",
    "limit drift mutation failed",
    "decode ordering mutation failed",
    "hosted pull-request check",
)

if statuses != ["status: completed"] or any(item not in plan for item in required):
    raise SystemExit(
        "Image decode payload plan must record completed status and actual verification."
    )
PY

printf '%s\n' "finn maintenance baseline checks passed."
