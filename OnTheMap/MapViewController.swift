//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About MapViewController.swift:
 */

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var logoutBbi: UIBarButtonItem!
    @IBOutlet weak var dropPinBbi: UIBarButtonItem!
    @IBOutlet weak var refreshBbi: UIBarButtonItem!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //activateUIState(searching: true)
        updateMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
                
                var errorMessage:String!
                switch error {
                case .networkError(let value):
                    errorMessage = value
                case .operatorError(let value):
                    errorMessage = value
                case .generalError(let value):
                    errorMessage = value
                }
                print(errorMessage)
            }
            // test params
            else if let params = params, let students = params["results"] as? [[String:AnyObject]] {
                StudentsOnTheMap.shared.newCohort(students)
            }
            
            DispatchQueue.main.async {
                self.activateUIState(searching: false)
            }
        }
    }
    
    @IBAction func logoutBbiPressed(_ sender: Any) {
        
        presentCancelProceedAlertWithTitle("Log out of 'On The Map' ?",
                                           message: nil) {
                                            (action) in
                                            
                                            UdacityAPI.shared.deleteSession()
                                            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @IBAction func dropPinBbiPressed(_ sender: Any) {
        
    }
    @IBAction func refreshBbiPressed(_ sender: Any) {
        updateMap()
    }
}

extension MapViewController {
    
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
            mapView.alpha = 0.3
        }
        else {
            activityIndicator.stopAnimating()
            mapView.alpha = 1.0
        }
    }
}

extension MapViewController: MKMapViewDelegate {
    
    func mapViewDidFinishLoadingMap(_ mapView: MKMapView) {
    }
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        activateUIState(searching: false)
    }
}
