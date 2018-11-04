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
    var addedImages = [NSManagedObject]()
    var addedToDos = [NSManagedObject]()
    var hotspots = [HotspotMO]()
    var photo: PhotosMO?
    var mainEditIsTapped : Bool = false;
    
    //===================================================================================================
    // Outlets
    //===================================================================================================
    @IBOutlet weak var collectionView: UICollectionView!
    
    //===================================================================================================
    // Actions
    //===================================================================================================
    @IBAction func mainEditTapped(_ sender: UIButton) {
        mainEditIsTapped = !mainEditIsTapped
        collectionView.reloadData()
        print("MainEditTapped")
    }
   
    //===================================================================================================
    // Override Functions
    //===================================================================================================
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewDidLoad()
        self.navigationController?.isNavigationBarHidden = false
        
        load()
        self.collectionView.reloadData()
        
        if(mainEditIsTapped) {
            collectionView.reloadData()
        }
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

        do {
            let hotspots = try PersistenceService.context.fetch(fetchRequest)
            self.hotspots = hotspots
        }
        
        catch {
            print("failed fetching")
        }
    }
    
    // Returns the number of hotspots
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return hotspots.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: CollectionViewCell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CollectionViewCell
        
        // Check if user has inputted an image, if not, use the default image
        if(hotspots[indexPath.row].photos?.anyObject() != nil){
            let photosMO = hotspots[indexPath.row].photos?.allObjects
            let photo = photosMO![0] as! PhotosMO
            if(photo.photo != nil){
                cell.image.image = (UIImage(data: photo.photo! as Data))
            }
        }
        else {
            cell.image.image = (UIImage(named: "defaultPhoto"))
        }
       
        cell.label.text = hotspots[indexPath.row].name

        // Check if editing is enabled, if it is, show a white border around all hotspots and show a gear icon
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
        
        // Takes hotspot that the user has selected and creates the overview view controller
        let overviewVC = storyboard?.instantiateViewController(withIdentifier: "HotspotOverviewViewController") as! HotspotOverviewViewController
        overviewVC.selectedHotspot = hotspots[indexPath.row]
        
        for photo in (hotspots[indexPath.row].photos?.allObjects)! {
            addedImages.append(photo as! NSManagedObject)
        }
        
        for toDoItem in (hotspots[indexPath.row].toDo?.allObjects)! {
            addedToDos.append(toDoItem as! NSManagedObject)
        }
        
        overviewVC.addedImages = addedImages
        overviewVC.addedToDos = addedToDos
        
        // Remove all so that previous selections objects are not also passed
        addedImages.removeAll()
        addedToDos.removeAll()
        
        navigationController?.pushViewController(overviewVC, animated: true)
    }
}
