import Foundation
import UIKit

class Picture: NSObject, NSURLConnectionDataDelegate {

    private let maxImageDataBytes = 5 * 1024 * 1024
    private let requestTimeout: NSTimeInterval = 15
    private var activeConnection: NSURLConnection?
    private var receivedData = NSMutableData()
    private var completionHandler: ((image: UIImage, NSError!) -> Void)?

    func get(url: NSURL, handler: ((image: UIImage, NSError!) -> Void))
    {
        cancel()

        if let scheme = url.scheme {
            if scheme != "https" {
                return
            }
        } else {
            return
        }

        if let host = url.host {
            if host.isEmpty {
                return
            }
        } else {
            return
        }

        if url.user != nil || url.password != nil {
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

    func connection(connection: NSURLConnection!, didReceiveResponse response: NSURLResponse!) {
        if !isActiveConnection(connection) {
            return
        }

        receivedData.length = 0
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
        if receivedData.length > 0, let image = UIImage(data: receivedData) {
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

    private func resetState() {
        activeConnection = nil
        completionHandler = nil
        receivedData.length = 0
    }

    deinit {
        cancel()
    }
}
