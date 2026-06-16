import Foundation

let RestaurantAPIResponseMaxBytes = 1024 * 1024

let acceptsRestaurantAPIResponseValues: (Int?, String?, Int?) -> Bool = {
    statusCode, MIMEType, dataLength in

    if statusCode != 200 {
        return false
    }

    if let MIMEType = MIMEType {
#if EXECUTABLE_POLICY_TESTS
        let normalizedMIMEType = MIMEType.lowercased()
#else
        let normalizedMIMEType = MIMEType.lowercaseString
#endif
        if normalizedMIMEType != "application/json" {
            return false
        }
    } else {
        return false
    }

    if let dataLength = dataLength {
        return dataLength >= 0 && dataLength <= RestaurantAPIResponseMaxBytes
    }

    return false
}
