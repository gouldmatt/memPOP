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

import UIKit
import CoreData

class mainDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //===================================================================================================
    // MARK: Constants
    //===================================================================================================
    let fetchRequest: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()
    
    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var arrLabel = [String]()
    var arrImg = [UIImage]()
    var hotspots = [HotspotMO]()
    var mainEditIsTapped : Bool = false;
    
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
        
        // Change appearance for segmented control (categories)
        selectedCategory.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        selectedCategory.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        view.sendSubview(toBack: collectionView)
    }
    
    override func viewWillAppear(_ animated:Bool) {
        
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
    
        load()
        
        // Everytime the view appears, reload data stored in the collection view
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
    
    //===================================================================================================
    // MARK: Functions
    //===================================================================================================
    
    // Fetch HotspotMO Entity and store it in array of hotspots
    func load () {
        
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.relationshipKeyPathsForPrefetching = ["photos"]
        
        // Do-try block to fetch all the hotspot entities that correspond to the category selected
        do {
        
                let hotspots = try PersistenceService.context.fetch(fetchRequest)
                var sortedHotspots = [HotspotMO]()
            
                // Before storing the hotspots check which category has been chosen and only load those
                if (selectedCategory.selectedSegmentIndex == 1) {
                    for hotspotItem in (hotspots) {
                        if (hotspotItem.category == "Food") {
                            sortedHotspots.append(hotspotItem)
                        }
                    }
                }
                else if (selectedCategory.selectedSegmentIndex == 2) {
                    for hotspotItem in (hotspots) {
                        if (hotspotItem.category == "Fun") {
                            sortedHotspots.append(hotspotItem)
                        }
                    }
                }
                else if (selectedCategory.selectedSegmentIndex == 3) {
                    for hotspotItem in (hotspots) {
                        if (hotspotItem.category == "Task") {
                            sortedHotspots.append(hotspotItem)
                        }
                    }
                }
                else {
                    for hotspotItem in (hotspots) {
                        sortedHotspots.append(hotspotItem)
                    }
                }
                self.hotspots = sortedHotspots
        }
        catch {
            print("failed fetching")
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

