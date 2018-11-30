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

class overviewNavMasterViewController: UIViewController, CLLocationManagerDelegate {
    
    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var addedToDos = [NSManagedObject]()
    var addedImages = [NSManagedObject]()
    var selectedHotspot: HotspotMO?
    
    var latitude:Double = 0.0
    var longitude:Double = 0.0
    
    var contactNumber:String = "6041234567"
    
    var navigationVC : navigationViewController = navigationViewController()

    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet var overviewNavControl: UISegmentedControl!
    @IBOutlet weak var overviewContainer: UIView!
    @IBOutlet var navigationContainer: UIView!
    @IBOutlet weak var emergency: UIButton!
    
    
    //===================================================================================================
    // MARK: Actions
    //===================================================================================================
    @IBAction func changedSegment(_ sender: UISegmentedControl) {
        
        // Hide one of the container views based on current segmented control selection
        if (sender.selectedSegmentIndex == 0) {
            self.overviewContainer.isHidden = false
            self.navigationContainer.isHidden = true
            
            /*
            navigationVC.directionsTableView.isHidden = false
            navigationVC.mapOrDirectionsControl.isHidden = false
            */
 
        }
        else {
            self.overviewContainer.isHidden = true
            self.navigationContainer.isHidden = false
            
            let status = CLLocationManager.authorizationStatus()
            if (status == CLAuthorizationStatus.denied) {
                // Create the alert
                let alert = UIAlertController(title: "Locations Permissions Denied", message: "Please enable locations services in the Settings app.", preferredStyle: .alert)
                
                let cancelAction = UIAlertAction(title: "Done", style: .cancel) {
                    (action:UIAlertAction) in
                    print ("pressed Cancel")
                }
                
                // Add actions to alert
                alert.addAction(cancelAction)
                
                // Show the alert
                self.present(alert,animated: true, completion: nil)
            }
        }
    }
    
    // Call the emergency contact when the emergency button is pressed
    @IBAction func emergencyPressed(_ sender: Any) {
        print("entered")
        // Retrieve emergency contact information
        let contactNumber = "6041234567"
        let url = URL(string: "tel://\(contactNumber)")
        UIApplication.shared.open(url!)
    }
    
    //===================================================================================================
    // MARK: Functions
    //===================================================================================================
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        navigationVC = navigationViewController()
        
        
        // Change appearance for segmented control
        overviewNavControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        overviewNavControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // Update navigation bar title with hotspot name
        self.title = ((selectedHotspot?.value(forKey: "name")) as? String)
        
        // Add Emergency Contact Button to navigation bar
        let eImage = UIImage(named: "emergency")!.withRenderingMode(UIImageRenderingMode.alwaysOriginal)
        let eButton: UIBarButtonItem = UIBarButtonItem(image: eImage, style: .plain, target: self, action: #selector(emergencyPressed(_:)))
        self.navigationItem.rightBarButtonItem = eButton
      

        let hotspot = selectedHotspot
        if ((hotspot?.info == nil || (hotspot?.info?.isEmpty)!) && hotspot?.toDo?.count == 0 && hotspot?.photos?.count == 0){

            self.overviewContainer.isHidden = true
            self.navigationContainer.isHidden = false
            overviewNavControl.removeSegment(at:0, animated: true)
            overviewNavControl.isUserInteractionEnabled = false
        }
        

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
