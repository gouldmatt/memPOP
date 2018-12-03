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

//===================================================================================================
// Changes that have been made in v3.0
// Added an activity indicator to show user loading times of the map and route
// Added a circular region at the end destination to update the amount of times the selected hotspot is visited
// Modified route line to be solid when using car directions and dotted when using walking directions
// Added two modes of navigation: overview and on-screen directions
// Added checks to know when no routes are available and notify the user
// Added a custom cell for each direction step with images, distance and instruction per step
// Implemented resizing functionality for images
   
import UIKit
import CoreLocation
import MapKit
import CoreData

// Consulted https://www.youtube.com/watch?v=vEN5WzsAoxA for customPin
class customPin: NSObject, MKAnnotation {

    // Class "customPin" added to handle each pin added to the map view
    var coordinate: CLLocationCoordinate2D
    var title: String?
    var identifier: String?

    // Initiliazer function of customPin
    init (pinTitle:String, location:CLLocationCoordinate2D, identifier:String) {
        self.title = pinTitle
        self.coordinate = location
        self.identifier = identifier
    }
}
   
class navigationViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate,UITableViewDelegate,UITableViewDataSource {

    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var doOnce: Bool = true
    var takeCar: Bool = false
    var selectedHotspot: HotspotMO?
    var latitude:Double?
    var longitude:Double?
    var currentLatitude:Double?
    var currentLongitude:Double?
    var locationManager = CLLocationManager()
    var route:MKRoute?
    var timesVisit:Int32?
    var incrementOnce: Bool = true
    var hotspotRegion: CLCircularRegion?
    var mapLoaded = false
    var routeLoaded = false
    var noRoute = true
    
    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet weak var mapkitView: MKMapView!
    @IBOutlet var mapOrDirectionsControl: UISegmentedControl!
    @IBOutlet var directionsTableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    //===================================================================================================
    // MARK: Override Functions
    //===================================================================================================
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Initiliaze variables need to be reset
        noRoute = true
        mapLoaded = false
        routeLoaded = false
        incrementOnce = true
        doOnce = true
        
        // Pass the number of times visited
        timesVisit = selectedHotspot?.timesVisit
        
        // Set activity indicator and its properties
        activityIndicator.startAnimating()
        activityIndicator.hidesWhenStopped = true
        self.activityIndicator.transform = CGAffineTransform(scaleX: 3, y: 3)
        
        directionsTableView.isHidden = true
      
        // Ignore interaction events until map and route finish loading
        UIApplication.shared.beginIgnoringInteractionEvents()
        
