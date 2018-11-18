//  overviewNavSelectViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Matthew Gould on 2018-11-10.
//  Programmers: Matthew Gould
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Changes that have been made in v2.0
// Created Master view controller to handle the switching of view between overview and navigation mode
// Added buttons to handle the transition events
// Added fetching support for passing information about hotspot selected between the views

import CoreData
import UIKit
import CoreLocation
import MapKit

class overviewNavMasterViewController: UIViewController {
    
    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var addedToDos = [NSManagedObject]()
    var addedImages = [NSManagedObject]()
    var selectedHotspot: NSManagedObject?
    
    var latitude:Double = 0.0
    var longitude:Double = 0.0

    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet var overviewNavControl: UISegmentedControl!
    @IBOutlet weak var overviewContainer: UIView!
    @IBOutlet var navigationContainer: UIView!
    
    //===================================================================================================
    // MARK: Actions
    //===================================================================================================
    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        
        // Hide one of the container views based on current segmented control selection
        if sender.selectedSegmentIndex == 0 {
            self.overviewContainer.isHidden = false
            self.navigationContainer.isHidden = true
        }
        else {
            self.overviewContainer.isHidden = true
            self.navigationContainer.isHidden = false
        }
    }

    //===================================================================================================
    // MARK: Functions
    //===================================================================================================
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Change appearance for segmented control
        overviewNavControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        overviewNavControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // Update navigation bar title with hotspot name
        self.title = ((selectedHotspot?.value(forKey: "name")) as? String)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        
        // Pass the selected hotspot information to the hotspot overview view controller
        if let controller = segue.destination as? HotspotOverviewViewController, segue.identifier == "showOverview" {
            controller.addedToDos = addedToDos
            controller.addedImages = addedImages
            controller.selectedHotspot = selectedHotspot
        }
        
        // Pass the selected hotspot information to the navigation view controller
        if let controller = segue.destination as? navigationViewController, segue.identifier == "showNav" {
            controller.selectedHotspot = selectedHotspot
        }
    }
    
}
