import Foundation

private var failureCount = 0

private func expect(_ statusCode: Int?, _ MIMEType: String?, _ dataLength: Int?, _ expected: Bool, _ message: String) {
    let actual = acceptsRestaurantAPIResponseValues(statusCode, MIMEType, dataLength)
    if actual != expected {
        failureCount += 1
        print("FAIL: \(message): expected \(expected), got \(actual)")
    }
}

expect(200, "application/json", 0, true, "empty JSON response")
expect(200, "APPLICATION/JSON", RestaurantAPIResponseMaxBytes, true, "case-insensitive MIME and size boundary")
expect(nil, "application/json", 1, false, "missing HTTP status")
expect(201, "application/json", 1, false, "created status")
expect(204, "application/json", 0, false, "no-content status")
expect(302, "application/json", 1, false, "redirect status")
expect(400, "application/json", 1, false, "client error status")
expect(500, "application/json", 1, false, "server error status")
expect(200, nil, 1, false, "missing MIME type")
expect(200, "text/html", 1, false, "non-JSON MIME type")
expect(200, "application/json", nil, false, "missing response data")
expect(200, "application/json", -1, false, "negative response length")
expect(200, "application/json", RestaurantAPIResponseMaxBytes + 1, false, "oversize response")

if failureCount > 0 {
    exit(1)
}

print("RestaurantAPIResponsePolicy behavioral tests passed")
