import Foundation
import UIKit

class Picture{

    func get(url: NSURL, handler: ((image: UIImage, NSError!) -> Void))
    {
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
