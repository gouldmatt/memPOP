//
//  HotspotOverviewViewController.swift
//  memPOP
//
//  Created by Emily on 2018-10-23.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
import CoreData
import UIKit

class HotspotOverviewViewController: UIViewController,UITableViewDelegate, UITableViewDataSource,UICollectionViewDelegate,UICollectionViewDataSource {
    @IBOutlet var overviewNavControl: UISegmentedControl!
    @IBOutlet var toDoTable: UITableView!
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var toDoHeightConstraint: NSLayoutConstraint!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    

    @IBOutlet var descriptionView: UILabel!
    @IBOutlet var collectionView: UICollectionView!
    var addedToDos = [NSManagedObject]()
    var addedImages = [NSManagedObject]()
    var selectedHotspot: NSManagedObject?
    
    override func viewDidLoad() {
        
        //toDoTable.isScrollEnabled = false;
        toDoTable.bounces = false;
    
        
        overviewNavControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        overviewNavControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // change navigation bar title
        self.title = ((selectedHotspot?.value(forKey: "name")) as? String)
        
        // add description
        descriptionView.text = ((selectedHotspot?.value(forKey: "info")) as? String)
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    public func tableView(_ toDoTable: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return addedToDos.count
    }
    
    public func tableView(_ toDoTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let photoCell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "photoCell")
        photoCell.textLabel?.text = (addedToDos[indexPath.row].value(forKey: "toDoItem") as! String)

        return(photoCell)
    }

    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return addedImages.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photoOnlyCell:  CollectionViewPhoto = collectionView.dequeueReusableCell(withReuseIdentifier: "photoOnlyCell", for: indexPath) as! CollectionViewPhoto
        
        
        let imageData = addedImages[indexPath.row].value(forKey: "photo")

        photoOnlyCell.image.image = UIImage(data: imageData as! Data)

        
        return photoOnlyCell
    }
}

