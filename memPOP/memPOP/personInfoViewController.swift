//  personInfoViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-24.
//  Programmers:
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Changes that have been made in v2.0


import CoreData
import UIKit

class personInfoViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        //let fetchRequest: NSFetchRequest<HotspotMO> = HotspotMO.fetch
        //let hotspots = try PersistenceService.context.fetch(fetchRequest)
        
        let newHotspot = HotspotMO(context: PersistenceService.context)
        let newPhoto = PhotosMO(context: PersistenceService.context)
        
        newPhoto.photo = UIImageJPEGRepresentation((UIImage(named: "home"))!, 1)! as NSData
        
        newHotspot.name = "Home"
        newHotspot.address = "123456 Some Street"
        
        newHotspot.addToPhotos(newPhoto)
        PersistenceService.saveContext()
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
