//  settingsViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by Emily on 2018-10-24.
//  Programmers: Nicholas Lau, Emily Chen, Matthew Gould, Diego Martin Marcelo
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// Changes that have been made in v3.0
// Implemented a notification system to remind the user to add new hotspots
// Added a way for user to disable notifications
// Implemented a reset statistics action

import UIKit
import UserNotifications
import CoreData

class settingsViewController: UIViewController {
    
    //===================================================================================================
    // MARK: Constants
    //===================================================================================================
    let notifCentre = UNUserNotificationCenter.current()
    let fetchUser: NSFetchRequest<PersonInfoMO> = PersonInfoMO.fetchRequest()
    let fetchHotspot: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()
    
    // Notification IDs
    let addNotifID = "AddNotifReq"
    let activitiesNotifID = "ActivitiesNotifReq"
    
    // Notification Content
    let addNotifContent = UNMutableNotificationContent()
    
    //AddHotspot Notif Times
    let hourAddHotspotNotif = 14 // Default 18:00 or 6 PM
    let minuteAddHotspotNotif = 6
    //Activities Notif times
    let hourActivitiesNotif = 8 // Default 08:00 or 8 AM
    let minuteActivitiesNotif = 0
    
    //===================================================================================================
    // MARK: Variables
    //===================================================================================================
    var dateAddNotif = DateComponents()
    var dateActivitiesNotif = DateComponents()
    var user: PersonInfoMO?
    
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
    @IBAction func resetStats(_ sender: UIButton) {
        // Added action to reset all statistics collected from the user
        do {
            let hotspotFetch = try PersistenceService.context.fetch(fetchHotspot)
            let userFetch = try PersistenceService.context.fetch(fetchUser)
            
            if(userFetch.count == 1) {
                // Create the alert
                let alert = UIAlertController(title: "Reset Statistics", message: "Are you sure you want to reset all statistics collected?", preferredStyle: .alert)
                
                // Create the actions
                let deleteAction = UIAlertAction(title: "Reset", style: .destructive) {
                    (action:UIAlertAction) in
                    
                    // For debugging
                    print ("pressed Reset")
                    
                    // Reset statistics back to zero for all hotspots
                    for hotspot in hotspotFetch {
                        hotspot.timesVisit = 0
                        PersistenceService.saveContext()
                    }
                }
                
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {
                    (action:UIAlertAction) in
                    print ("pressed Cancel")
                }
                
                // Add actions to alert
                alert.addAction(deleteAction)
                alert.addAction(cancelAction)
                
                // Show the alert
                self.present(alert,animated: true, completion: nil)
            }
        }
        catch {
            print("failed user fetch")
        }
        
    }
    
