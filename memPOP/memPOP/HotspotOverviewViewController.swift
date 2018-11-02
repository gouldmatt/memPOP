//
//  HotspotOverviewViewController.swift
//  memPOP
//
//  Created by Emily on 2018-10-23.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
import CoreData
import UIKit

class HotspotOverviewViewController: UIViewController {
    
    @IBOutlet var hotspotName: UILabel!
    @IBOutlet var hotspotTransportation: UILabel!
    @IBOutlet var hotspotDescription: UILabel!
    @IBOutlet var imageView: UIImageView!
    @IBOutlet var imageView2: UIImageView!
    @IBOutlet var imageView3: UIImageView!
    
    //@IBOutlet var hotspotImage: UIImageView!
    
    var addedImages = [NSManagedObject]()
    var selectedHotspot: NSManagedObject?
    
    override func viewDidLoad() {
        
        
        hotspotName.text = ((selectedHotspot?.value(forKey: "name")) as? String)
        hotspotTransportation.text = ((selectedHotspot?.value(forKey: "transportation")) as? String)
        hotspotDescription.text = ((selectedHotspot?.value(forKey: "info")) as? String)
        print(addedImages.count)
        
        
        let image = addedImages[0].value(forKey: "photo")
        imageView.image = (UIImage(data: image! as! Data)!)
        
        let image2 = addedImages[1].value(forKeyPath: "photo")
        imageView2.image = (UIImage(data: image2! as! Data)!)
        
        let image3 = addedImages[2].value(forKeyPath: "photo")
        imageView3.image = (UIImage(data: image3! as! Data)!)
        
        //let image = addedImages[0].value(forKey: "photo")

        // get image
        //let image = selectedHotspot?.value(forKey: "picture") as? NSData
        //hotspotImage.image = (UIImage(data: image! as Data)!)
        
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
