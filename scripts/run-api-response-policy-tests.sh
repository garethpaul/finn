#!/bin/sh
set -eu

ROOT=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
SWIFTC=${SWIFTC:-swiftc}
BUILD_DIR=$(mktemp -d "${TMPDIR:-/tmp}/finn-api-response-tests.XXXXXX")

cleanup() {
    rm -rf -- "$BUILD_DIR"
}
trap cleanup 0
trap 'exit 129' 1
trap 'exit 130' 2
trap 'exit 143' 15

"$SWIFTC" \
    "$ROOT/Finn/RestaurantAPIResponsePolicy.swift" \
    "$ROOT/Tests/RestaurantAPIResponsePolicyTests/main.swift" \
    -o "$BUILD_DIR/restaurant-api-response-tests"

"$BUILD_DIR/restaurant-api-response-tests"
