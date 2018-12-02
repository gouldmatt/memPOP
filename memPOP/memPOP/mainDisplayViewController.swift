//  mainDisplayViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-23.
//  Programmers: Emily Chen, Matthew Gould, Diego Martin Marcelo
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Changes that have been made in v1.0
// Edit button adds borders and gear icon to every hotspot (no functionality)
// Added a collection view to display every hotspot with their first image (or default image) and name
// Linking to AddHotspotViewControllers for adding a new hotspot
// Added Navigation bar

//===================================================================================================
// Changes that have been made in v2.0
// Clicking an editable hotspot links to the edit page
// Added category sorting for each hotspot
// Linking to AddHotspotViewControllers for editing an existing hotspot

//===================================================================================================
// Changes that have been made in v3.0
// Update method for sorting the hotspots so that the sort only happens if a hotspot has been added/edited
// Saved the number of hotspots in each category 
//
import CoreLocation
import UIKit
import CoreData

class mainDisplayViewController: UIViewController, UICollectionViewDelegate,CLLocationManagerDelegate, UICollectionViewDataSource {
    
    //===================================================================================================
    // MARK: Constants
    //===================================================================================================
    let fetchRequestHotspot: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()
    let fetchRequestPerson: NSFetchRequest<PersonInfoMO> = PersonInfoMO.fetchRequest()
    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var arrLabel = [String]()
    var arrImg = [UIImage]()
    var hotspots = [HotspotMO]()
    var allHotspots = [HotspotMO]()
    var foodHotspots = [HotspotMO]()
    var funHotspots = [HotspotMO]()
    var taskHotspots = [HotspotMO]()
    var locationManager = CLLocationManager()
    var mainEditIsTapped : Bool = false;
    var didSortHotspots: Bool = false;
    
    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedCategory: UISegmentedControl!
    
