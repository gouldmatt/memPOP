//
//  ViewController.swift
//  memPOP
//
//  Created by nla52 on 10/23/18.
//  Copyright © 2018 Iota Inc. All rights reserved.
//

import UIKit

class startViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewWillAppear(_ animated:Bool) {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

