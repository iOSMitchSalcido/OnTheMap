//
//  PortraitNavController.swift
//  OnTheMap
//
//  Created by Online Training on 4/29/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About PortraitNavController.swift:
 NC with orientation property overridden to support only portrait
*/

import UIKit

class PortraitNavController: UINavigationController {

    // portrait
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
