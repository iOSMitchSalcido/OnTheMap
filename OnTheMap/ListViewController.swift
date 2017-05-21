//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About ListViewController.swift:
 VC to preset a tableView that contains a list of students (udacions) who are currently "On the Map". Includes functionality
 to refresh map, logout, and add/update location. Tapping cell wil present a URL of interest to the student.
 */

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var logoutBbi: UIBarButtonItem!      // logout bbi
    @IBOutlet weak var tableView: UITableView!          // ref to tableView
    @IBOutlet weak var dropPinBbi: UIBarButtonItem!     // bbi to post/update location
    @IBOutlet weak var refreshBbi: UIBarButtonItem!     // bbi to refresh student locations
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!  // indicate network activity

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide activityIndicator, reload data
        activateUIState(searching: false)
        tableView.reloadData()
    }
    
    func updateMap() {
        
        /*
         Function to update table. Retrieve student locations using ParseAPI and update tableView
         Procedure to update map:
         1) retrieve student locations
         2) update udacion cohort with students who are "on the map"
         3) update tableView
         */
        
        // UI state to start update
        activateUIState(searching: true)
        
        // 1) retrieve student locations
        ParseAPI().studentLocations() {
            (params, error) in
            
            // test error
            if let error = error {
                
                // show alert for error message
                DispatchQueue.main.async {
                    self.showAlertForError(error)
                }
            }
            // 2) update udacion cohort with students who are "on the map"
            else if let params = params, let students = params["results"] as? [[String:AnyObject]] {
                
                // good params...create new cohort from retrieved students
                StudentsOnTheMap.shared.newCohort(students)
            }
            
            // 3) update tableView
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activateUIState(searching: false)
            }
        }
    }
    
    @IBAction func logoutBbiPressed(_ sender: Any) {
        
        /*
         logout bbi pressed
         Invoke alert with option to log out of app
         */
        
        presentCancelProceedAlertWithTitle("Log out of 'On The Map' ?",
                                           message: nil) {
                                            (action) in
                                            
                                            // completion..delete session and dismiss VC
                                            UdacityAPI().deleteSession() // 170520: include per reviewer comment
                                            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func dropPinBbiPressed(_ sender: Any) {
        
        /*
         Invoke process to add/update map location. Function tests to see if student currently
         has a location posted. If so, then an alert is presented to allow the user to cancel out.
         If no currentl location or proceed pressed, the invoke PostLocationVC to allow student to
         continue process of posting location.
         */
        
        // closure to invoke PostLocationVC....save a few lines of code below...
        let postLocation = {() -> Void in
            let controller = self.storyboard?.instantiateViewController(withIdentifier: "PostLocationNavControllerID") as! UINavigationController
            self.present(controller, animated: true, completion: nil)
        }
        
        // test if currently on map
        if let _ = StudentsOnTheMap.shared.onTheMap(uniqueKey: StudentsOnTheMap.shared.myUniqueKey) {
            
            // student/user is currently on the map...present cancel/proceed alert
            presentCancelProceedAlertWithTitle("You currently have a location posted.",
                                               message: "Do you wish to overwrite location ?") {
                                                (action) in
                                                
                                                // post
                                                postLocation()
            }
        }
            // not on map..OK to invoke PostLocationVC
        else {
            postLocation()
        }
    }
    
    // update table with most recent students "on the map"
    @IBAction func refreshBbiPressed(_ sender: Any) {
        updateMap()
    }
}

extension ListViewController {
    
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
    
    // helper function for displaying alert
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
    
    // set enable state of UI elements...used when searching, network activity
    func activateUIState(searching: Bool) {
        
        activityIndicator.isHidden = !searching
        logoutBbi.isEnabled = !searching
        dropPinBbi.isEnabled = !searching
        refreshBbi.isEnabled = !searching
        
        if searching {
            activityIndicator.startAnimating()
            tableView.alpha = 0.3
        }
        else {
            activityIndicator.stopAnimating()
            tableView.alpha = 1.0
        }
    }
}

extension ListViewController: UITableViewDataSource, UITableViewDelegate {
    
    // row count
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return StudentsOnTheMap.shared.udacions.count
    }
    
    // cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCellID", for: indexPath)
        
        // get student. Set text to first/last name
        let student = StudentsOnTheMap.shared.udacions[indexPath.row]
        cell.textLabel?.text = student.firstName + " " + student.lastName
        return cell
    }
    
    // cell selected..open media
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // deselect
        tableView.deselectRow(at: indexPath, animated: true)
        
        // get student/url
        let student = StudentsOnTheMap.shared.udacions[indexPath.row]
        if let url = URL(string: student.mediaURL) {
            
            // open media...if possible
            UIApplication.shared.open(url, options: [:]) {
                (success) in
                
                // test for failure...show alert with message
                if !success {
                
                    let alert = UIAlertController(title: "Unable to open",
                                                  message: "Bad URL or possible security issue: \(url.absoluteString)",
                                                  preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
        // bad url...show alert
        else {
            
            let alert = UIAlertController(title: "Unable to open",
                                          message: "Bad or missing media URL info.",
                                          preferredStyle: .alert)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
        }
    }
}