        // Change appearance for segmented control
        mapOrDirectionsControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        mapOrDirectionsControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // Check if permission is granted by the user
        let status = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.authorizedWhenInUse){
            
            // For debugging
            print("location enabled")
            
            locationManager.delegate = self
            
            // Accuracy using GPS
            locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation
            locationManager.startUpdatingLocation()
        }
        
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
        
        // This function gets called whenever the user updates their location and it updates the route
        
        let userLocal = locations.last
    
        // Store the user's current location
        currentLongitude = userLocal?.coordinate.longitude
        currentLatitude = userLocal?.coordinate.latitude
        
        // Check if user selected directions from segmented control
        if(mapOrDirectionsControl.selectedSegmentIndex == 1){
             mapkitView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        }
        
        // Only show the route once every time the view is loaded
        if(doOnce){
            layoutRoute()
            doOnce = false
        }
        
        // For debugging
        print(userLocal!.coordinate)
        
        // If we have calculated the route then create a circular region to check when the user has reached their destination
        if(!doOnce) {
            let region = CLCircularRegion(center: CLLocationCoordinate2D(latitude: (selectedHotspot?.latitude)!, longitude: (selectedHotspot?.longitude)!), radius: 75, identifier: "hotspot")
            
            // For debugging and showing the circle in the simulator
            //let circle = MKCircle(center: region.center, radius: region.radius)
            //self.mapkitView.add(circle)
            
            // Increment timesVisit only once everytime this VC is loaded
            if(incrementOnce && region.contains((userLocal!.coordinate))) {
    
                // For debugging
                print("At hotspot")
                
                // Updated timesVisit
                timesVisit = timesVisit! + Int32(1)
                incrementOnce = false
                
                // Save the timesVisit into the selected hotspot using coredata
                selectedHotspot?.timesVisit = timesVisit!
                PersistenceService.saveContext()
            }
        }
    }
    
    // Draw and display the walking route in blue
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        
        // Check if we are rendering a polyline
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            
            // Check if user takes car or is walking
            if(takeCar) {
                // For car show a filled line
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 5.0
            }
            else {
                // When walking show a dotted line
                renderer.strokeColor = UIColor.blue
                renderer.lineWidth = 5.0
                renderer.lineDashPattern = [0, 7]
            }
            
            return renderer
        }
        else if overlay is MKCircle {
            // Or if we are rendering a circle
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.fillColor = UIColor.blue
            renderer.alpha = 0.5
            
            return renderer
        }
        
        return MKOverlayRenderer()
    }

    // Get walking or driving directions, consulted https://www.youtube.com/watch?v=nhUHzst6x1U for route directions
    func layoutRoute() {
        
        // Remove any existing annotations/renderers/routes from map
        self.locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
        mapkitView.removeOverlays(mapkitView.overlays)
      
        // Set the start and end coordinates
        let sourceCoordinates = CLLocationCoordinate2DMake(currentLatitude!, currentLongitude!)
        let destCoordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
        
        // Create a request to get directions
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinates, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoordinates, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        
        // Check the method of transportation from the selected hotspot to display the appropiate route
        if (takeCar) {
            request.transportType = .automobile
        }
        else {
            request.transportType = .walking
        }
        
        // Create where to store the directions
        let directions = MKDirections(request: request)

        // Fetch the directions
        directions.calculate{ [unowned self] response, error in
            guard let unwrappedResponse = response else {
                
                // For debugging
                print("Failed to obtain directions")
                
                self.routeLoaded = true
                
                if (self.mapLoaded) {
                    // When the map finishes loading, stop animating activity indicator button
                    self.activityIndicator.stopAnimating()
                    
                    // Can re-enable user interactions with this View controller
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
                return
            }
            
            // Found a route
            for route in unwrappedResponse.routes {
                
                if(route.steps.count > 1) {
                    self.mapkitView.add(route.polyline)
                }
                
                self.route = route
                
                for step in route.steps {
                    // For debugging: print the directions in the output window
                    print(step.instructions)
                }
 
                self.routeLoaded = true
                
                if (self.mapLoaded) {
                    // When the map finishes loading, stop animating activity indicator button
                    self.activityIndicator.stopAnimating()
                    
                    // Can re-enable user interactions with this View controller
                    UIApplication.shared.endIgnoringInteractionEvents()
                }
            }

            // If in overview layout, zoom to show whole map
            if(self.mapOrDirectionsControl.selectedSegmentIndex == 0){
                   self.mapkitView.setVisibleMapRect((self.route?.polyline.boundingMapRect)!,edgePadding: UIEdgeInsets.init(top: 60, left: 15, bottom: 60, right: 15) ,animated: false)
            }
        }

        // Remove existing annotations
        let annotations = self.mapkitView.annotations
        for annotation in annotations {
            self.mapkitView.removeAnnotation(annotation)
        }
    
        // Mark source and destination locations as pins on the map
        let sourcePin = customPin(pinTitle: "My Location`", location: sourceCoordinates,identifier: "start")
        let destPin =   customPin(pinTitle: (selectedHotspot?.name)!, location: destCoordinates,identifier: "end")
        self.mapkitView.addAnnotation(sourcePin)
        self.mapkitView.addAnnotation(destPin)
    }
    
    // Check when user changes navigation modes
    @IBAction func changedNavMode(_ sender: Any){
        
        // Always check for empty route
        if(route?.polyline != nil) {
            // If in overview mode, show whole map and route between start and end points
            if(mapOrDirectionsControl.selectedSegmentIndex == 0){
                print("map")
                self.mapkitView.setVisibleMapRect((self.route?.polyline.boundingMapRect)!,edgePadding: UIEdgeInsets.init(top: 60, left: 15, bottom: 60, right: 15) ,animated: true)
                directionsTableView.isHidden = true
            }
            else {
                // If in on-screen directions mode, show route and zoom in and follow the user's current location
                print("directions")
                mapkitView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
                directionsTableView.reloadData()
                directionsTableView.isHidden = false
            }
        }
        else {
            // If no routes were found, hide and show text letting the user know that there are no routes available
            if(mapOrDirectionsControl.selectedSegmentIndex == 0){
                print("map")
                directionsTableView.isHidden = true
            }
            else {
                print("directions")
                mapkitView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
                directionsTableView.reloadData()
                directionsTableView.isHidden = false
            }
        }
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections in directionsTableView, always 1
        return 1
    }
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        
        // Return the number of items to display in the directionsTableView, depends if a route was found or not
        if(!doOnce && route?.steps.count != nil) {
            count = route?.steps.count
        }
        else {
            count = 1
        }
        
        return count!
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Use the single "cell" created in the storyboard as a template for every direction item
        var cell : UITableViewCell?
        cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        
        let image: UIImage?
        
        // Process each step and update the table view cell accordingly
        if(indexPath.row == 0) {
            
            // The very first step shows the current direction highlighted
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            image = UIImage(named: "location")!
            
            // Check if a route is available and notify the user
            if(route?.polyline == nil && !doOnce) {
                noRoute = true
                if(takeCar) {
                    cell?.textLabel?.text = "No driving directions to " + (selectedHotspot?.name)!
                }
                else {
                    cell?.textLabel?.text = "No walking directions to " + (selectedHotspot?.name)!
                }
            }
            else {
                noRoute = false
                cell?.textLabel?.text = "Directions to " + (selectedHotspot?.name)!
            }
        }
        else {
            // For the remaining steps to the following
            let currentDirection = route?.steps[indexPath.row].instructions
            var distanceInt =  Int((route?.steps[indexPath.row].distance.magnitude)!)
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
            
            // Check the direction per step to show the correct image
            if (currentDirection?.range(of: "left") != nil) {
                image = UIImage(named: "leftTurn")!
            }
            else if (currentDirection?.range(of: "right") != nil) {
                image = UIImage(named: "rightTurn")!
            }
            else {
                image = UIImage(named: "continue")!
            }
            
            // Check the distance per step
            if (distanceInt > 1000) {
                distanceInt = distanceInt / 1000
                cell?.textLabel?.text = "\(distanceInt) km"
            }
            else {
                cell?.textLabel?.text = "\(distanceInt) m"
            }
            
            // Show the step instruction
            cell!.detailTextLabel?.text = self.route?.steps[indexPath.row].instructions
        }
        
        // Attach the image
        cell?.imageView?.image = image
        
        // Resize the image within the cell
        let itemSize = CGSize.init(width: 27, height: 27)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell?.imageView?.image?.draw(in: imageRect)
        cell?.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return cell!
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // When user selects one of the directions show and zoom into that step on the map for a period of time
        let routeStepView = route?.steps[indexPath.row].polyline.boundingMapRect
        self.mapkitView.setVisibleMapRect(routeStepView!,edgePadding: UIEdgeInsets.init(top: 70, left: 20, bottom: 70, right: 20) ,animated: true)
    }
    
    //////////// I dont think we are doing this anymore ////////////
    //Consulted https://www.youtube.com/watch?v=8m-duJ9X_Hs for detecting user entry/exit of regions
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if(region.identifier == "hotspot") {
            print("Increment\n\n")
            print(locationManager.monitoredRegions.count)
            timesVisit = timesVisit! + Int32(1)
            incrementOnce = false
        }
    
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        if(!incrementOnce) {
            locationManager.stopMonitoring(for: hotspotRegion!)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("Leaving")
        selectedHotspot?.timesVisit = timesVisit!
        incrementOnce = true
        PersistenceService.saveContext()
    }
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
        // Check when the map has finished loading its view
        mapLoaded = true
        
        // Check if the route has also finish loading
        if(routeLoaded) {
            // When both conditions are true, stop animating activity indicator button
            activityIndicator.stopAnimating()
            
            // Can re-enable user interactions with this View controller
            UIApplication.shared.endIgnoringInteractionEvents()
        }
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        // Add the images for each custom pin annotation
        if let annotation = annotation as? customPin {
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier!) {
                return view
            }
            else {
                if(annotation.identifier == "start") {
                    // Start step
                    let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                    var image = UIImage(named: "user")
                
                    image = image?.resize(targetSize: CGSize(width: 40, height: 40))
                    view.image = image
                    view.isEnabled = true
                    view.canShowCallout = true
                  
                    return view
                }
                else {
                    // End step
                    let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)

                    var image = UIImage(named: "hotspot")
                    
                    image = image?.resize(targetSize: CGSize(width: 40, height: 40))
                    view.image = image
                    view.isEnabled = true
                    view.canShowCallout = true
                  
                    return view
                }
            }
        }
        return nil
    }
}

//===================================================================================================
// MARK: Extensions
//===================================================================================================
// Consulted https://stackoverflow.com/questions/32612760/resize-image-without-losing-quality for resizing UIImage
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image {_ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
}
   
