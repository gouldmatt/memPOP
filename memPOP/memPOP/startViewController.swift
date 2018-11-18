//  ViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by nla52 on 10/23/18.
//  Programmers: Emily Chen, Matthew Gould
//  Copyright © 2018 Iota Inc. All rights reserved.

//===================================================================================================
// App entry point
//===================================================================================================

import CoreData
import UIKit

class startViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest: NSFetchRequest<HotspotMO> = HotspotMO.fetchRequest()
        do {
            let hotspots = try PersistenceService.context.fetch(fetchRequest)
            
            // Check if user is using the app for the first time
            if(hotspots.count == 0){
                
                // Create the alert
                let alert = UIAlertController(title: "Welcome to Mem-POP!", message: "Let's Set Up Your Personal Information", preferredStyle: .alert)
                
                // Create the actions
                let startAction = UIAlertAction(title: "Get Started", style: .default) {
                    (action:UIAlertAction) in
                    print ("Get Started")
                
                    self.performSegue(withIdentifier: "personInfo", sender: self)
                }
                
                // Add actions to alert
                alert.addAction(startAction)
                
                // Show the alert
                self.present(alert,animated: true, completion: nil)
            }
        }
        catch {
            
            // Show error message
            print("failed fetching")
        }
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

