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
import CoreData

class customPin: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(pinTitle:String, location:CLLocationCoordinate2D){
        self.title = pinTitle
        self.coordinate = location
    }
}

class navigationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    var doOnce: Bool = true
    var takeCar: Bool = false
    var selectedHotspot: NSManagedObject?
    var destinationName: String = ""
    
    var latitude:Double?
    var longitude:Double?
    
    var currentLatitude:Double?
    var currentLongitude:Double?
    
    //===================================================================================================
    // Constants
    var locationManager = CLLocationManager()
    //===================================================================================================
    // Outlets
    @IBOutlet weak var mapkitView: MKMapView!
    //===================================================================================================
    // Functions
    //===================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        doOnce = true
        
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled(){
            print("location enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // accuracy using gps
            locationManager.startUpdatingLocation()
        }
        
        //setUpLocationManager()
        destinationName = selectedHotspot?.value(forKey: "name") as! String
        latitude = selectedHotspot?.value(forKey: "latitude") as? Double
        longitude = selectedHotspot?.value(forKey: "longitude") as? Double
        print(latitude!)
        print(longitude!)
        
        if (selectedHotspot?.value(forKey: "transportation") as? String == "Car") {
            takeCar = true
        } else {
            takeCar = false
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
    
    }
    
    func setUpLocationManager() {
        
        // Get location permission from user
        self.locationManager.requestAlwaysAuthorization()
        
        // Check if location services enabled before starting
        if CLLocationManager.locationServicesEnabled(){
            print("location enabled")
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation // accuracy using gps
            
            locationManager.distanceFilter = 10.0
            // meters update when past cetain distance using other methods
            //but realtime is better for navigation related purposes
            
            
            locationManager.startUpdatingLocation()
            
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        //let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        let userLocal = locations.last
        
        currentLongitude = userLocal?.coordinate.longitude
        currentLatitude = userLocal?.coordinate.latitude
        print(currentLatitude!)
       
        //let viewLoc = MKCoordinateRegionMakeWithDistance((userLocal?.coordinate)!, 5000, 5000)
        //self.mapkitView.setRegion(viewLoc, animated: true)
        if(doOnce){
            layoutWalkingRoute()
            doOnce = false
        }
        
    }
    
    // Draw and display the walking route in blue
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 3.0
        return renderer
    }
    
    // Get walking directions
    func layoutWalkingRoute(){
        let sourceCoordinates = CLLocationCoordinate2DMake(currentLatitude!, currentLongitude!)
        let destCoordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
        
        // Mark source and destination locations as pins on the map
        let sourcePin = customPin(pinTitle: " ", location: sourceCoordinates)
        let destPin =   customPin(pinTitle: destinationName, location: destCoordinates)
        self.mapkitView.addAnnotation(sourcePin)
        self.mapkitView.addAnnotation(destPin)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinates, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoordinates, addressDictionary: nil))
     
        if (takeCar){
            request.transportType = .automobile
        } else {
            request.transportType = .walking
        }
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            
            for route in unwrappedResponse.routes {
                self.mapkitView.add(route.polyline)
                self.mapkitView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                for step in route.steps {
                    print(step.instructions)
                }
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

