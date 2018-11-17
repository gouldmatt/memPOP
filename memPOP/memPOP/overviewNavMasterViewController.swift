//
//  overviewNavSelectViewController.swift
//  memPOP
//
//  Created by Matthew Gould   on 2018-11-10.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
// 
import CoreData
import UIKit
import CoreLocation
import MapKit


class overviewNavMasterViewController: UIViewController {
    
    //===================================================================================================
    // Variables declaration
    //===================================================================================================
    var addedToDos = [NSManagedObject]()
    var addedImages = [NSManagedObject]()
    var selectedHotspot: NSManagedObject?
    
    //let locationManager = CLLocationManager()

    //===================================================================================================
    // Outlets
    //===================================================================================================
    @IBOutlet var overviewNavControl: UISegmentedControl!
    @IBOutlet weak var overviewContainer: UIView!
    @IBOutlet var navigationContainer: UIView!
    
    
    //===================================================================================================
    // Actions
    //===================================================================================================
    // Hide one of the container views based on current segmented control selection
    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.overviewContainer.isHidden = false
            self.navigationContainer.isHidden = true
        } else {
            self.overviewContainer.isHidden = true
            self.navigationContainer.isHidden = false
        }
    }

    //===================================================================================================
    // Functions
    //===================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
   
        
        // change appearance for segmented control
        overviewNavControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        overviewNavControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // Update navigation bar title with hotspot name
        self.title = ((selectedHotspot?.value(forKey: "name")) as? String)
    
    }
    
    // Pass the selected hotspot information to the hotspot overview 
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        
        if let controller = segue.destination as? HotspotOverviewViewController, segue.identifier == "showOverview" {
            controller.addedToDos = addedToDos
            controller.addedImages = addedImages
            controller.selectedHotspot = selectedHotspot
        }
        
        if let controller = segue.destination as? HotspotOverviewViewController, segue.identifier == "showNav" {
            controller.selectedHotspot = selectedHotspot
        }
        
    }
    

}
