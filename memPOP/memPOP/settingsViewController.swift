//  settingsViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-24.
//  Programmers: Nicholas Lau
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Implementation coming in v3.0

import UIKit
import UserNotifications
import CoreData

class settingsViewController: UIViewController {
    //===================================================================================================
    // MARK: Constants
    //===================================================================================================
    let notifCentre = UNUserNotificationCenter.current()
    let fetchUser: NSFetchRequest<PersonInfoMO> = PersonInfoMO.fetchRequest()
    
    // Notification IDs
    let addNotifID = "AddNotifReq"
    let activitiesNotifID = "ActivitiesNotifReq"
    
    // Notification Content
    let addNotifContent = UNMutableNotificationContent()
    //===================================================================================================
    // MARK: Variables
    //===================================================================================================
    var dateAddNotif = DateComponents()
    var dateActivitiesNotif = DateComponents()
    var user: PersonInfoMO?
    var timer = Timer()
    //===================================================================================================
    // MARK: Outlets
    //===================================================================================================
    @IBOutlet weak var addHotspotNotif: UISegmentedControl!
    @IBOutlet weak var addHotspotNotifFreq: UISegmentedControl!
    @IBOutlet weak var activitiesNotif: UISegmentedControl!
    @IBOutlet weak var activitiesNotifFreq: UISegmentedControl!
    //===================================================================================================
    // MARK: Actions
    //===================================================================================================
    @IBAction func changeAddHotspotNotif(_ sender: Any) {
        print("received action")
        // check if permission granted. Do not add notif otherwise
        notifCentre.getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else {
                print("permission check failed")
                self.alertPermissionDisabled()
                return
            }
        }
        configAddHotspotNotif()
    }
    
    @IBAction func changeAddHotspotNotifFreq(_ sender: Any) {
        print("received action")
        // check if permission granted. Do not add notif otherwise
        notifCentre.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else {
                print("permission check failed")
                self.alertPermissionDisabled()
                return
            }
        }
        configAddHotspotNotif()
    }
    
    @IBAction func changeActivitiesNotif(_ sender: Any) {
        notifCentre.getNotificationSettings { (settings) in
            // check if permission granted. Do not add notif otherwise
            guard settings.authorizationStatus == .authorized else {
                print("permission check failed")
                self.alertPermissionDisabled()
                return
            }
        }
        configActivityNotif()
    }
    
    @IBAction func changeActivitiesNotifFreq(_ sender: Any) {
        // check if permission granted. Do not add notif otherwise
        notifCentre.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else {
                print("permission check failed")
                self.alertPermissionDisabled()
                return
            }
        }
        configActivityNotif()
    }
    //===================================================================================================
    // MARK: Override Functions
    //===================================================================================================
    override func viewDidLoad() {
        super.viewDidLoad()
        notifCentre.requestAuthorization(options: [.sound, .alert, .badge]){ (grantedNotif, err) in
            print("Granted notification permission")
        }
        
        notifCentre.getNotificationSettings(){ (settings) in
            if (settings.alertSetting == .enabled){
                print("check good")
                
                // Check if user data can be fetched
                do {
                    let userFetch = try PersistenceService.context.fetch(self.fetchUser)
                    if(userFetch.count == 1){
                        self.user = userFetch[0]
                    }
                }
                catch {
                    print("failed user fetch")
                }
                
                // The line below forces the fetch notification settings to update UI on the main thread
                DispatchQueue.main.async{
                    // Fetch addHotspot notif settings to put to settings controls
                    if (self.user?.addHotspotNotifSetting == 1){ // Daily
                        self.addHotspotNotif.selectedSegmentIndex = 0;
                        self.addHotspotNotifFreq.selectedSegmentIndex = 0;
                    }
                    else if (self.user?.addHotspotNotifSetting == 2){ // Weekly
                        self.addHotspotNotif.selectedSegmentIndex = 0;
                        self.addHotspotNotifFreq.selectedSegmentIndex = 1;
                    }
                    else if (self.user?.addHotspotNotifSetting == 3){ // Monthly
                        self.addHotspotNotif.selectedSegmentIndex = 0;
                        self.addHotspotNotifFreq.selectedSegmentIndex = 2;
                    }
                    else { // Off
                        self.addHotspotNotif.selectedSegmentIndex = 1;
                        self.addHotspotNotifFreq.selectedSegmentIndex = 0;
                    }
                    
                    // Fetch activities Notificaiton settings to put on segment controls
                    if (self.user?.activitiesNotifSetting == 1){ // Daily
                        self.activitiesNotif.selectedSegmentIndex = 0;
                        self.activitiesNotifFreq.selectedSegmentIndex = 0;
                    }
                    else if (self.user?.activitiesNotifSetting == 2){ // Weekly
                        self.activitiesNotif.selectedSegmentIndex = 0;
                        self.activitiesNotifFreq.selectedSegmentIndex = 1;
                    }
                    else if (self.user?.activitiesNotifSetting == 3){ // Monthly
                        self.activitiesNotif.selectedSegmentIndex = 0;
                        self.activitiesNotifFreq.selectedSegmentIndex = 2;
                    }
                    else { // Off
                        self.activitiesNotif.selectedSegmentIndex = 1;
                        self.activitiesNotifFreq.selectedSegmentIndex = 0;
                    }
                }
                
            } else {
                print("check bad")
                self.alertPermissionDisabled()
            }
        }
        
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = false
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //===================================================================================================
    // MARK: Functions
    //===================================================================================================
    
    // Configure the notification settings for Add Hotspot
    func configAddHotspotNotif(){
        do {
            let userFetch = try PersistenceService.context.fetch(self.fetchUser)
            if(userFetch.count == 1){
                self.user = userFetch[0]
            }
        }
        catch {
            print("failed user fetch")
        }
        
        if (addHotspotNotif.selectedSegmentIndex == 0){ // addHotspotNotif - ON
            print("check good")
            print("Add notif process for addHotspot")
            dateAddNotif.calendar = Calendar.current
            if (addHotspotNotifFreq.selectedSegmentIndex == 1){ // Weekly Freq
                print("weekly")
                dateAddNotif.weekday = 6 // Friday - end of week
                dateAddNotif.hour = 18 // 18:00 or 6 PM
                user?.addHotspotNotifSetting = 2; // Set notification setting
            } else if (addHotspotNotifFreq.selectedSegmentIndex == 2){ // Monthly Freq
                print("monthly")
                dateAddNotif.weekOfMonth = 3 // Third week of the month
                dateAddNotif.hour = 18 // 18:00 or 6 PM
                user?.addHotspotNotifSetting = 3; // Set notification setting
            } else { // Daily Freq
                print("Daily")
                dateAddNotif.hour = 18 // 18:00 or 6 PM
                user?.addHotspotNotifSetting = 1; // Set notification setting
            }
            
            // Assign when to trigger notification - based on frequency set by user
            let addNotifTrigger = UNCalendarNotificationTrigger(dateMatching: dateAddNotif, repeats: true)
            
            // Set up the notification content
            addNotifContent.title = "Time to add some new hotspots!"
            addNotifContent.body = alertMsgAddHotspot()
            addNotifContent.sound = UNNotificationSound.default()
            
            // Create notif req
            let addNotifReq = UNNotificationRequest(identifier: addNotifID, content: addNotifContent, trigger: addNotifTrigger)
            
            // add addHotspot Notif request to notification centre. This will overwrite existing reminder if it exists.
            notifCentre.add(addNotifReq)
        } else { // addHotspotNotif - OFF
            print("Turn off AddHotspot Notif")
            notifCentre.removePendingNotificationRequests(withIdentifiers: [addNotifID])
            user?.addHotspotNotifSetting = 0;
        }
    }
    
    func configActivityNotif(){
        if (activitiesNotif.selectedSegmentIndex == 0){ // activitiesNotif - ON
            print("Add notif process for activitiesNotif")
            dateActivitiesNotif.calendar = Calendar.current
            
            if (activitiesNotifFreq.selectedSegmentIndex == 1){ // Weekly Freq
                print("weekly")
                dateActivitiesNotif.weekday = 2 // Monday - first weekday
                dateActivitiesNotif.hour = 8 // 8:00 or 8 AM
                user?.activitiesNotifSetting = 2; // Set notification setting
            } else if (activitiesNotifFreq.selectedSegmentIndex == 2){ // Monthly Freq
                print("monthly")
                dateActivitiesNotif.weekOfMonth = 1 // First week of the month
                dateActivitiesNotif.hour = 8 // 8:00 or 8 AM
                user?.activitiesNotifSetting = 3; // Set notification setting
            } else { // Daily Freq
                print("Daily")
                dateActivitiesNotif.hour = 8 // 8:00 or 8 AM
                user?.activitiesNotifSetting = 1; // Set notification setting
            }
            
            // Assign when to trigger notification - based on frequency set by user
            let addNotifTrigger = UNCalendarNotificationTrigger(dateMatching: dateActivitiesNotif, repeats: true)
            
            // Set up the notification content
            addNotifContent.title = "Time to be Active!"
            addNotifContent.body = "Being active is great for your health. Use the navigation feature to get to your favourite hotspots!"
            addNotifContent.sound = UNNotificationSound.default()
            
            // Create notif request
            let addNotifReq = UNNotificationRequest(identifier: activitiesNotifID, content: addNotifContent, trigger: addNotifTrigger)
            
            // add Activities Notif request to notification centre. This will overwrite existing reminder if it exists.
            notifCentre.add(addNotifReq)
        } else { // activitiesNotif - OFF
            print("Turn off Activities Notif")
            notifCentre.removePendingNotificationRequests(withIdentifiers: [activitiesNotifID])
            user?.activitiesNotifSetting = 0; // Set notification setting
        }
    }
    
    func alertPermissionDisabled() {
        // Create the alert
        let alert = UIAlertController(title: "Request for Notifications Permission Denied", message: "memPOP needs to be able to have permission to notify you of things to do.\nTo use this feature, go to Settings->memPOP->Notifications->Check Allow Notifications with all options enabled and Temporary banner.", preferredStyle: .alert)
        
        // Create the actions
        let okAction = UIAlertAction(title: "Okay", style: .cancel) {
            (action:UIAlertAction) in
            print ("pressed OK")
        }
        
        // Add actions to alert
        alert.addAction(okAction)
        
        // Show the alert
        self.present(alert,animated: true, completion: nil)
    }
    
    // Prints the body message for notification alerts to add a new hotspot
    func alertMsgAddHotspot() -> String {
        // fetch any existing user information
        do {
            let userFetch = try PersistenceService.context.fetch(fetchUser)
            if(userFetch.count == 1){
                user = userFetch[0]
            }
        }
        catch {
            print("failed user fetch")
        }
        
        // Set up the notification content
        
        // Fewest Food hotspots message
        if ((user?.foodNum)! < (user?.funNum)! && (user?.foodNum)! < (user?.taskNum)!){
            let alertBody = "Looks like there aren't many Food-related Hotspots (There are only " + String((user?.foodNum)!) + " Food Hotspots. Enter some more!"
            return alertBody
        } // Fewest Fun hotspots message
        else if ((user?.funNum)! < (user?.foodNum)! && (user?.funNum)! < (user?.taskNum)!){
            let alertBody = "Looks like there aren't many Fun-related Hotspots (There are only " + String((user?.funNum)!) + " Fun Hotspots. Enter some more!"
            return alertBody
        } // Fewest task hotspot message
        else if ((user?.taskNum)! < (user?.foodNum)! && (user?.taskNum)! < (user?.funNum)!){
            let alertBody = "Looks like there aren't many Task-related Hotspots (There are only " + String((user?.taskNum)!) + " Task Hotspots. Enter some more!"
            return alertBody
        } // Default hotspot message
        else {
            let alertBody = "If you haven't already input the latest memories, be sure to do so now in case you forget!"
            return alertBody
        }
    }
}


