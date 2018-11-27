//  overviewNavSelectViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Matthew Gould on 2018-11-10.
//  Programmers: Matthew Gould
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Changes that have been made in v2.0
// Created Master view controller to handle the switching of view between overview and navigation mode
// Added buttons to handle the transition events
// Added fetching support for passing information about hotspot selected between the views

import CoreData
import UIKit
import CoreLocation
import MapKit

class overviewNavMasterViewController: UIViewController, UITableViewDelegate, UITableViewDataSource{
    
    //===================================================================================================
    // MARK: Variables declaration
    //===================================================================================================
    var addedToDos = [NSManagedObject]()
    var addedImages = [NSManagedObject]()
    var selectedHotspot: NSManagedObject?
    
    var latitude:Double = 0.0
    var longitude:Double = 0.0

    var contactsEnabled:Bool = false
    
    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet var overviewNavControl: UISegmentedControl!
    @IBOutlet weak var overviewContainer: UIView!
    @IBOutlet var navigationContainer: UIView!
    @IBOutlet weak var contactsTableView: UITableView!
    
    //===================================================================================================
    // MARK: Actions
    //===================================================================================================
    @IBAction func changedSegment(_ sender: UISegmentedControl) {
    
        // Hide one of the container views based on current segmented control selection
        if sender.selectedSegmentIndex == 0 {
            self.overviewContainer.isHidden = false
            self.navigationContainer.isHidden = true
        }
        else {
            self.overviewContainer.isHidden = true
            self.navigationContainer.isHidden = false
        }
    }

    //===================================================================================================
    // MARK: Functions
    //===================================================================================================
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        contactsTableView.tableFooterView = UIView(frame: .zero)
        contactsTableView.isHidden = true
        contactsEnabled = false
        
        // Change appearance for segmented control
        overviewNavControl.setTitleTextAttributes([NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .normal)
        
        overviewNavControl.setTitleTextAttributes([
            NSAttributedStringKey.font : UIFont.boldSystemFont(ofSize: 18),
            NSAttributedStringKey.foregroundColor: UIColor.white
            ], for: .selected)
        
        // Update navigation bar items
        setupNavigationBarItems()
        
        let hotspot = selectedHotspot as! HotspotMO
        if ((hotspot.info == nil || (hotspot.info?.isEmpty)!) && hotspot.toDo?.count == 0 && hotspot.photos?.count == 0){
            self.overviewContainer.isHidden = true
            self.navigationContainer.isHidden = false
            overviewNavControl.removeSegment(at:0, animated: true)
            overviewNavControl.isUserInteractionEnabled = false
        }
    }
    
    private func setupNavigationBarItems () {
        
        // Update navigation bar title with hotspot name
        navigationItem.title = ((selectedHotspot?.value(forKey: "name")) as? String)
        
        /*
        let contactButton = UIButton(type: .system)
        contactButton.setImage(#imageLiteral(resourceName: "emergencyIcon").withRenderingMode(.alwaysOriginal), for: .normal)
        contactButton.frame = CGRect(x: 0, y: 0, width: 15, height: 15) */
        
       // self.navigationItem.rightBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "emergencyIcon").withRenderingMode(.alwaysOriginal), style: .plain, target: self, action: #selector(contactTapped))
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Call contact", style: .plain, target: self, action: #selector(contactTapped))
    }
    
    @objc func contactTapped () {
        print("Tapping Contact button")
        contactsEnabled = !contactsEnabled
        
        if(contactsEnabled) {
            //contactsTableView.isHidden = false
            
            // Create the alert
            let alert = UIAlertController(title: "Choose a contact to call", message: nil, preferredStyle: .alert)
            
            // Create the actions
            let firstNumberAction = UIAlertAction(title: "Susan", style: .default) { (action) in
                print("Call Susan's number")
                
                
                
                if let url = URL(string: "tel://+92111111111222"),
                    UIApplication.shared.canOpenURL(url) {
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                    else {
                        UIApplication.shared.openURL(url)
                    }
                }
                else {
                    // Add error message
                }
            }
            
            let secondNumberAction = UIAlertAction(title: "2nd contact..", style: .default) { (action) in
                print("Call 2nd contact's number")
            }
            
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                (action:UIAlertAction) in
                print ("pressed Cancel")
            }
            
            // Add actions to alert
            alert.addAction(firstNumberAction)
            alert.addAction(secondNumberAction)
            alert.addAction(cancelAction)
            
            // Show the alert
            self.present(alert,animated: true, completion: nil)
            
        }
        else {
            //contactsTableView.isHidden = true
        }
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: (Any)?) {
        
        // Pass the selected hotspot information to the hotspot overview view controller
        if let controller = segue.destination as? HotspotOverviewViewController, segue.identifier == "showOverview" {
            controller.addedToDos = addedToDos
            controller.addedImages = addedImages
            controller.selectedHotspot = selectedHotspot
            
        }

        // Pass the selected hotspot information to the navigation view controller
        if let controller = segue.destination as? navigationViewController, segue.identifier == "showNav" {
            controller.selectedHotspot = selectedHotspot
        }
    }
    
    ///// Can remove table view functions if using alerts to make the call  ///////
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return user.contacts.count
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell : UITableViewCell?
        let image = UIImage(named: "emergencyIcon")!
        
        
        cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        
        // Attach the image
        cell?.imageView?.image = image
    
        cell?.textLabel?.text = "Susan"
        
        cell?.detailTextLabel?.text = "604-444-555"
        
        // Resize the image within the cell
        let itemSize = CGSize.init(width: 50, height: 50)
        UIGraphicsBeginImageContextWithOptions(itemSize, false, UIScreen.main.scale)
        let imageRect = CGRect.init(origin: CGPoint.zero, size: itemSize)
        cell?.imageView?.image?.draw(in: imageRect)
        cell?.imageView?.image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        
        return cell!
    }
    
    
}
