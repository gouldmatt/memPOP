//
//  HotspotOverviewViewController.swift
//  memPOP
//
//  Created by Emily on 2018-10-23.
//  Copyright © 2018 Iota Inc. All rights reserved.
//
import CoreData
import UIKit

class HotspotOverviewViewController: UIViewController {
    @IBOutlet var overviewNavControl: UISegmentedControl!
    @IBOutlet var toDoTable: UITableView!
    
    var addedToDos = [NSManagedObject]()
    var addedImages = [NSManagedObject]()
    var selectedHotspot: NSManagedObject?
    
    override func viewDidLoad() {
        
        print("added to do:")
        print(addedToDos.count)
        
        
        overviewNavControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        overviewNavControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // change navigation bar title
        self.title = ((selectedHotspot?.value(forKey: "name")) as? String)
        
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
        print(addedToDos.count)
        return addedToDos.count
    }
    
    public func tableView(_ toDoTable: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        let cell = UITableViewCell(style: UITableViewCellStyle.default, reuseIdentifier: "cell")
        cell.textLabel?.text = addedToDos[indexPath.row].value(forKey: "toDoItem") as? String

        return(cell)
    }
}
