#!/usr/bin/env python3
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path


root = Path(__file__).resolve().parent.parent
swiftc = shutil.which("swiftc")
if not swiftc:
    raise SystemExit("swiftc unavailable; Finn boundary mutations require the native policy compiler")


def run(command, cwd):
    return subprocess.run(
        command,
        cwd=cwd,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
    )


def copy_fixture(destination):
    for relative in (
        "Finn/API.swift",
        "Finn/LocationLookupPolicy.swift",
        "Finn/Picture.swift",
        "Finn/RemoteImagePolicy.swift",
        "Finn/RestaurantAPIResponsePolicy.swift",
        "Finn/FinnPickerView.swift",
        "Finn/ViewController.swift",
        "Tests/FinnBoundaryPolicyTests/main.swift",
        "scripts/test-finn-network-boundaries.py",
    ):
        target = destination / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        shutil.copy2(root / relative, target)


def mutate(path, old, new):
    source = path.read_text(encoding="utf-8")
    if old not in source:
        raise SystemExit("mutation target missing: " + old)
    path.write_text(source.replace(old, new, 1), encoding="utf-8")


native_mutations = (
    ("Finn/LocationLookupPolicy.swift", "RestaurantLocationMaxAge: Double = 30", "RestaurantLocationMaxAge: Double = 300"),
    ("Finn/RemoteImagePolicy.swift", 'normalizedHost == "localhost" || ', ""),
    ("Finn/RemoteImagePolicy.swift", "let RestaurantImageMaxDimension = 4096", "let RestaurantImageMaxDimension = 8192"),
    ("Finn/RestaurantAPIResponsePolicy.swift", "return currentLength >= 0 && incomingLength >= 0 &&", "return true ||"),
)

static_mutations = (
    ("Finn/API.swift", "if !isActiveConnection(connection) {", "if false {"),
    ("Finn/Picture.swift", "acceptsRestaurantImageMetadata(responseMIMEType, data: receivedData)", "true"),
    ("Finn/ViewController.swift", "        api.cancel()", "        // api cancellation removed"),
)

with tempfile.TemporaryDirectory(prefix="finn-boundary-mutations.") as temporary:
    temporary_root = Path(temporary)
    for index, (relative, old, new) in enumerate(native_mutations, 1):
        fixture = temporary_root / f"native-{index}"
        copy_fixture(fixture)
        mutate(fixture / relative, old, new)
        result = run(
            [
                swiftc,
                "-D",
                "EXECUTABLE_POLICY_TESTS",
                "Finn/RestaurantAPIResponsePolicy.swift",
                "Finn/LocationLookupPolicy.swift",
                "Finn/RemoteImagePolicy.swift",
                "Tests/FinnBoundaryPolicyTests/main.swift",
                "-o",
                "boundary-tests",
            ],
            fixture,
        )
        if result.returncode == 0:
            executed = run([str(fixture / "boundary-tests")], fixture)
            if executed.returncode == 0:
                raise SystemExit(f"native mutation {index} survived")

    for index, (relative, old, new) in enumerate(static_mutations, 1):
        fixture = temporary_root / f"static-{index}"
        copy_fixture(fixture)
        mutate(fixture / relative, old, new)
        result = run(
            [
                sys.executable,
                "scripts/test-finn-network-boundaries.py",
                "Finn/API.swift",
                "Finn/Picture.swift",
                "Finn/FinnPickerView.swift",
                "Finn/ViewController.swift",
            ],
            fixture,
        )
        if result.returncode == 0:
            raise SystemExit(f"static mutation {index} survived")

print("Finn boundary mutations rejected (7 cases)")
