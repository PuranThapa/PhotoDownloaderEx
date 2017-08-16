//
//  ListViewController.swift
//  PhotoDownloader
//
//  Created by Puran Thapa on 15/08/2017.
//  Copyright © 2017 teamglobal. All rights reserved.
//

import UIKit
import CoreImage

let dataSourceURL = URL(string: "https://pastebin.com/raw/fszMUw3w")

class ListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tblView: UITableView!
   // var photos = [PhotoRecord]()//NSDictionary(contentsOf: dataSourceURL!)
    let pendingOperations = PendingOperations()
    var photos = [[String: URL]]()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Classic Photos"
        fetchPhotoDetails()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//MARK:- tableview methods
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (photos.count)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.performSegue(withIdentifier: "sendToSingleImageShowVC", sender: Array(photos[indexPath.row].values)[0])
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier", for: indexPath)
        
        let photoDetails =  photos[indexPath.row] //photos[indexPath.row]
        cell.textLabel?.text = Array(photoDetails.keys)[0]
        //cell.imageView?.image = photoDetails.image
        let url = Array(photoDetails.values)[0]
        
        if cell.accessoryView == nil {
            
            let button = UIButton(frame: CGRect(x: UIScreen.main.bounds.size.width - 70, y: (cell.frame.size.height/2)-10, width: 60, height: 20))
            button.setTitle("Cancel", for: .normal)
            button.setTitleColor(UIColor.blue, for: .normal)
            button.layer.setValue(indexPath, forKey: "indexPath")
            button.addTarget(self, action: #selector(cancelDownloadImage(sender:)), for: .touchUpInside)
            cell.accessoryView = button
            
        }
        
        if let details = PhotoCache.shared.library.object(forKey: (url.relativePath) as AnyObject) as? PhotoRecord {
            if details.state == .Downloaded {
             
                cell.imageView?.image = details.image
                
            }
            
        }
        else
        {
            
            let record = PhotoRecord(url: url)
            startDownloadImage(photoDetail: record, indexPath: indexPath)
            PhotoCache.shared.library.setObject(record, forKey: (url.relativePath) as AnyObject)
            
        }
        
        return cell
    }
    
    //MARK:- cancel download image
    func cancelDownloadImage(sender: UIButton) {
        
        print(sender.layer.value(forKey: "indexPath") as! IndexPath)
        let indexPath = sender.layer.value(forKey: "indexPath") as! IndexPath
       if let process = pendingOperations.downloadInPregresss[indexPath]
       {
             process.cancel()
        
       }
        
    }
    
    //MARK:- download image
    
    func startDownloadImage(photoDetail: PhotoRecord, indexPath: IndexPath) {
        
        if photoDetail.state == .New {
            
            if pendingOperations.downloadInPregresss[indexPath] != nil {
                return
            }
            
            let downloader = ImageDownloader(photoRecord: photoDetail)
            
            downloader.completionBlock = {
                if downloader.isCancelled {
                    return
                }
                
                self.performSelector(onMainThread: #selector(self.callingtabel(indexPath:)), with: indexPath, waitUntilDone: true)
            }
            
            pendingOperations.downloadInPregresss[indexPath] = downloader
            pendingOperations.downloadQueue.addOperation(downloader)
            
        }
        
    }
    
    func callingtabel(indexPath: IndexPath) {
        self.pendingOperations.downloadInPregresss.removeValue(forKey: indexPath)
        self.tblView.reloadRows(at: [indexPath], with: .fade)
    }
    
    //MARK:- download images list
    func fetchPhotoDetails() {
        
        let request = URLRequest(url: dataSourceURL!)
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let task = URLSession.shared.dataTask(with: request) {(data, response, error) in
           
            if data != nil {
            
        let dataArray =  try! JSONSerialization.jsonObject(with: data!, options: []) as! NSArray
                
            for oneValue in dataArray {
                
                let userdictionary = (oneValue as! NSDictionary).value(forKey: "links") as! NSDictionary
                print(userdictionary)
                let name =  ((oneValue as! NSDictionary).value(forKey: "user") as! NSDictionary).value(forKey: "name") as? String
                let url = URL(string: (((oneValue as! NSDictionary).value(forKey: "user") as! NSDictionary).value(forKey: "profile_image") as! NSDictionary).value(forKey: "large") as! String)
                if name != nil && url != nil {
                    
                    self.photos.append([name!:url!])
                    
                }
        
            }
                DispatchQueue.main.async {
                 
                    self.tblView.reloadData()
                    
                }
            }
            if error != nil {
                
                print("Error")
                
            }
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }
        task.resume()
    }
    
    //MARK:- segue prepare
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "sendToSingleImageShowVC" {
            
          let vc = segue.destination as! SingleImageShowVC
            vc.imgURL = sender as! URL
            
        }
        
    }
    
    
}
