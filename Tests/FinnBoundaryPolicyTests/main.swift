import Foundation

var failures = 0

let expect: (Bool, Bool, String) -> Void = { actual, expected, message in
    if actual != expected {
        print("FAIL: \(message): expected \(expected), got \(actual)")
        failures += 1
    }
}

expect(acceptsRestaurantLocationValues(37.78, -122.42, 10, 1), true, "fresh accurate location")
expect(acceptsRestaurantLocationValues(Double.nan, -122.42, 10, 1), false, "NaN latitude")
expect(acceptsRestaurantLocationValues(37.78, Double.infinity, 10, 1), false, "infinite longitude")
expect(acceptsRestaurantLocationValues(91, -122.42, 10, 1), false, "latitude range")
expect(acceptsRestaurantLocationValues(37.78, -181, 10, 1), false, "longitude range")
expect(acceptsRestaurantLocationValues(37.78, -122.42, -1, 1), false, "invalid accuracy")
expect(acceptsRestaurantLocationValues(37.78, -122.42, 1501, 1), false, "inaccurate fix")
expect(acceptsRestaurantLocationValues(37.78, -122.42, 10, -1), false, "future fix")
expect(acceptsRestaurantLocationValues(37.78, -122.42, 10, 31), false, "stale fix")

expect(isAllowedRestaurantImageHost("images.example.com"), true, "public hostname")
expect(isAllowedRestaurantImageHost("fd.example.com"), true, "hostname beginning with IPv6 letters")
expect(isAllowedRestaurantImageHost("LOCALHOST"), false, "localhost")
expect(isAllowedRestaurantImageHost("api.localhost"), false, "localhost suffix")
expect(isAllowedRestaurantImageHost("127.0.0.1"), false, "IPv4 loopback")
expect(isAllowedRestaurantImageHost("10.1.2.3"), false, "IPv4 private")
expect(isAllowedRestaurantImageHost("169.254.1.2"), false, "IPv4 link local")
expect(isAllowedRestaurantImageHost("192.168.1.2"), false, "IPv4 private LAN")
expect(isAllowedRestaurantImageHost("::1"), false, "IPv6 loopback")
expect(isAllowedRestaurantImageHost("::ffff:127.0.0.1"), false, "IPv4-mapped IPv6 loopback")
expect(isAllowedRestaurantImageHost("fd00::1"), false, "IPv6 unique local")
expect(isAllowedRestaurantImageHost("fe80::1"), false, "IPv6 link local")

expect(acceptsRestaurantImageMetadataValues("image/jpeg", 1024, 1024), true, "bounded JPEG")
expect(acceptsRestaurantImageMetadataValues("image/png", 4096, 4096), true, "maximum PNG")
expect(acceptsRestaurantImageMetadataValues("image/svg+xml", 100, 100), false, "active vector type")
expect(acceptsRestaurantImageMetadataValues("image/jpeg", 0, 100), false, "zero width")
expect(acceptsRestaurantImageMetadataValues("image/jpeg", 4097, 1), false, "oversized dimension")
expect(acceptsRestaurantImageMetadataValues("image/jpeg", 4096, 4097), false, "pixel bomb")
expect(acceptsRestaurantImageResponseValues(200, "image/jpeg", -1), true, "chunked JPEG")
expect(acceptsRestaurantImageResponseValues(404, "image/jpeg", 100), false, "image HTTP error")
expect(acceptsRestaurantImageResponseValues(302, "image/png", 100), false, "image redirect status")
expect(acceptsRestaurantImageResponseValues(200, "image/svg+xml", 100), false, "active image media")
expect(acceptsRestaurantImageResponseValues(200, "image/jpeg", -2), false, "invalid image length")
expect(acceptsRestaurantImageResponseValues(200, "image/jpeg", 5 * 1024 * 1024 + 1), false, "declared image overflow")

expect(acceptsRestaurantAPIResponseHeadersValues(200, "application/json", -1), true, "chunked JSON")
expect(acceptsRestaurantAPIResponseHeadersValues(200, "application/json; charset=utf-8", 1024), true, "JSON charset")
expect(acceptsRestaurantAPIResponseHeadersValues(200, "text/json", 1024), false, "wrong API media type")
expect(acceptsRestaurantAPIResponseHeadersValues(302, "application/json", 10), false, "API redirect")
expect(acceptsRestaurantAPIResponseHeadersValues(200, "application/json", Int64(RestaurantAPIResponseMaxBytes + 1)), false, "declared API overflow")
expect(canAppendRestaurantAPIBytes(100, 50), true, "bounded API chunk")
expect(canAppendRestaurantAPIBytes(RestaurantAPIResponseMaxBytes, 1), false, "streamed API overflow")
expect(canAppendRestaurantAPIBytes(0, -1), false, "negative API chunk")

if failures != 0 {
    exit(1)
}

print("Finn boundary policy tests passed")
