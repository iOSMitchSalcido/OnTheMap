//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/22/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About PostLocationViewController.swift:
 Handle posting location to map.
 VC initially prompts user to enter text for a location (city, town, etc). This text is then
 geocoded into a CLPlacemark class, which contains coordinate data used to post location.
 
 When location is successfully geocoded, the user is prompted to enter a URL (linked in, facebook, etc).
 Upon successful entering of URL, the user can then "post" their location. If successful post, this VC is
 then dismissed.
 */

import UIKit
import MapKit

class PostLocationViewController: UIViewController {

    // ref to UI elements
    @IBOutlet weak var stackView: UIStackView!                      // dim alpha when searching geo or posting
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!  // unhide/animate when searching geo or posting
    @IBOutlet weak var cancelBbi: UIBarButtonItem!                  // cancel operation, dismiss VC
    @IBOutlet weak var button: UIButton!                            // dual purpose. Geocode text or post location
    @IBOutlet weak var whereAtLabel: UILabel!                       // label to show info/prompt user action
    @IBOutlet weak var textField: UITextField!                      // for user to enter geo string or URL
    @IBOutlet weak var mapView: MKMapView!                          // show user location upon succesful geocoding
    
    // placemark...set after location found
    // used when posting location. Coordinate data retieved from CLPlacemark
    // Also used to steer functionality of button: geoCode or post location depending if nil
    var placemark: CLPlacemark?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // hide map and set UI state
        mapView.isHidden = true
        activateUIState(searching: false)
    }
    
    // dismiss action for cancelBbi
    @IBAction func cancelBbiPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    // button pressed
    @IBAction func buttonPressed(_ sender: Any) {
        
        /*
         Button is dual purpose. Use for retieving location if myLocationPlaceMark is nil.
         Otherwise used for posting/updating location
        */
        
        // test myLocationPlaceMark
        if placemark == nil {
            
            // new location
            locateOnMap()
        }
        else {
            
            // post location
            
            // test if already on the map to steer into update or post
            if let student = StudentsOnTheMap.shared.onTheMap(uniqueKey: StudentsOnTheMap.shared.myUniqueKey) {
                
                // already on map...update
                updateLocationForStudent(student.0)
            }
            else {
                
                // not currently on map....post location
                postLocation()
            }
        }
    }
}

// location, posting functions
extension PostLocationViewController {
    
