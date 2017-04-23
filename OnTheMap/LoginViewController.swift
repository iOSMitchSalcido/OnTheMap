//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class LoginViewController: UIViewController {
    
    // ref to textFields
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    // ref to loginButton..need to enable/disable based in UI state
    @IBOutlet weak var loginButton: UIButton!
    
    // ref to stackView and activityView..dimmed/activite to indicate network activity
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activityViewIndicator: UIActivityIndicatorView!
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // disable loginButton...no valid text yet
        loginButton.isEnabled = false
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
        
        /*
         Handle login process. This involves posting a session to the Udacity API.
         The user/password are retirieved from the textFields and passed into the
         UdacityAPI. Functionality included for dimming and showing activityView
         for improved UI experience
         */
        
        // logging in..dim view and show activityIndicator during session post
        stackView.alpha = 0.2
        activityViewIndicator.isHidden = false
        activityViewIndicator.startAnimating()
        
        // invoke API function to post session
        UdacityAPI.shared.postSessionForUser(usernameTextField.text!, password: passwordTextField.text!) {
            (params, error) in
            
            // test error
            if let error = error {
                // error of some sort during task....present alert
                self.showAlertForError(error)
            }
            // test for good POST session (valid key and registered = true)
            else if let account = params?[UdacityAPI.Account.account] as? [String:AnyObject],
                let key = account[UdacityAPI.Account.key] as? String,
                let registered = account[UdacityAPI.Account.registered] as? Bool,
                registered == true {
                
                // good key/registration. OK to invoke tabVC
                
                // set uniqueKey in API
                UdacityAPI.shared.myUniqueKey = key
                
                // load tabVC
                DispatchQueue.main.async {
                    let tbc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID") as! UITabBarController
                    self.present(tbc, animated: true, completion: nil)
                }
            }
            // bad registration error
            else {
                
                // error during registration/session post, but successful params created
                let error = NetworkErrors.operatorError("Unregistered user ! Please verify credentials and try again")
                self.showAlertForError(error)
            }
            
            // restore UI
            DispatchQueue.main.async {
                self.stackView.alpha = 1.0
                self.activityViewIndicator.isHidden = true
                self.activityViewIndicator.stopAnimating()
            }
        }
    }
}

extension LoginViewController {

    // alert
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
    
    // keyboard is about to show
    func keyboardWillShow(_ notification: Notification) {
        
        // test for keyboard shift. Shift up if not currently shifted
        if view.superview?.frame.origin.y == 0.0 {
            
            // shift..experimentation showed deceasing by ~1.5 looks good
            self.view.superview?.frame.origin.y -= keyboardHeight(notification) / 1.5
            
            // disable loginButton while shifted up
            loginButton.isEnabled = false
        }
    }
    
    // keyboard is about to hide
    func keyboardWillHide(_ notification: Notification) {
        
        // test for keyboard shift. Shift back down if currently shifted
        if view.superview?.frame.origin.y != 0.0 {
            view.superview?.frame.origin.y = 0.0
            
            // test for valid text in username/password textFields before
            // enabling loginButton
            if (usernameTextField.text?.isEmpty)! || (passwordTextField.text?.isEmpty)! {
                loginButton.isEnabled = false
            }
            else {
                loginButton.isEnabled = true
            }
        }
    }
    
    // retrieve height of keyboard
    func keyboardHeight(_ notification: Notification) -> CGFloat {
        
        // get keyboard from rect from notification dictionary
        if let userInfo = notification.userInfo,
            let keyboardFrameValue = userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue {
            
            return keyboardFrameValue.cgRectValue.size.height
        }
        else {
            // failed, return 100.0..also works OK for shift value
            return 100.0
        }
    }
    
    // single tap in view
    @IBAction func singleTapDetected(_ sender: UITapGestureRecognizer) {
        
        // dismiss keyboard, end editing
        view.endEditing(true)
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
