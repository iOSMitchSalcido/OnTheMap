//
//  MapViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/16/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About MapViewController.swift:
 VC to present a mapView with pins to identify Udacity students (udacions) who are currently "On the Map". Includes functionality
 to refresh map, logout, and add/update location. Tapping pins wil present accessory with info button that can be used to
 access a URL of interest to the student.
*/

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView: MKMapView!              // mapView to present locations of students
    @IBOutlet weak var logoutBbi: UIBarButtonItem!      // bbi to log out of app/API
    @IBOutlet weak var dropPinBbi: UIBarButtonItem!     // bbi to add/update student location
    @IBOutlet weak var refreshBbi: UIBarButtonItem!     // bbi to refresh students who are currently "on the map"
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!  // indicate network activity
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // update map with locations of udacions who are "on the map"
        updateMap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // update map
        updateMapAnnotations()
    }
    
    // update map
    func updateMap() {
        
        /*
         Function to update map. Retrieve student locations using ParseAPI and create pinViews on map.
         Procedure to update map:
         1) retrieve student locations
         2) update udacion cohort with students who are "on the map"
         3) update pinViews on map
        */
        
        // UIstate to searching
        activateUIState(searching: true)
        
        // 1) retrieve student locations
        ParseAPI().studentLocations() {
            (params, error) in
            
            // test error
            if let error = error {
                
                // present alert for error
                DispatchQueue.main.async {
                    self.showAlertForError(error)
                }
            }
            // test for good params
            else if let params = params, let students = params["results"] as? [[String:AnyObject]] {
                
                // 2) update udacion cohort with students who are "on the map"
                StudentsOnTheMap.shared.newCohort(students)

                // 3) update pinViews on map
                DispatchQueue.main.async {
                    self.updateMapAnnotations()
                }
            }
            
            // restore UI state
            DispatchQueue.main.async {
                self.activateUIState(searching: false)
            }
        }
    }
    
    // logout bbi pressed
    @IBAction func logoutBbiPressed(_ sender: Any) {
        
        /*
         logout bbi pressed
         Invoke alert with option to log out of app
         */
        
        presentCancelProceedAlertWithTitle("Log out of 'On The Map' ?",
                                           message: nil) {
                                            (action) in
                                            
                                            // completion..delete session and dismiss VC
                                            UdacityAPI().deleteSession()
                                            self.dismiss(animated: true, completion: nil)
        }
    }

    // add/update location
    @IBAction func dropPinBbiPressed(_ sender: Any) {
        
        /*
         Invoke process to add/update map location. Function tests to see if student currently
         has a location posted. If so, then an alert is presented to allow the user to cancel out.
         If no currentl location or proceed pressed, then invoke PostLocationVC to allow student to
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
    
    // update map with most recent students "on the map"
    @IBAction func refreshBbiPressed(_ sender: Any) {
        updateMap()
    }
}

// helper functions
extension MapViewController {
    
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
            mapView.alpha = 0.3
        }
        else {
            activityIndicator.stopAnimating()
            mapView.alpha = 1.0
        }
    }
    
    // update map annot's
    func updateMapAnnotations() {
        
        // remove annot's currently on map
        mapView.removeAnnotations(mapView.annotations)
        
        // create annotArray, create annot's using student data and add to array
        var annotArray = [MKPointAnnotation]()
        for student in StudentsOnTheMap.shared.udacions {
            let annot = MKPointAnnotation()
            annot.coordinate = CLLocationCoordinate2D(latitude: student.latitude, longitude: student.longitude)
            annot.title = student.firstName + " " + student.lastName
            annot.subtitle = student.mediaURL
            annotArray.append(annot)
        }
        
        // add annot's to map
        mapView.addAnnotations(annotArray)
    }
}

// mapView delegate functions
extension MapViewController: MKMapViewDelegate {
    
    // finished rendering
    func mapViewDidFinishRenderingMap(_ mapView: MKMapView, fullyRendered: Bool) {
        activateUIState(searching: false)
    }
    
    // annotationView
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        // deque view
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        
        // create if nil
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }
        else {
            pinView!.annotation = annotation
        }
        
        return pinView
    }
    
    // accessory button tapped
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        
        // retrieve subtitle, URL from subtitle
        if let subtitle = view.annotation?.subtitle as? String, let url = URL(string: subtitle) {
            
            // open media...if possible
            UIApplication.shared.open(url, options: [:]) {
                (success) in
                
                // test for failure
                if !success {
                    
                    // failure opening mediaURL..show alert
                    let alert = UIAlertController(title: "Unable to open",
                                                  message: "Bad URL or possible security issue: \(url.absoluteString)",
                        preferredStyle: .alert)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                    alert.addAction(cancelAction)
                    self.present(alert, animated: true, completion: nil)
                }
            }
        }
    }
}
