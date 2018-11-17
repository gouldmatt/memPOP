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

class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(pinTitle:String, location:CLLocationCoordinate2D){
        self.title = pinTitle
        self.coordinate = location
    }
}

class navigationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //===================================================================================================
    // Constants
    let locationManager = CLLocationManager()
    //===================================================================================================
    // Outlets
    @IBOutlet weak var mapkitView: MKMapView!
    //===================================================================================================
    // Functions
    //===================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        setUpLocationManager()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        layoutRoute();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 5.0
        return renderer
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
        self.mapkitView.setRegion(viewLoc, animated: true)
    }
    
    func layoutRoute()
    {
        // Set up the mapkit with some conditions
        mapkitView.delegate = self
        mapkitView.showsScale = true
        mapkitView.showsCompass = true
        mapkitView.showsPointsOfInterest = true
        mapkitView.showsUserLocation = true
        
        let sourceCoordinates = locationManager.location?.coordinate
        //let sourceCoordinates = CLLocationCoordinate2DMake(49.2014, 122.7772)
        let destCoordinates = CLLocationCoordinate2DMake(49.1969, 122.7772)
        
        let sourcePin = customPin(pinTitle: " ", location: sourceCoordinates!)
        let destPin =   customPin(pinTitle: " ", location: destCoordinates)
        self.mapkitView.addAnnotation(sourcePin)
        self.mapkitView.addAnnotation(destPin)
        
        
        let sourcePlacemark = MKPlacemark(coordinate: (sourceCoordinates!))
        let destPlacemark = MKPlacemark(coordinate: destCoordinates)
        
        let sourceItem = MKMapItem(placemark: sourcePlacemark)
        let destItem = MKMapItem(placemark: destPlacemark)
        
        let directionRequest = MKDirectionsRequest()
        directionRequest.source = sourceItem
        directionRequest.destination = destItem
        directionRequest.transportType = .walking
        
        let directions = MKDirections(request: directionRequest)
        directions.calculate(completionHandler: {
            response, error in
            
            guard let response = response else {
                if let error = error {
                    print("error ==\(error.localizedDescription)")
                }
                return
            }
            
            // fastest route
            let route = response.routes[0]
            self.mapkitView.add(route.polyline, level: .aboveRoads)
            
            let rekt = route.polyline.boundingMapRect
            self.mapkitView.setRegion(MKCoordinateRegionForMapRect(rekt), animated: true)
        })
    }

}
