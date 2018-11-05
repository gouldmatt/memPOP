//
//  HotspotOverviewViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-23.
//  Programmers: Matthew Gould
//  Copyright © 2018 Iota Inc. All rights reserved.
//

// Changes that have been made
// Fetching of hotspot selected
// Hotspot descriptions layout

import CoreData
import UIKit

class HotspotOverviewViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource {
    
    //===================================================================================================
    // Variables declaration
    //===================================================================================================
    var addedToDos = [NSManagedObject]()
    var addedImages = [NSManagedObject]()
    var selectedHotspot: NSManagedObject?
    
    //===================================================================================================
    // Outlets
    //===================================================================================================
    @IBOutlet var overviewNavControl: UISegmentedControl!
    @IBOutlet var toDoTable: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var descriptionView: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    
    //===================================================================================================
    // Override Functions
    //===================================================================================================
    
    override func viewDidLoad() {
        toDoTable.bounces = false;
        
        // change appearance for segmented control
        overviewNavControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        overviewNavControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // Update navigation bar title
        self.title = ((selectedHotspot?.value(forKey: "name")) as? String)
        
        // Add description
        descriptionView.text = ((selectedHotspot?.value(forKey: "info")) as? String)
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //===================================================================================================
    // Functions
    //===================================================================================================
    public func tableView(_ toDoTable: UITableView, numberOfRowsInSection section: Int) -> Int {
        return addedToDos.count
    }
    
    // Load To-Do List
    public func tableView(_ toDoTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let photoCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "photoCell")
        photoCell.textLabel?.text = (addedToDos[indexPath.row].value(forKey: "toDoItem") as! String)

        return(photoCell)
    }

    // Return the count of images
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addedImages.count
    }
    
    // Load photos
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoOnlyCell:  CollectionViewPhoto = collectionView.dequeueReusableCell(withReuseIdentifier: "photoOnlyCell", for: indexPath) as! CollectionViewPhoto
        
        let imageData = addedImages[indexPath.row].value(forKey: "photo")
        photoOnlyCell.image.image = UIImage(data: imageData as! Data)
        return photoOnlyCell
    }
}

