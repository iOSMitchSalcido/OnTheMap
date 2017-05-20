//
//  LoginViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About LoginViewController.swift:
 Handle login process for app. Username and password textFields are provided, along with button for login. Upon entry
 of username and password, pressing login button will invoke UdacityAPI function to post a new session. If post is
 successful, then VC will invoke tabBar controller which contains main views for app, map and list of students on map.
 */

import UIKit

class LoginViewController: UIViewController {
    
    // ref to textFields
    @IBOutlet weak var usernameTextField: UITextField!      // textField for username
    @IBOutlet weak var passwordTextField: UITextField!      // textField for password
    @IBOutlet weak var loginButton: UIButton!               // button for login
    @IBOutlet weak var stackView: UIStackView!              // ref to stackView. Used for dimming view indicating network activity
    @IBOutlet weak var activityViewIndicator: UIActivityIndicatorView!  // Used for indicating network activity
    
    // portrait orientation
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // loginButton enable
        loginButton.isEnabled = !(usernameTextField.text?.isEmpty)! && !(passwordTextField.text?.isEmpty)!
        
        // begin keyboard notifications for shifting up view when textField is editing
        startKeyboardNotifications()
        
        // hide activityView
        self.activateUILoginState(loggingIn: false)
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
         UdacityAPI.
         
         Of the params returned from the post, "uniqueKey" and "registered" are checked. If good, then invoke
         tabBar controller containing main app views, map and list of students on the map...
         */
        
        // logging in..dim view and show activityIndicator during session post
        activateUILoginState(loggingIn: true)
        
        // invoke API function to post session
        UdacityAPI().postSessionForUser(usernameTextField.text!, password: passwordTextField.text!) {
            (params, error) in
            
            // test error
            if let error = error {
                // error during task....present alert
                DispatchQueue.main.async {
                    self.showAlertForError(error)
                    self.activateUILoginState(loggingIn: false)
                }
            }
            // test for good POST session (valid key and registered = true)
            else if let account = params?[UdacityAPI.Account.account] as? [String:AnyObject],
                let uniqueKey = account[UdacityAPI.Account.key] as? String,
                let registered = account[UdacityAPI.Account.registered] as? Bool,
                registered == true {
                
                // assign to uniqueKey
                StudentsOnTheMap.shared.myUniqueKey = uniqueKey
                
                // load tabVC
                DispatchQueue.main.async {
                    let tbc = self.storyboard?.instantiateViewController(withIdentifier: "TabBarControllerID") as! UITabBarController
                    self.present(tbc, animated: true, completion: nil)
                }
            }
            // bad registration error
            else {
                
                // error during registration/session post
                let error = NetworkErrors.operatorError("Unregistered user ! Please verify credentials and try again")
                DispatchQueue.main.async {
                    self.showAlertForError(error)
                    self.activateUILoginState(loggingIn: false)
                }
            }
        }
    }
}

// helper functions
extension LoginViewController {

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
    
    // UI state while logging in
    func activateUILoginState(loggingIn: Bool) {
        
        if loggingIn {
            stackView.alpha = 0.2
            activityViewIndicator.isHidden = false
            activityViewIndicator.startAnimating()
        }
        else {
            stackView.alpha = 1.0
            activityViewIndicator.isHidden = true
            activityViewIndicator.stopAnimating()
        }
    }
}

// keyboard show/hide functionality...also tap gesture
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
