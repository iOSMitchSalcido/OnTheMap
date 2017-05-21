//
//  UIViewController-Extensions.swift
//  OnTheMap
//
//  Created by Online Training on 5/20/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About UIViewController-Extensions.swift:
 
 Common functionality across multiple VC's used in app.
 Per Udacity reviewer comment, added this class extension to capture redundant code into a single location.
*/

import UIKit

extension UIViewController {
    
    // helper function for displaying alert for NetworkErrors enum type
    func showAlertForError(_ error: NetworkErrors) {
        
        /*
         Handle creation and presentation of an alertController. Function receives a NetworkError enum
         and filters for approproate title/message based on enum case and associated value.
         */
        
        // title and message for alert
        var alertTitle: String!
        var alertMessage: String!
        
        // filter out title/message from error
        switch error {
        case .networkError(let value):
            alertTitle = "Network Error"
            alertMessage = value
        case .operatorError(let value):
            alertTitle = "User Error"
            alertMessage = value
        case .generalError(let value):
            alertTitle = "Misc/unknown Error"
            alertMessage = value
        }
        
        // create alert and cancel action
        let alert = UIAlertController(title: alertTitle,
                                      message: alertMessage,
                                      preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        // add action, present alert
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    // present alert with cancel/proceed buttons
    func presentCancelProceedAlertWithTitle(_ title: String, message: String? = nil, completion: @escaping (UIAlertAction) -> Void) {
        
        // present alert. Completion is executed if "Proceed" button pressed
        
        // alert
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        // cancel action
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        // proceed action...execute completion passed in if pressed
        let proceedAction = UIAlertAction(title: "Proceed", style: .default, handler: completion)
        
        // add actions, present
        alert.addAction(cancelAction)
        alert.addAction(proceedAction)
        present(alert, animated: true, completion: nil)
    }
}