    // locate
    func locateOnMap() {
    
        /*
         function to retieve location data from text. Using CLGeocoder, retrieve placemark
         and coord data for use on map
         */
        
        // UI state
        activateUIState(searching: true)
        
        // geoCoder. Geocode string
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textField.text!) {
            (placemark, error) in
            
            // !! NOTE !! Geocode completion is executed on main...OK to update UI without Dispatch
            
            // error test
            if let error = error as? CLError.Code {

                // error. Create error message
                // ..Using the more "pertinent" error's defined in CLError.Code
                var networkError: NetworkErrors!
                switch error {
                case .locationUnknown:
                    networkError = NetworkErrors.operatorError("Unknown location.")
                case .network:
                    networkError = NetworkErrors.networkError("Network unavailable or error.")
                case .geocodeFoundNoResult:
                    networkError = NetworkErrors.operatorError("No result found.")
                default:
                    networkError = NetworkErrors.generalError("Error during geocoding.")
                }
                
                self.showAlertForError(networkError)
            }
            // test for placemark and coordinate
            else if let placemark = placemark?.last, let coordinate = placemark.location?.coordinate {
                
                // good placemark and coordinate
                
                // set placemark
                self.placemark = placemark
                
                // user prompt in label to add extra info..linkedIn URL, etc
                self.whereAtLabel.text = "Something Extra ? ..."
                
                // button will now invoke POST
                self.button.setTitle("Post Location", for: .normal)
                
                // test for student already on map. If on map, then use existing mediaURL
                // in textField. Otherwise nil textField and show placeholder
                if let student = StudentsOnTheMap.shared.onTheMap(uniqueKey: StudentsOnTheMap.shared.myUniqueKey) {
                    self.textField.text = student.0.mediaURL
                    self.textField.placeholder = nil
                }
                else {
                    self.textField.text = nil
                    self.textField.placeholder = "Add URL: LinkedIn, Udacity, etc.."
                }
                
                // create a region. Show mapView and animate/zoom into location
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let mapRegion = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.isHidden = false
                self.mapView.setRegion(mapRegion, animated: true)
                
                // restore UI
                self.activateUIState(searching: false)
            }
            // unknown placemark or location coordinate error
            else {
                
                // present a general purpose error alert, restore UI
                self.showAlertForError(NetworkErrors.generalError("Unable to find a valid location."))
                self.activateUIState(searching: false)
            }
        }
    }
    
    // post student location
    func postLocation() {
        
        /*
         !! NOT currently on map. POST method to post location !!
         To post location, need to first create a Student struct (required by ParseAPI POST method).
         This Student will be a stripped down created using uniqueId, first/last name, and URL currently
         in textField.
         
         POST student location proceedure:
         1) get student public user info..need first/last name info
         2) create student..use "easy" init for Student struct..also assign mediaURL, location coord
         3) POST location using ParseAPI
         4) refresh udacions array in StudentsOnTheMap singleton, dismiss VC
         */
        
        // UI state
        activateUIState(searching: true)
        
        // 1) get student public user info..need first/last name info
        UdacityAPI.shared.getPublicUserData(userID: StudentsOnTheMap.shared.myUniqueKey) {
            (params, error) in
            
            // test error
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlertForError(error)
                }
            }
            // test params
            else if let user = params?[UdacityAPI.ResponseKeys.user] as? [String:AnyObject],
                let lastName = user[UdacityAPI.ResponseKeys.lastName] as? String,
                let firstName = user[UdacityAPI.ResponseKeys.firstName] as? String {
                
                // 2) create student..use "easy" init for Student struct..also assign mediaURL and location coord
                var student = Student(uniqueKey: StudentsOnTheMap.shared.myUniqueKey,
                                      firstName: firstName,
                                      lastName: lastName)
                
                student.mediaURL = self.textField.text! // mediaURL is currently in textField
                student.longitude = (self.placemark?.location?.coordinate.longitude)!
                student.latitude = (self.placemark?.location?.coordinate.latitude)!
                
                // 3) POST using ParseAPI
                ParseAPI.shared.postStudentLocation(student) {
                    (params, error) in
                    
                    // test error
                    if let error = error {
                        DispatchQueue.main.async {
                            self.showAlertForError(error)
                        }
                    }
                    // test params for createdAt and objectId
                    else if let _ = params?[ParseAPI.ResponseKeys.createdAt] as? String,
                        let _ = params?[ParseAPI.ResponseKeys.objectId] as? String {
                        
                        // good params
                        
                        // 4) refresh udacions
                        ParseAPI.shared.studentLocations() {
                            (params, error) in

                            // test error
                            if let error = error {
                                DispatchQueue.main.async {
                                    self.showAlertForError(error)
                                }
                            }
                            // test params
                            else if let students = params?[ParseAPI.ResponseKeys.results] as? [[String:AnyObject]] {
                                
                                // good parse..update udacions with new cohort...now includes this student
                                StudentsOnTheMap.shared.newCohort(students)
                                
                                // dismiss
                                DispatchQueue.main.async {
                                    self.dismiss(animated: true, completion: nil)
                                }
                            }
                        }
                    }
                    // unknown post failure
                    else {
                        
                        // show alert and update UI state
                        DispatchQueue.main.async {
                            self.showAlertForError(NetworkErrors.generalError("Unable to post student location."))
                            self.activateUIState(searching: false)
                        }
                    }
                }
            }
            // unknow failure retrieving student public info
            else {
                
                // show alert and update UI state
                DispatchQueue.main.async {
                    self.showAlertForError(NetworkErrors.generalError("Unable to retrieve student public info."))
                    self.activateUIState(searching: false)
                }
            }
        }
    }
    
    // update location
    func updateLocationForStudent(_ student: Student) {
        
        /*
         !! currently on map. PUT method to update location !!
         
         PUT student location update proceedure:
         1) update student location coord and mediaURL
         2) PUT function using ParseAPI to update location
         3) refresh udacions array in StudentsOnTheMap singleton, dismiss VC
         */
        
        // UI state
        activateUIState(searching: true)
        
        // 1) update student location coord and mediaURL
        var student = student // need var
        student.mediaURL = textField.text! // mediaURL is currently in textField
        student.longitude = (placemark?.location?.coordinate.longitude)!
        student.latitude = (placemark?.location?.coordinate.latitude)!
        
        // 2) PUT function using ParseAPI to update location
        ParseAPI.shared.putStudentLocation(student) {
            (params, error) in
            
            // test error, show alert if error
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlertForError(error)
                }
            }
            // test params
            else if let _ = params?[Student.Keys.updatedAt] {
                
                // 3) refresh udacions, dismiss VC
                ParseAPI.shared.studentLocations() {
                    (params, error) in
                    
                    // test error
                    if let error = error {
                        DispatchQueue.main.async {
                            self.showAlertForError(error)
                        }
                    }
                    // test params
                    else if let students = params?[ParseAPI.ResponseKeys.results] as? [[String:AnyObject]] {
                        
                        // update udacions with updated cohort
                        StudentsOnTheMap.shared.newCohort(students)
                        
                        // dismiss
                        DispatchQueue.main.async {
                            self.dismiss(animated: true, completion: nil)
                        }
                    }
                    // unknown error retieving student locations
                    else {
                        
                        // show alert and update UI state
                        DispatchQueue.main.async {
                            self.showAlertForError(NetworkErrors.generalError("Unable to update student locations"))
                            self.activateUIState(searching: false)
                        }
                    }
                }
            }
            // unknown problem with returned data
            else {
                
                // show alert and update UI state
                DispatchQueue.main.async {
                    self.showAlertForError(NetworkErrors.generalError("Unable to update student location"))
                    self.activateUIState(searching: false)
                }
            }
        }
    }
}

// Alert/Error handling functions
extension PostLocationViewController {
    
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
}

// helper functions
extension PostLocationViewController {
    
    // UI state. Used to set UI elements when searching not active searching
    func activateUIState(searching: Bool) {
        
        activityIndicator.isHidden = !searching
        button.isEnabled = (!searching) && !((textField.text?.isEmpty)!)
        activityIndicator.isHidden = !searching
        
        if searching {
            activityIndicator.startAnimating()
            stackView.alpha = 0.3
        }
        else {
            activityIndicator.stopAnimating()
            stackView.alpha = 1.0
        }
    }
}

// textField delegate functions
extension PostLocationViewController: UITextFieldDelegate {
    
    // disable cancelBbi when editing textField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        cancelBbi.isEnabled = false
    }
    
    // done editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        // hide keyboard, update UI state
        textField.resignFirstResponder()
        cancelBbi.isEnabled = true
        button.isEnabled = !(textField.text?.isEmpty)!
        
        return true
    }
}
