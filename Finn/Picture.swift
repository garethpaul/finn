import Foundation
import UIKit
import ImageIO

class Picture: NSObject, NSURLConnectionDataDelegate {

    private let maxImageDataBytes = RestaurantImageMaxDataBytes
    private let requestTimeout: NSTimeInterval = 15
    private var activeConnection: NSURLConnection?
    private var receivedData = NSMutableData()
    private var completionHandler: ((image: UIImage, NSError!) -> Void)?

    func get(url: NSURL, handler: ((image: UIImage, NSError!) -> Void))
    {
        cancel()

        if !isAllowedRestaurantImageURL(url) {
            return
        }

        let imageRequest = NSMutableURLRequest(URL: url)
        imageRequest.timeoutInterval = requestTimeout
        receivedData = NSMutableData()
        completionHandler = handler

        if let connection = NSURLConnection(request: imageRequest, delegate: self, startImmediately: false) {
            activeConnection = connection
            connection.start()
        } else {
            resetState()
        }
    }

    func cancel() {
        activeConnection?.cancel()
        resetState()
    }

    func connection(connection: NSURLConnection!, willSendRequest request: NSURLRequest!, redirectResponse response: NSURLResponse!) -> NSURLRequest! {
        if !isActiveConnection(connection) {
            return nil
        }

        if response != nil {
            connection.cancel()
            resetState()
            return nil
        }

        return request
    }

    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        if !isActiveConnection(connection) {
            return
        }

        receivedData.length = 0
        responseMIMEType = response?.MIMEType
        if !isImageResponse(response) {
            connection.cancel()
            resetState()
            return
        }

        if response.expectedContentLength > Int64(maxImageDataBytes) {
            connection.cancel()
            resetState()
        }
    }

    func connection(connection: NSURLConnection!, didReceiveData data: NSData!) {
        if !isActiveConnection(connection) {
            return
        }

        if data.length > maxImageDataBytes ||
            receivedData.length > maxImageDataBytes - data.length {
            connection.cancel()
            resetState()
            return
        }

        receivedData.appendData(data)
    }

    func connectionDidFinishLoading(connection: NSURLConnection!) {
        if !isActiveConnection(connection) {
            return
        }

        let handler = completionHandler
        if receivedData.length > 0 && acceptsRestaurantImageMetadata(responseMIMEType, data: receivedData),
            let image = UIImage(data: receivedData) {
            resetState()
            handler?(image: image, nil)
        } else {
            resetState()
        }
    }

    func connection(connection: NSURLConnection!, didFailWithError error: NSError!) {
        if isActiveConnection(connection) {
            resetState()
        }
    }

    private func isActiveConnection(connection: NSURLConnection) -> Bool {
        if let currentConnection = activeConnection {
            return connection === currentConnection
        }

        return false
    }

    private func isImageResponse(response: NSURLResponse?) -> Bool {
        var statusCode: Int?
        if let httpResponse = response as? NSHTTPURLResponse {
            statusCode = httpResponse.statusCode
        }

        return acceptsRestaurantImageResponseValues(
            statusCode,
            response?.MIMEType,
            response?.expectedContentLength ?? -2
        )
    }

    private var responseMIMEType: String?

    private func acceptsRestaurantImageMetadata(MIMEType: String?, data: NSData) -> Bool {
        if let source = CGImageSourceCreateWithData(data, nil),
            properties = CGImageSourceCopyPropertiesAtIndex(source, 0, nil) as? NSDictionary,
            width = properties.objectForKey(kCGImagePropertyPixelWidth) as? NSNumber,
            height = properties.objectForKey(kCGImagePropertyPixelHeight) as? NSNumber {
            return acceptsRestaurantImageMetadataValues(MIMEType, width.integerValue, height.integerValue)
        }

        return false
    }

    private func resetState() {
        activeConnection = nil
        completionHandler = nil
        responseMIMEType = nil
        receivedData.length = 0
    }

    deinit {
        cancel()
    }
}
