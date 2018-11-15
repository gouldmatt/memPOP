//
//  mainDisplayViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-23.
//  Programmers: Emily Chen, Matthew Gould, Diego Martin Marcelo
//  Copyright © 2018 Iota Inc. All rights reserved.
//

// Changes that have been made
// Edit button borders
// Hotspot tiles layout
// Linking of view controllers

import UIKit
import CoreData

class mainDisplayViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
    
    //===================================================================================================
    // Constants
    //===================================================================================================
    
    let fetchRequest: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()
    
    //===================================================================================================
    // Variables declaration
    //===================================================================================================
    var arrLabel = [String]()
    var arrImg = [UIImage]()
    var hotspots = [HotspotMO]()
    //var photo: PhotosMO?
    var mainEditIsTapped : Bool = false;
    
    //===================================================================================================
    // Outlets
    //===================================================================================================
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var selectedCategory: UISegmentedControl!
    //===================================================================================================
    // Actions
    //===================================================================================================
    @IBAction func mainEditTapped(_ sender: UIButton) {
        mainEditIsTapped = !mainEditIsTapped
        collectionView.reloadData()
        print("MainEditTapped")
    }
    
    @IBAction func categoryChanged(_ sender: UISegmentedControl) {
        load()
        collectionView.reloadData()
        print("category changed")
    }
   
    //===================================================================================================
    // Override Functions
    //===================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.sendSubview(toBack: collectionView)        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        // Fetch all the hotspots
        load()
        
        // Everytime the view appears, reload data stored in the collection view
        self.collectionView.reloadData()
        
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
    // Functions
    //===================================================================================================
    
    // Fetch HotspotMO Entity and store it in array hotspots
    func load () {
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.relationshipKeyPathsForPrefetching = ["photos"]
        
        // Do-try block to fetch all the hotspot entities that correspond to the category selected
        do {
                let hotspots = try PersistenceService.context.fetch(fetchRequest)
                var sortedHotspots = [HotspotMO]()
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
    
    // Returns the number of hotspots
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotspots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewPhotoLabel = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewPhotoLabel
        // Use the single "cell" created in the storyboard as a template for every hotspot added
        
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
        print(String(indexPath.row))
        print("tapped hotspot")
        
        if(mainEditIsTapped) {
            let editHotspotVC = storyboard?.instantiateViewController(withIdentifier: "AddHotspotViewController") as! AddHotspotViewController
            editHotspotVC.selectedHotspot = hotspots[indexPath.row]
            
            editHotspotVC.fetchedToDos = hotspots[indexPath.row].toDo as! [NSManagedObject]
            editHotspotVC.fetchedImages = hotspots[indexPath.row].photos as! [NSManagedObject]
            
            navigationController?.pushViewController(editHotspotVC, animated: true)
            
        }
        else {
        
        // Takes hotspot that the user has selected and creates the overview view controller
        let overviewNavVC = storyboard?.instantiateViewController(withIdentifier: "overviewNavMasterViewController") as! overviewNavMasterViewController
        overviewNavVC.selectedHotspot = hotspots[indexPath.row]

        // Pass both arrays to the overview view controller to display them
        overviewNavVC.addedImages = hotspots[indexPath.row].photos as! [NSManagedObject]
        overviewNavVC.addedToDos = hotspots[indexPath.row].toDo as! [NSManagedObject]
        
        navigationController?.pushViewController(overviewNavVC, animated: true)
        }
    }
}

