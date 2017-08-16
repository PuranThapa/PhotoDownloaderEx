//
//  PhotoOperations.swift
//  PhotoDownloader
//
//  Created by Puran Thapa on 15/08/2017.
//  Copyright © 2017 teamglobal. All rights reserved.
//

import Foundation
import UIKit

enum PhotoRecordState {
    case New, Downloaded, Failed, UserCanceled, Downloading
}

//MARK:- Model class for photos record
class PhotoRecord {
    
    var url: URL! = nil
    var state = PhotoRecordState.New
    var image = UIImage(named: "Placeholder")
    
    init(url: URL) {
        
        self.url = url
        
    }
    
}

//MARK:- For manage downloading operation
class PendingOperations {
    
    lazy var downloadInPregresss = [IndexPath:Operation]()
    lazy var downloadQueue: OperationQueue = {
       var queue = OperationQueue()
       queue.name = "Download queue"
       queue.maxConcurrentOperationCount = 1
       return queue
    }()
    
}

//MARK:- download image from the web
class ImageDownloader: Operation {
    
    var photoRecord: PhotoRecord?
    
    init(photoRecord: PhotoRecord) {
        self.photoRecord = photoRecord
    }
    
    override func main() {
        
        if self.isCancelled {
            return
        }
        
        // start downloading
        self.photoRecord?.state = .Downloading
        let imageData = try! Data(contentsOf: (self.photoRecord?.url)!)
        
        if self.isCancelled {
            return
        }
        
        if imageData.count > 0 {
            
            self.photoRecord?.image = self.resizeImage(image: UIImage(data: imageData)!) 
            self.photoRecord?.state = .Downloaded
            
        }
        else
        {
            self.photoRecord?.state = .Failed
            self.photoRecord?.image = UIImage(named: "Failed")
        }
        
    }
    
    func resizeImage(image: UIImage) -> UIImage {
      let imageData = UIImageJPEGRepresentation(image, 0.5)
        return UIImage(data: imageData!)!
    }
    
}


class PhotoCache {
    
      var library = NSCache<AnyObject, AnyObject>()
      static let shared = PhotoCache()
      private init() {
        library.countLimit = 20
        
      }
    
}

extension UIImageView {
    
    //MARK:- Only for simple image view not for that imageview which is on tableView
    func setImageWith(url: URL) {
        
        if let photoDetails = PhotoCache.shared.library.object(forKey: url.relativePath as AnyObject) as? PhotoRecord{
            if photoDetails.state == .Downloaded {
                
             self.image = photoDetails.image!   
                
            }
            else
            {
                DispatchQueue.global().async {
                    
                    let data = try? Data(contentsOf: url)
                    DispatchQueue.main.async {
                         photoDetails.state = .Downloaded
                        photoDetails.image = UIImage(data: data!)
                        self.image = UIImage(data: data!)
                        
                    }
                    
                }
            }
        }
        else
        {
            DispatchQueue.global().async {
                
                let data = try? Data(contentsOf: url)
                DispatchQueue.main.async {
                    
                    self.image = UIImage(data: data!)
                    
                }
                
            }
        }
    }
    
}
