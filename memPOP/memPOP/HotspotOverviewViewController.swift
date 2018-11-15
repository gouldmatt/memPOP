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
    @IBOutlet var toDoTable: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var descriptionView: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var toDoTableHeight: NSLayoutConstraint!
    @IBOutlet var collectionViewHeight: NSLayoutConstraint!
   // @IBOutlet var descriptionViewHeight: NSLayoutConstraint!
    //===================================================================================================
    // Override Functions
    //===================================================================================================
    
    override func viewDidLoad() {
        
        // Set up to do table, description label and collection view with dynamic height
        
        toDoTable.bounces = false
        toDoTable.isScrollEnabled = false
        toDoTable.reloadData()
        toDoTable.layoutIfNeeded()
        toDoTableHeight.constant = toDoTable.contentSize.height
        
        descriptionView.text = ((selectedHotspot?.value(forKey: "info")) as? String)
        
        collectionView.bounces = false
        collectionView.isScrollEnabled = false
        collectionView.reloadData()
        collectionView.layoutIfNeeded()
        collectionViewHeight.constant =  collectionView.contentSize.height
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
        collectionView.reloadData()
        toDoTable.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
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
        photoCell.backgroundColor = UIColor(red:0.16, green:0.19, blue:0.21, alpha:1.0)
        photoCell.textLabel?.textColor = UIColor.white
        
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
        if(imageData != nil){
            let image = UIImage(data: imageData as! Data)
            photoOnlyCell.image.image = image
        } else {
            photoOnlyCell.image.image = (UIImage(named: "defaultPhoto"))
        }
        
        return photoOnlyCell
    }
}