    //===================================================================================================
    // MARK: Actions
    //===================================================================================================
    @IBAction func mainEditTapped(_ sender: UIButton) {
        
        // Add the borders around each hotspot shown
        mainEditIsTapped = !mainEditIsTapped
        collectionView.reloadData()
    }
    
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        
        // Check which category is chosen and load the set of hotspots that matches that category
        load()
        collectionView.reloadData()
    }
   
    //===================================================================================================
    // MARK: Override Functions
    //===================================================================================================
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        // Request the user permission to use their location
        self.locationManager.requestWhenInUseAuthorization()
        
        // Change appearance for segmented control (categories)
        selectedCategory.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        selectedCategory.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // initial load of the collection view data
        load()
        self.collectionView.reloadData()
        
        view.sendSubview(toBack: collectionView)
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        // Everytime the view appears, reload data stored in the collection view
        load()
        self.collectionView.reloadData()
        
        // Check if the edit button is tapped to update the borders
        if(mainEditIsTapped) {
            collectionView.reloadData()
        }
        
        // By default Edit button should not be tapped
        mainEditIsTapped = false
    }
    
    override func didReceiveMemoryWarning() {
        
        super.didReceiveMemoryWarning()
    }
    
    // if the user is adding a hotspot sort the hotspots again when they return
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        print("test")
        if (segue.identifier == "addHotspot"){
            didSortHotspots = false
        }
    }
    
    //===================================================================================================
    // MARK: Functions
    //===================================================================================================
    
    // Fetch HotspotMO Entity and store it in array of hotspots
    func load () {
        
        fetchRequestHotspot.returnsObjectsAsFaults = false

        // check if the hotspots are already sorted into category arrays
        if !(didSortHotspots){
          
            // Do-try block to fetch all the hotspot entities that correspond to the category selected
            do {
                // counter for the num of each category
                var foodNum:Int16 = 0
                var taskNum:Int16 = 0
                var funNum:Int16 = 0
                
                let person = try PersistenceService.context.fetch(fetchRequestPerson)
                let allHotspots = try PersistenceService.context.fetch(fetchRequestHotspot)
                
                // remove exisiting hotspots in case hotspots have changed category
                foodHotspots.removeAll()
                funHotspots.removeAll()
                taskHotspots.removeAll()
                self.hotspots.removeAll()
                
                // go through hotspots and append to the correct category array, also counting the number
                for hotspotItem in (allHotspots) {
        
                    if (hotspotItem.category == "Food") {
                        foodHotspots.append(hotspotItem)
                        foodNum += 1
                    }
                    else if (hotspotItem.category == "Fun") {
                        funHotspots.append(hotspotItem)
                        funNum += 1
                    }
                    else if (hotspotItem.category == "Task") {
                   
                        taskHotspots.append(hotspotItem)
                        taskNum += 1
                    }
                    
                    // set the values to be saved with the PersonInfoMO
                    person[0].foodNum = foodNum
                    person[0].funNum = funNum
                    person[0].taskNum = taskNum
                    
                    PersistenceService.saveContext()
                    
                    
                }
                
                // Modify the addHotspot Notification
                settingsViewController().modifyAddHotspotNotif()
                
                // determine which hotspots to display
                if (selectedCategory.selectedSegmentIndex == 1) {
                    
                    self.hotspots = foodHotspots
                }
                else if (selectedCategory.selectedSegmentIndex == 2) {
                    self.hotspots = funHotspots
                }
                else if (selectedCategory.selectedSegmentIndex == 3) {
                    self.hotspots = taskHotspots
                }
                else {
                    self.hotspots = allHotspots
                    self.allHotspots = allHotspots
                }
                self.didSortHotspots = true
            }
            catch {
                print("failed fetching")
            }
        }
        else {
           // if the hotspots are already sorted just display the correct array for the selected cat

            if (selectedCategory.selectedSegmentIndex == 1) {
                print(foodHotspots.count)
                self.hotspots = foodHotspots
            }
            else if (selectedCategory.selectedSegmentIndex == 2) {
                self.hotspots = funHotspots
            }
            else if (selectedCategory.selectedSegmentIndex == 3) {
                self.hotspots = taskHotspots
            } else {
                self.hotspots = allHotspots
            }
        }
    }

    
    // Collection view shows all the hotpots in mainDisplay
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // Returns the number of hotspots
        return hotspots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // Use the single "cell" created in the storyboard as a template for every hotspot added
        let cell: CollectionViewPhotoLabel = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewPhotoLabel
        
        // Check if user has inputted an image, if not, use the default image
        if(hotspots[indexPath.row].photos?.firstObject != nil){
            let photosMO = hotspots[indexPath.row].photos
            let photo = photosMO![0] as! PhotosMO
            if(photo.photo != nil){
                cell.image.image = (UIImage(data: photo.photo! as Data))
            }
        }
        else {
            cell.image.image = (UIImage(named: "defaultPhoto"))
        }
       
        // Update the label of the cell with the name of the hotspot entity
        cell.label.text = hotspots[indexPath.row].name

        // Check if editing is enabled, if it is, show a red border around all hotspots and show a gear icon
        if(mainEditIsTapped) {
            cell.cellEditButton.isHidden = false
            let borderColor : UIColor = UIColor(red: 255/255, green: 97/255, blue: 110/255, alpha: 1.0)
            cell.layer.borderColor = borderColor.cgColor
            cell.layer.borderWidth = 3
        }
        else {
            cell.cellEditButton.isHidden = true
            cell.layer.borderColor = UIColor.black.cgColor
            cell.layer.borderWidth = 0
        }
        
        return cell
    }
 
    // Checks which hotspot user selected
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // For debugging
        print(String(indexPath.row))
        print("tapped hotspot")
        
        // Check if user intends to edit or view a hostpot based on the button state
        if(mainEditIsTapped) {
            
            // User intends to edit a hotspot
            
            // make sure hotspots are sorted when user returns
            didSortHotspots = false
            
            // Instantiate an AddHotspotVC and make a transition
            let editHotspotVC = storyboard?.instantiateViewController(withIdentifier: "AddHotspotViewController") as! AddHotspotViewController
            
            // Check if this is the home hotspot
            if(indexPath.row == 0){
                editHotspotVC.isHomeHotspot = true
            }
            
            // Pass the selected hotspot information
            editHotspotVC.selectedHotspot = hotspots[indexPath.row]
            editHotspotVC.fetchedToDos = hotspots[indexPath.row].toDo as! [NSManagedObject]
            editHotspotVC.fetchedImages = hotspots[indexPath.row].photos as! [NSManagedObject]
            
            // Change view controller
            navigationController?.pushViewController(editHotspotVC, animated: true)
            
        }
        else {
            
            // User intends to view a hotspot
            
            // Takes hotspot that the user has selected and creates the overview view controller
            let overviewNavVC = storyboard?.instantiateViewController(withIdentifier: "overviewNavMasterViewController") as! overviewNavMasterViewController
            overviewNavVC.selectedHotspot = hotspots[indexPath.row]

            // Pass both arrays to the overview view controller to display them
            overviewNavVC.addedImages = hotspots[indexPath.row].photos as! [NSManagedObject]
            overviewNavVC.addedToDos = hotspots[indexPath.row].toDo as! [NSManagedObject]
            
            // Change view controller
            navigationController?.pushViewController(overviewNavVC, animated: true)
        }
    }


}

