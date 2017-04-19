//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activityViewIndicator: UIActivityIndicatorView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // begin keyboard notifications for shifting up view when textField is editing
        startKeyboardNotifications()
        
        // hide activityViewIndicator
        activityViewIndicator.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // terminate keyboard notifications when view not visible
        terminateKeyboardNotifications()
    }
    @IBAction func loginButtonPressed(_ sender: Any) {
        
        // logging in..dim view and show activityIndicator
        stackView.alpha = 0.2
        activityViewIndicator.isHidden = false
        activityViewIndicator.startAnimating()
        
        UdacityAPI.shared.postSessionForUser("", password: "") {
            (params, error) in
            
            // test error
            if let error = error {
                
                var errorMessage:String!
                switch error {
                case .networkError(let value):
                    errorMessage = value
                case .operatorError(let value):
                    errorMessage = value
                }
                print(errorMessage)
            }
            
            // test params
            if let params = params {

                if let session = params["session"], let sessionID = session["id"] as? String {
                    print(sessionID)
                }
                DispatchQueue.main.async {
                    let tbc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID") as! UITabBarController
                    self.present(tbc, animated: true, completion: nil)
                }
            }
            
            DispatchQueue.main.async {
                self.stackView.alpha = 1.0
                self.activityViewIndicator.isHidden = true
                self.activityViewIndicator.stopAnimating()
            }
        }
    }
}

// keyboard show/hide functionality
extension LoginViewController {
    
    // begin keyboard show/hide notifications
    func startKeyboardNotifications() {
        
        // keyboard show
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        // keyboard hide
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }
    
    // terminate keyboard show/hide notifications
    func terminateKeyboardNotifications() {
        
        // keyboard show
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIKeyboardWillShow,
                                                  object: nil)
        // keyboard hide
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIKeyboardWillHide,
                                                  object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if view.superview?.frame.origin.y == 0.0 {
            self.view.superview?.frame.origin.y -= keyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {
        
        if view.superview?.frame.origin.y != 0.0 {
            view.superview?.frame.origin.y = 0.0
        }
    }
    
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        
        return 100.0
    }
}

// textField delegate functions
extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        //dismiss keyboard
        textField.resignFirstResponder()
        return true
    }
}
