//
//  ViewController.swift
//  memPOP
//  Group 9, Iota Inc.
//  Created by nla52 on 10/23/18.
//  Copyright © 2018 Iota Inc. All rights reserved.
//

//===============================================================
// App entry point
//===============================================================

import UIKit

class startViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

