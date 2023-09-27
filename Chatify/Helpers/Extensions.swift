//
//  Extensions.swift
//  Chatify
//
//  Created by Amr Mohamad on 26/09/2023.
//

import UIKit

let imagesCache = NSCache<AnyObject, AnyObject>()

extension UIImageView {
    
    ///For loading images of profiles and if it's downloaded befor, it will be cached and fetching it from the cache
    ///- Parameter urlString: its for getting a URL for download the image from Firebase storage and for used as a key when come to store the downloaded image into cache ``imagesCache``
    func loadImagefromCacheWithURLstring(urlString: String){
        //For clear imageview of the previous cell because UITableViewController reuse the unseen cells
        self.image = nil
        
        //For fetch images from the cache
        if let cachedImage = imagesCache.object(
            forKey: NSString(string: urlString)
        ) as? UIImage {
            DispatchQueue.main.async {
                self.image = cachedImage
            }
            return
        }
        // if the image not downloaded before or a new user is added the image will be download from internet
        URLSession.shared.dataTask(
            with: URL(string: urlString)!
        ) { data, response, error in
            if let d = data {
                DispatchQueue.main.async {
                    if let downloadedImage = UIImage(data: d) {
                        imagesCache.setObject(downloadedImage, forKey: NSString(string: urlString))
                        self.image = downloadedImage
                    }
                }
            }
        }.resume()
    }
    
}
