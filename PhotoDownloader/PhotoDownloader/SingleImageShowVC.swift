//
//  SingleImageShowVC.swift
//  PhotoDownloader
//
//  Created by Puran Thapa on 15/08/2017.
//  Copyright © 2017 teamglobal. All rights reserved.
//

import UIKit

class SingleImageShowVC: UIViewController {

    @IBOutlet weak var imgV_showImage: UIImageView!
    var imgURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imgV_showImage.setImageWith(url: imgURL!)
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
