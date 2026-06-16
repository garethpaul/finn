import Foundation

let RestaurantAPIResponseMaxBytes = 1024 * 1024

let acceptsRestaurantAPIResponseValues: (Int?, String?, Int?) -> Bool = {
    statusCode, MIMEType, dataLength in

    if statusCode != 200 {
        return false
    }

    if let MIMEType = MIMEType {
        if NSString(string: MIMEType).lowercaseString != "application/json" {
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
