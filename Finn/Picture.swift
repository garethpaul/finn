import Foundation
import UIKit

class Picture{

    func get(url: NSURL, handler: ((image: UIImage, NSError!) -> Void))
    {
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

        var imageRequest: NSURLRequest = NSURLRequest(URL: url)
        NSURLConnection.sendAsynchronousRequest(imageRequest,
            queue: NSOperationQueue.mainQueue(),
            completionHandler:{response, data, error in
                if error != nil {
                    return
                }

                if let imageData = data {
                    if let image = UIImage(data: imageData) {
                        handler(image: image, error)
                    }
                }
        })
    }
}
