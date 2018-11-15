//
//  navigationViewController.swift
//  memPOP
//
//  Created by Matthew Gould   on 2018-11-10.
//  Programmer: Nicholas Lau
//  Copyright © 2018 Iota Inc. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class navigationViewController: UIViewController, CLLocationManagerDelegate {
    
    //===================================================================================================
    // Constants
    let locationManager = CLLocationManager()
    //===================================================================================================
    // Outlets
    @IBOutlet weak var mapOutlet: MKMapView!
    //===================================================================================================
    // Functions
    //===================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpLocationManager()
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setUpLocationManager() {
        // Get location permission from user
        self.locationManager.requestAlwaysAuthorization()
        
        
        // Check if location services enabled before starting
        if CLLocationManager.locationServicesEnabled(){
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // accuracy using gps
            
            //locationManager.distanceFilter = 10.0
            // meters update when past cetain distance using other methods
            //but realtime is better for navigation related purposes
            
            locationManager.delegate = self
            locationManager.startUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]){
        let userLoc = locations.last // get the last location available in the location array
        let viewLoc = MKCoordinateRegionMakeWithDistance((userLoc?.coordinate)!, 1000, 1000) // centre to user coord with x by y centering in meters
        self.mapOutlet.setRegion(viewLoc, animated: true)
    }

}
