#!/usr/bin/env python3
from pathlib import Path
import sys


if len(sys.argv) != 5:
    raise SystemExit(
        "usage: test-finn-network-boundaries.py API.swift Picture.swift "
        "FinnPickerView.swift ViewController.swift"
    )

api = Path(sys.argv[1]).read_text(encoding="utf-8")
picture = Path(sys.argv[2]).read_text(encoding="utf-8")
picker = Path(sys.argv[3]).read_text(encoding="utf-8")
view = Path(sys.argv[4]).read_text(encoding="utf-8")

required_api = (
    "class APIClient: NSObject, NSURLConnectionDataDelegate",
    "private var activeConnection: NSURLConnection?",
    "func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!)",
    "acceptsRestaurantAPIResponseHeaders(response)",
    "func connection(connection: NSURLConnection!, didReceiveData data: NSData!)",
    "canAppendRestaurantAPIBytes(receivedData.length, data.length)",
    "connectionDidFinishLoading",
    "parseRestaurants(receivedData)",
    "func cancel()",
)
for fragment in required_api:
    if fragment not in api:
        raise SystemExit("API streaming boundary missing: " + fragment)

if ".response {" in api or "responseObject as? NSData" in api:
    raise SystemExit("Restaurant API transport must not buffer through Alamofire response callbacks.")

redirect = api.split(
    "func connection(connection: NSURLConnection!, willSendRequest request: NSURLRequest!, redirectResponse response: NSURLResponse!)",
    1,
)[1].split("func connection(connection: NSURLConnection!, didReceiveResponse", 1)[0]
for fragment in (
    "if !isActiveConnection(connection)",
    "return nil",
    "if response != nil",
    "connection.cancel()",
    "finish([])",
):
    if fragment not in redirect:
        raise SystemExit("API redirect ownership missing: " + fragment)
if redirect.index("if !isActiveConnection(connection)") > redirect.index("if response != nil"):
    raise SystemExit("Stale API redirects must be rejected before current request state changes.")

required_picture = (
    "isAllowedRestaurantImageURL(url)",
    "CGImageSourceCreateWithData",
    "acceptsRestaurantImageMetadata",
)
for fragment in required_picture:
    if fragment not in picture:
        raise SystemExit("Image boundary missing: " + fragment)

image_finish = picture.split("func connectionDidFinishLoading", 1)[1].split(
    "func connection(connection: NSURLConnection!, didFailWithError", 1
)[0]
metadata_call = "acceptsRestaurantImageMetadata(responseMIMEType, data: receivedData)"
if metadata_call not in image_finish or image_finish.index(metadata_call) > image_finish.index("UIImage(data: receivedData)"):
    raise SystemExit("Image metadata limits must run before UIKit decoding.")

required_lifecycle = (
    "private let api = APIClient()",
    "private var lookupGeneration = 0",
    "acceptsRestaurantLocation(location)",
    "lookupGeneration += 1",
    "api.cancel()",
    "dispatch_async(dispatch_get_main_queue()",
)
for fragment in required_lifecycle:
    if fragment not in view:
        raise SystemExit("Location/request lifecycle boundary missing: " + fragment)

if "private let picture = Picture()" not in picker or "picture.cancel()" not in picker:
    raise SystemExit("Picker must own and cancel its image request.")


class FakeStream:
    def __init__(self, maximum):
        self.maximum = maximum
        self.received = 0
        self.cancelled = False

    def response(self, status, mime, declared):
        base_mime = mime.split(";", 1)[0].strip().lower() if mime else None
        if status != 200 or base_mime != "application/json":
            self.cancelled = True
        if declared < -1 or declared > self.maximum:
            self.cancelled = True

    def data(self, amount):
        if amount < 0 or self.received > self.maximum - amount:
            self.cancelled = True
            return
        if not self.cancelled:
            self.received += amount


valid = FakeStream(1024)
valid.response(200, "application/json; charset=utf-8", -1)
valid.data(512)
valid.data(512)
if valid.cancelled or valid.received != 1024:
    raise SystemExit("Valid chunked fake response must complete at the exact limit.")

overflow = FakeStream(1024)
overflow.response(200, "application/json", -1)
overflow.data(1024)
overflow.data(1)
if not overflow.cancelled or overflow.received != 1024:
    raise SystemExit("Unknown-length fake response must cancel before overflow append.")

for status, mime, declared in (
    (302, "application/json", 10),
    (200, "text/html", 10),
    (200, "application/json", 1025),
):
    stream = FakeStream(1024)
    stream.response(status, mime, declared)
    if not stream.cancelled:
        raise SystemExit("Invalid fake response headers must cancel transport.")

print("Finn fake-network boundary tests passed")
