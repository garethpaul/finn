#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SWIFTC=${SWIFTC:-swiftc}
BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/finn-boundary-tests.XXXXXX")

cleanup() {
    rm -rf -- "$BUILD_DIR"
}

trap cleanup 0 1 2 15

"$SWIFTC" \
    -D EXECUTABLE_POLICY_TESTS \
    "$ROOT/Finn/RestaurantAPIResponsePolicy.swift" \
    "$ROOT/Finn/LocationLookupPolicy.swift" \
    "$ROOT/Finn/RemoteImagePolicy.swift" \
    "$ROOT/Tests/FinnBoundaryPolicyTests/main.swift" \
    -o "$BUILD_DIR/finn-boundary-tests"

"$BUILD_DIR/finn-boundary-tests"