    @IBAction func changeAddHotspotNotif(_ sender: Any) {
        print("received action")
        // Check if permission granted. Do not add notif otherwise
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
        // Check if permission granted. Do not add notif otherwise
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
            // Check if permission granted. Do not add notif otherwise
            guard settings.authorizationStatus == .authorized else {
                print("permission check failed")
                self.alertPermissionDisabled()
                return
            }
        }
        configActivityNotif()
    }
    
    @IBAction func changeActivitiesNotifFreq(_ sender: Any) {
        // Check if permission granted. Do not add notif otherwise
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
            self.notifCentre.getNotificationSettings(){ (settings) in
                if (settings.alertSetting == .enabled){
                    print("notifications: check good")
                    
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
                }
                else {
                    print("notifications: check bad")
                    self.alertPermissionDisabled()
                }
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
    /*
     Notification Setting values for addHotspotNotifSetting and activitiesNotifSetting
     0 = OFF
     1 = ON, Daily
     2 = ON, Weekly
     3 = ON, Monthly
    */
    
    // Configure the notification settings for Add Hotspot on the settings page
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
                dateAddNotif.hour = hourAddHotspotNotif
                dateAddNotif.minute = minuteAddHotspotNotif
                user?.addHotspotNotifSetting = 2; // Set notification setting
            }
            else if (addHotspotNotifFreq.selectedSegmentIndex == 2){ // Monthly Freq
                print("monthly")
                dateAddNotif.weekOfMonth = 3 // Third week of the month
                dateAddNotif.hour = hourAddHotspotNotif
                dateAddNotif.minute = minuteAddHotspotNotif
                user?.addHotspotNotifSetting = 3; // Set notification setting
            }
            else { // Daily Freq
                print("Daily")
                dateAddNotif.hour = hourAddHotspotNotif
                dateAddNotif.minute = minuteAddHotspotNotif
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
            
            // Add addHotspot Notif request to notification centre. This will overwrite existing reminder if it exists.
            notifCentre.add(addNotifReq)
        }
        else { // addHotspotNotif - OFF
            print("Turn off AddHotspot Notif")
            notifCentre.removePendingNotificationRequests(withIdentifiers: [addNotifID])
            user?.addHotspotNotifSetting = 0;
        }
    }
    
    // Configure the notification settings for being active on the settings page
    func configActivityNotif(){
        if (activitiesNotif.selectedSegmentIndex == 0){ // activitiesNotif - ON
            print("Add notif process for activitiesNotif")
            dateActivitiesNotif.calendar = Calendar.current
            
            if (activitiesNotifFreq.selectedSegmentIndex == 1){ // Weekly Freq
                print("weekly")
                dateActivitiesNotif.weekday = 2 // Monday - first weekday
                dateActivitiesNotif.hour = hourActivitiesNotif
                dateActivitiesNotif.minute = minuteActivitiesNotif
                user?.activitiesNotifSetting = 2; // Set notification setting
            }
            else if (activitiesNotifFreq.selectedSegmentIndex == 2){ // Monthly Freq
                print("monthly")
                dateActivitiesNotif.weekOfMonth = 1 // First week of the month
                dateActivitiesNotif.hour = hourActivitiesNotif
                dateActivitiesNotif.minute = minuteActivitiesNotif
                user?.activitiesNotifSetting = 3; // Set notification setting
            }
            else { // Daily Freq
                print("Daily")
                dateActivitiesNotif.hour = hourActivitiesNotif
                dateActivitiesNotif.minute = minuteActivitiesNotif
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
            
            // Add Activities Notif request to notification centre. This will overwrite existing reminder if it exists.
            notifCentre.add(addNotifReq)
        }
        else { // activitiesNotif - OFF
            print("Turn off Activities Notif")
            notifCentre.removePendingNotificationRequests(withIdentifiers: [activitiesNotifID])
            user?.activitiesNotifSetting = 0; // Set notification setting
        }
    }
    
    // Alert message function when permission for notificaitons is denied. Appears in settings page if attempting to change notification setting without granted permission.
    func alertPermissionDisabled() {
        // Create the alert
        let alert = UIAlertController(title: "Request for Notifications Permission Denied", message: "Mem-POP requires your permission to enable push notifications.\nTo use this feature, go to Settings > memPOP > Notifications", preferredStyle: .alert)
        
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
        // Fetch any existing user information
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
        print((user?.foodNum)!)
        print((user?.funNum)!)
        print((user?.taskNum)!)
        
        if ((user?.foodNum)! <= (user?.funNum)! && (user?.foodNum)! <= (user?.taskNum)!){
            let alertBody = "Looks like there aren't many Food-related Hotspots (There are " + String((user?.foodNum)!) + " Food Hotspots). Enter some more!"
            return alertBody
        } // Fewest Fun hotspots message
        else if ((user?.funNum)! <= (user?.foodNum)! && (user?.funNum)! <= (user?.taskNum)!){
            let alertBody = "Looks like there aren't many Fun-related Hotspots (There are " + String((user?.funNum)!) + " Fun Hotspots). Enter some more!"
            return alertBody
        } // Fewest task hotspot message
        else if ((user?.taskNum)! <= (user?.foodNum)! && (user?.taskNum)! <= (user?.funNum)!){
            let alertBody = "Looks like there aren't many Task-related Hotspots (There are " + String((user?.taskNum)!) + " Task Hotspots). Enter some more!"
            return alertBody
        } // Default hotspot message
        else {
            let alertBody = "If you haven't already input your latest memories, enter some now!"
            return alertBody
        }
    }
    
    // Used to update the notification body message for addHotspot when changes are made to the number of hotspots and category
    public func modifyAddHotspotNotif(){
        notifCentre.requestAuthorization(options: [.sound, .alert, .badge]){ (grantedNotif, err) in
            // Check if permission granted. Do not add notif otherwise
            self.notifCentre.getNotificationSettings { (settings) in
                guard settings.authorizationStatus == .authorized else {
                    print("permission check failed")
                    self.alertPermissionDisabled()
                    return
                }
            }
            // Fetch any existing user information
            do {
                let userFetch = try PersistenceService.context.fetch(self.fetchUser)
                if(userFetch.count == 1){
                    self.user = userFetch[0]
                }
            }
            catch {
                print("failed user fetch")
            }
            
            
            if (self.user?.addHotspotNotifSetting != 0){ // addHotspotNotif is on, then do below
                print("Modify notif process for addHotspot")
                self.dateAddNotif.calendar = Calendar.current
                if (self.user?.addHotspotNotifSetting == 2){ // Weekly Freq setting
                    print("weekly")
                    self.dateAddNotif.weekday = 6 // Friday - end of week
                    self.dateAddNotif.hour = self.hourAddHotspotNotif
                    self.dateAddNotif.minute = self.minuteAddHotspotNotif
                    self.user?.addHotspotNotifSetting = 2; // Set notification setting
                }
                else if (self.user?.addHotspotNotifSetting == 3){ // Monthly Freq setting
                    print("monthly")
                    self.dateAddNotif.weekOfMonth = 3 // Third week of the month
                    self.dateAddNotif.hour = self.hourAddHotspotNotif
                    self.dateAddNotif.minute = self.minuteAddHotspotNotif
                    self.user?.addHotspotNotifSetting = 3; // Set notification setting
                }
                else { // Daily Freq setting
                    print("Daily")
                    self.dateAddNotif.hour = self.hourAddHotspotNotif
                    self.dateAddNotif.minute = self.minuteAddHotspotNotif
                    self.user?.addHotspotNotifSetting = 1; // Set notification setting
                }
                
                // Assign when to trigger notification - based on frequency set by user
                let addNotifTrigger = UNCalendarNotificationTrigger(dateMatching: self.dateAddNotif, repeats: true)
                
                // Set up the notification content
                self.addNotifContent.title = "Time to add some new hotspots!"
                self.addNotifContent.body = self.alertMsgAddHotspot()
                self.addNotifContent.sound = UNNotificationSound.default()
                
                // Create notif req
                let addNotifReq = UNNotificationRequest(identifier: self.addNotifID, content: self.addNotifContent, trigger: addNotifTrigger)
                
                // Add addHotspot Notif request to notification centre. This will overwrite existing reminder if it exists.
                self.notifCentre.add(addNotifReq)
            }
            else {
                print("doing nothing since notificaiton addHotspot not enabled.")
            }
        }
    }
}


