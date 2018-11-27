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
    var identifier: String?
    
    init(pinTitle:String, location:CLLocationCoordinate2D, identifier:String){
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
    var stepCompleted: Bool = false
    var selectedHotspot: HotspotMO?
    var latitude:Double?
    var longitude:Double?
    var currentLatitude:Double?
    var currentLongitude:Double?
    var locationManager = CLLocationManager()
    var route:MKRoute?
    var routeStepsArr = [String]()
    var routeDistanceArr = [Int]()
    var stepCounter:Int = 0
    
    //var routeSteps:Int = 0
    var touchedScreen:Bool = false
    var firstTouchLocation:CGPoint?
    var lastTouchLocation:CGPoint?

    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet weak var mapkitView: MKMapView!
    @IBOutlet var mapOrDirectionsControl: UISegmentedControl!
    
    @IBOutlet var directionsTableView: UITableView!

    @IBOutlet var navigationView: UIView!
    //===================================================================================================
    // MARK: Override Functions
    //===================================================================================================
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Store the first touch location
        firstTouchLocation = touches.first?.location(in: mapkitView)
        
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // Store the last touch location
        lastTouchLocation = touches.first?.location(in: mapkitView)
        
        // Check if the first touch and last touch location are the same
        if(lastTouchLocation == firstTouchLocation) {
            
            // Every touch toggles between showing the entire map view or not
            touchedScreen = !touchedScreen
            
            // If equal, choose to hide/show the subviews to show a larger map view
            if(!touchedScreen) {
                UIView.transition(with: navigationView, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
                // Hide subviews
                self.navigationView.sendSubview(toBack: mapkitView)
            }
            else {
                UIView.transition(with: navigationView, duration: 0.2, options: .transitionCrossDissolve, animations: nil, completion: nil)
                // Show subviews
                self.navigationView.bringSubview(toFront: mapkitView)
            }
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        touchedScreen = false
        
        directionsTableView.isHidden = true
        doOnce = true
        
        mapkitView.isRotateEnabled = true
        mapkitView.isPitchEnabled = true
        
        // Change appearance for segmented control
        mapOrDirectionsControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        mapOrDirectionsControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)

        
        // Request the user permission to use their location
        self.locationManager.requestWhenInUseAuthorization()
        
        
        // Check if permission is granted by the user
        let status = CLLocationManager.authorizationStatus()
        if (status == CLAuthorizationStatus.authorizedWhenInUse){
            
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
        
        // This function gets called whenever the user updates their location and updates the route
        
        //let locValue:CLLocationCoordinate2D = (manager.location?.coordinate)!
        let userLocal = locations.last
        
        // Store the user's current location
        currentLongitude = userLocal?.coordinate.longitude
        currentLatitude = userLocal?.coordinate.latitude
        
        if(mapOrDirectionsControl.selectedSegmentIndex == 1){
             mapkitView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
        }
        
        if(routeStepsArr.count != 0) {
            // check if user is on track
            print("result from check")
            let userRegion = MKCircle(center: (locations.last?.coordinate)!, radius: 30)
            var onTrackBool = route?.polyline.intersects((userRegion.boundingMapRect))
            print(onTrackBool!)
            if !(onTrackBool!) {
                print("off track")
                self.mapkitView.add(userRegion)
                layoutWalkingRoute()
                onTrackBool = true
            }
        }

        // For debugging
        //print(currentLatitude!)
        
        // Only show the route once
        if(doOnce){
            layoutWalkingRoute()
            doOnce = false
        }
    }
    
    // Draw and display the walking route in blue
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if overlay is MKPolyline {
            let renderer = MKPolylineRenderer(polyline: overlay as! MKPolyline)
            renderer.strokeColor = UIColor.blue
            renderer.lineWidth = 10.0
            
            return renderer
        }
        else if overlay is MKCircle {
            let renderer = MKCircleRenderer(overlay: overlay)
            renderer.strokeColor = UIColor.blue
            renderer.fillColor = UIColor.blue
            renderer.alpha = 0.5
            
            return renderer
        }
        return MKOverlayRenderer()
    }
    

    
    // Get walking or driving directions
    // Consulted https://www.youtube.com/watch?v=nhUHzst6x1U for route directions
    func layoutWalkingRoute() {
        // reset the step counter & array for this new route
        stepCounter = 0
        
        //self.routeStepsArr.removeAll()
        //self.routeDistanceArr.removeAll()
        
        // remove any existing things from map
        self.locationManager.monitoredRegions.forEach({self.locationManager.stopMonitoring(for: $0)})
        mapkitView.removeOverlays(mapkitView.overlays)
      
        let sourceCoordinates = CLLocationCoordinate2DMake(currentLatitude!, currentLongitude!)
        let destCoordinates = CLLocationCoordinate2DMake(latitude!, longitude!)
        
        let request = MKDirectionsRequest()
        request.source = MKMapItem(placemark: MKPlacemark(coordinate: sourceCoordinates, addressDictionary: nil))
        request.destination = MKMapItem(placemark: MKPlacemark(coordinate: destCoordinates, addressDictionary: nil))
        request.requestsAlternateRoutes = false
        
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
            
            for route in unwrappedResponse.routes {
                
                self.mapkitView.add(route.polyline)
        
                self.route = route
                
                for step in route.steps {
                    // Print the directions in the output window
                    print(step.instructions)
                    self.routeDistanceArr.append(Int(step.distance))
                    self.routeStepsArr.append(step.instructions)

                }
                // create the first region
                self.routeStepsArr[0] = "Directions to " + (self.selectedHotspot?.name)!

                let step = route.steps[0]
                
                let region = CLCircularRegion(center: step.polyline.coordinate, radius: 30, identifier: step.instructions)
                region.notifyOnEntry = true
                region.notifyOnExit = true
                self.locationManager.startMonitoring(for: region)
                
                // draw a circle for debugging on map
                let circle = MKCircle(center: region.center, radius: region.radius)
                self.mapkitView.add(circle)
            }
            
            // if in overview layout zoom to show whole map
            if(self.mapOrDirectionsControl.selectedSegmentIndex == 0){
                   self.mapkitView.setVisibleMapRect((self.route?.polyline.boundingMapRect)!,edgePadding: UIEdgeInsets.init(top: 60, left: 15, bottom: 60, right: 15) ,animated: true)
            }
            
        }
        // remove existing annotations
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
    
    @IBAction func changedNavMode(_ sender: Any){
        if(mapOrDirectionsControl.selectedSegmentIndex == 0){
            print("map")
            //layoutWalkingRoute()
            self.mapkitView.setVisibleMapRect((self.route?.polyline.boundingMapRect)!,edgePadding: UIEdgeInsets.init(top: 60, left: 15, bottom: 60, right: 15) ,animated: true)
            directionsTableView.isHidden = true
        }
        else {
            print("directions")
            layoutWalkingRoute()
            mapkitView.setUserTrackingMode(MKUserTrackingMode.follow, animated: true)
            directionsTableView.reloadData()
            directionsTableView.isHidden = false
            

        }
    }
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // https://www.youtube.com/watch?v=LrCqXmHenJY
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
       return (routeStepsArr.count)
    }
    
    // https://www.youtube.com/watch?v=LrCqXmHenJY
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell?
        cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        
        let image: UIImage?
        
        // Process each step and update the table view cell accordingly
        
        if(indexPath.row == 0 && stepCounter == 0) {
            
            // The very first step shows the current direction highlighted
            
            cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
            image = UIImage(named: "location")!
            cell?.textLabel?.text = routeStepsArr[0]
            cell?.backgroundColor = UIColor.lightGray
        
        }
        else if (indexPath.row == 0){
            
            let currentDirection = routeStepsArr[indexPath.row]
            var distanceInt =  routeDistanceArr[indexPath.row]
            
            // The rest of the steps show how to the destination
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
            
           
            
            // Check the direction per step to show the correct image
            if (currentDirection.range(of: "left") != nil) {
                image = UIImage(named: "leftTurn")!
                
            }
            else if (currentDirection.range(of: "right") != nil) {
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
            cell?.backgroundColor = UIColor.lightGray
        }
        else {
            
            let currentDirection = routeStepsArr[indexPath.row]
            
            // The rest of the steps show how to the destination
            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
            
            //let distanceInStep = self.route?.steps[indexPath.row].distance
           // var distanceInt = Int(distanceInStep!)
            
            var distanceInt =  routeDistanceArr[indexPath.row]
            // Check the direction per step to show the correct image
            if (currentDirection.range(of: "left") != nil) {
                image = UIImage(named: "leftTurn")!
                
            }
            else if (currentDirection.range(of: "right") != nil) {
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
        
        // when user selects one of the directions show that step on the map
        let routeStepView = route?.steps[indexPath.row].polyline.boundingMapRect
        self.mapkitView.setVisibleMapRect(routeStepView!,edgePadding: UIEdgeInsets.init(top: 60, left: 10, bottom: 60, right: 10) ,animated: true)
    }
    
    //Consulted https://www.youtube.com/watch?v=8m-duJ9X_Hs for detecting user entry/exit of regions
    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        if !(self.stepCompleted) {
            if(routeStepsArr.count != 0){
                print("\n\n\n\n\n")
                print("within region")
                print("next step while entering")
                print("step counter")
                print(stepCounter)
                routeStepsArr.remove(at: stepCounter)
                stepCounter += 1
                directionsTableView.reloadData()
                stepCompleted = true
                
                if(stepCounter < routeStepsArr.count){
                    let step = route?.steps[stepCounter]
                    // create the regions
                    let region = CLCircularRegion(center: (step?.polyline.coordinate)!, radius: 30, identifier: (step?.instructions)!)
                    region.notifyOnEntry = true
                    region.notifyOnExit = true
                    self.locationManager.startMonitoring(for: region)
                    
                    
                    let circle = MKCircle(center: region.center, radius: region.radius)
                    self.mapkitView.add(circle)
                }
                
            }
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
    
        if(routeStepsArr.count != 0){
            if(stepCompleted != true){
                print("\n\n\n\n\n")
                print("left region")
                print("next step while leaving")
                print("step counter")
                print(stepCounter)
                routeStepsArr.remove(at: stepCounter)
                stepCounter += 1
                directionsTableView.reloadData()
                
                if(stepCounter < routeStepsArr.count){
                    let step = route?.steps[stepCounter]
                    // create the regions
                    let region = CLCircularRegion(center: (step?.polyline.coordinate)!, radius: 30, identifier: (step?.instructions)!)
                    region.notifyOnEntry = true
                    region.notifyOnExit = true
                    self.locationManager.startMonitoring(for: region)
                    
                    
                    let circle = MKCircle(center: region.center, radius: region.radius)
                    self.mapkitView.add(circle)
                }
            }
            stepCompleted = false
        }
        
    }
    
    // add the images for each custom pin annotation
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if let annotation = annotation as? customPin{
            if let view = mapView.dequeueReusableAnnotationView(withIdentifier: annotation.identifier!){
                return view
            }
            else{
                if(annotation.identifier == "start"){
                
                    let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                    var image = #imageLiteral(resourceName: "user")
                
                    image = image.resize(targetSize: CGSize(width: 40, height: 40))
                    view.image = image
                    view.isEnabled = true
                    view.canShowCallout = true
                  
                    return view
                    
                }
                else {
                    let view = MKAnnotationView(annotation: annotation, reuseIdentifier: annotation.identifier)
                    var image = #imageLiteral(resourceName: "hotspot")
                    
                    image = image.resize(targetSize: CGSize(width: 40, height: 40))
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

// Consulted https://stackoverflow.com/questions/32612760/resize-image-without-losing-quality for resizing UIImage
extension UIImage {
    func resize(targetSize: CGSize) -> UIImage {
        return UIGraphicsImageRenderer(size:targetSize).image {_ in
            self.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
   }
   
