   //  navigationViewController.swift
   //  memPOP
   //  Group 9, Iota Inc.
   //  Created by Matthew Gould on 2018-11-10.
   //  Programmers: Nicholas Lau, Emily Chen, Matthew Gould, Diego Martin Marcelo
   //  Copyright © 2018 Iota Inc. All rights reserved.
   
   //===================================================================================================
   // Changes that have been made in v2.0
   // Created view controller to handle all of the navigation features for each hotspot selected
   // Fetch information about the hotspot selected
   // Show the route in mapView between the user's location and the hotspot address
   // Add named pins to the map view
   // Print walking/driving instructions to the output terminal
   
   import UIKit
   import CoreLocation
   import MapKit
   import CoreData
   
   
   // Consulted https://www.youtube.com/watch?v=vEN5WzsAoxA for customPin
   class customPin: NSObject, MKAnnotation {
    
    // Class "customPin" added to handle each pin added to the map view
    var coordinate: CLLocationCoordinate2D
    var title: String?
    
    init(pinTitle:String, location:CLLocationCoordinate2D){
        self.title = pinTitle
        self.coordinate = location
    }
   }
   
   class navigationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var doOnce: Bool = true
    var takeCar: Bool = false
    var selectedHotspot: NSManagedObject?
    var destinationName: String = ""
    var latitude:Double?
    var longitude:Double?
    var currentLatitude:Double?
    var currentLongitude:Double?
    var locationManager = CLLocationManager()
    var route:MKRoute?
    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet weak var mapkitView: MKMapView!
    @IBOutlet var mapOrDirectionsControl: UISegmentedControl!
    
    @IBOutlet var directionsContainer: UIView!
    //===================================================================================================
    // MARK: Override Functions
    //===================================================================================================
    override func viewDidLoad() {
        
        super.viewDidLoad()
        directionsContainer.isHidden = true
        
        // Only update the route once whenever the view is loaded
        doOnce = true
        
        // Request the user permission to use their location
        self.locationManager.requestWhenInUseAuthorization()
        
        // Check if permission is granted by the user
        if CLLocationManager.locationServicesEnabled(){
            
            print("location enabled")
            
            locationManager.delegate = self
            
            // Accuracy using GPS
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            
            locationManager.startUpdatingLocation()
        }
        
        // Store the name of the destination for the selected hotspot
        destinationName = selectedHotspot?.value(forKey: "name") as! String
        
        // Fetch the latitude and longitude for the selected hotspot
        latitude = selectedHotspot?.value(forKey: "latitude") as? Double
        longitude = selectedHotspot?.value(forKey: "longitude") as? Double
        
        // For debugging
        print(latitude!)
        print(longitude!)
        
        // Check the method of transportation chosen for the selected hotspot
        if (selectedHotspot?.value(forKey: "transportation") as? String == "Car") {
            takeCar = true
        }
        else {
            takeCar = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //===================================================================================================
    // MARK: Functions
    //===================================================================================================
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // This function gets called whenever the user updates their location and updates the route
        
        //let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        let userLocal = locations.last
        
        // Store the user's current location
        currentLongitude = userLocal?.coordinate.longitude
        currentLatitude = userLocal?.coordinate.latitude
        
        // For debugging
        print(currentLatitude!)
        
        // Only show the route once
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
    
    // Get walking or driving directions
    // Consulted https://www.youtube.com/watch?v=nhUHzst6x1U for route directions
    func layoutWalkingRoute() {
        
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
        
        // Check the method of transportation from the selected hotspot to display the appropiate route
        if (takeCar){
            request.transportType = .automobile
        }
        else {
            request.transportType = .walking
        }
        
        let directions = MKDirections(request: request)
        
        directions.calculate { [unowned self] response, error in
            guard let unwrappedResponse = response else { return }
            self.route = unwrappedResponse.routes[0]
            
            for route in unwrappedResponse.routes {
                self.mapkitView.add(route.polyline)
                self.mapkitView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
                
                for step in route.steps {
                    // Print the directions in the output window
                    print(step.instructions)
                }
            }
        }
    }
    @IBAction func changedNavMode(_ sender: Any){
        if(mapOrDirectionsControl.selectedSegmentIndex == 0){
            print("map")
            layoutWalkingRoute()
            
            directionsContainer.isHidden = true
        }
        else {
            print("directions")
            //let viewLoc = MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2D(latitude,longitude), 1000)
            //self.mapkitView.setRegion(viewLoc, animated: true)
            
            //Zoom to user location
            if let userLocation = locationManager.location?.coordinate {
                let viewRegion = MKCoordinateRegionMakeWithDistance(userLocation, 200, 200)
                mapkitView.setRegion(viewRegion, animated: false)
            }
            directionsContainer.isHidden = false
        }
    }
    
   }
   

