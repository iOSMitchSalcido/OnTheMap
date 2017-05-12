//
//  ListViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About ListViewController.swift:
 */

import UIKit

class ListViewController: UIViewController {
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var logoutBbi: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var dropPinBbi: UIBarButtonItem!
    @IBOutlet weak var refreshBbi: UIBarButtonItem!
    
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
         Invoke ParseAPI method to retrieve student locations
         */
        
        activateUIState(searching: true)
        
        ParseAPI.shared.studentLocations() {
            (params, error) in
            
            // test error
            if let error = error {
                
                // show alert for error message
                DispatchQueue.main.async {
                    self.showAlertForError(error)
                }
            }
            // test params
            else if let params = params, let students = params["results"] as? [[String:AnyObject]] {
                
                // good params...create new cohort from retrieved students
                StudentsOnTheMap.shared.newCohort(students)
            }
            
            // update UI
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.activateUIState(searching: false)
            }
        }
    }
    
    @IBAction func logoutBbiPressed(_ sender: Any) {
        
        presentCancelProceedAlertWithTitle("Log out of 'On The Map' ?",
                                           message: nil) {
                                            (action) in
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
    
    @IBAction func refreshBbiPressed(_ sender: Any) {
        updateMap()
    }
}

extension ListViewController {
    
    // present an alertView, Cancel/Proceed
    func presentCancelProceedAlertWithTitle(_ title: String, message: String?, completion: @escaping (UIAlertAction) -> Void) {
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        let cancelAction = UIAlertAction(title: "Cancel",
                                         style: .cancel,
                                         handler: nil)
        
        let proceedAction = UIAlertAction(title: "Proceed", style: .default, handler: completion)
        
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
        return StudentsOnTheMap.shared.udacionCount
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
            
            // open media...is possible
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
