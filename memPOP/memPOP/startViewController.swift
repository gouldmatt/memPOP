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
            if(hotspots.count == 0) {
                // Instantiate a tutorialVC and make a transition
                let tutorialVC = storyboard?.instantiateViewController(withIdentifier: "tutorialViewController") as! tutorialViewController
                
                // Change view controller
                navigationController?.pushViewController(tutorialVC, animated: true)
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

