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
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func updateMap() {
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
                }
                print(errorMessage)
            }
            
            // test params
            if let params = params, let students = params["results"] as? [[String:AnyObject]] {
                StudentsOnTheMap.shared.newCohort(students)
            }
        }
    }
    
    @IBAction func logoutBbiPressed(_ sender: Any) {
        UdacityAPI.shared.deleteSession()
        dismiss(animated: true, completion: nil)
    }
    @IBAction func dropPinBbiPressed(_ sender: Any) {
        
    }
    @IBAction func refreshBbiPressed(_ sender: Any) {
        updateMap()
    }
}
