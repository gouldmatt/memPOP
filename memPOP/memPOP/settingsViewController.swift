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

class settingsViewController: UIViewController {
    //===================================================================================================
    // MARK: Constants
    //===================================================================================================
    let notifCentre = UNUserNotificationCenter.current()
    
    // Notification IDs
    let addNotifID = "AddNotifReq"
    let activitiesNotifID = "ActivitiesNotifReq"
    //===================================================================================================
    // MARK: Variables
    //===================================================================================================
    var dateAddNotif = DateComponents()
    var dateActivitiesNotif = DateComponents()
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
        if (addHotspotNotif.selectedSegmentIndex == 0){ // addHotspotNotif - ON
            print("Add notif process for addHotspot")
            dateAddNotif.calendar = Calendar.current
            
            if (addHotspotNotifFreq.selectedSegmentIndex == 1){ // Weekly Freq
                print("weekly")
                dateAddNotif.weekday = 6 // Friday - end of week
                dateAddNotif.hour = 18 // 18:00 or 6 PM
            } else if (addHotspotNotifFreq.selectedSegmentIndex == 2){ // Monthly Freq
                print("monthly")
                dateAddNotif.weekOfMonth = 3 // Third week of the month
                dateAddNotif.hour = 18 // 18:00 or 6 PM
            } else { // Daily Freq
                print("Daily")
                dateAddNotif.hour = 18 // 18:00 or 6 PM
                //dateAddNotif.hour = 13
                //dateAddNotif.minute = 16
            }
            
            // Assign when to trigger notification - based on frequency set by user
            let addNotifTrigger = UNCalendarNotificationTrigger(dateMatching: dateAddNotif, repeats: true)
            
            // Set up the notification content
            let addNotifContent = UNMutableNotificationContent()
            addNotifContent.title = "Time to add some new hotspots!"
            addNotifContent.body = "If you haven't already input the latest memories, be sure to do so now in case you forget!"
            addNotifContent.sound = UNNotificationSound.default()
            
            // Create notif req
            let addNotifReq = UNNotificationRequest(identifier: addNotifID, content: addNotifContent, trigger: addNotifTrigger)
            
            // add addHotspot Notif request to notification centre. This will overwrite existing reminder if it exists.
            notifCentre.add(addNotifReq)
        } else { // addHotspotNotif - OFF
            print("Turn off AddHotspot Notif")
            notifCentre.removePendingNotificationRequests(withIdentifiers: [addNotifID])
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
            } else if (activitiesNotifFreq.selectedSegmentIndex == 2){ // Monthly Freq
                print("monthly")
                dateActivitiesNotif.weekOfMonth = 1 // First week of the month
                dateActivitiesNotif.hour = 8 // 8:00 or 8 AM
            } else { // Daily Freq
                print("Daily")
                dateActivitiesNotif.hour = 8 // 8:00 or 8 AM
                //dateActivitiesNotif.hour = 13
                //dateActivitiesNotif.minute = 19
            }
            
            // Assign when to trigger notification - based on frequency set by user
            let addNotifTrigger = UNCalendarNotificationTrigger(dateMatching: dateActivitiesNotif, repeats: true)
            
            // Set up the notification content
            let addNotifContent = UNMutableNotificationContent()
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
        }
    }
}


