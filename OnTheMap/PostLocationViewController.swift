//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/22/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About PostLocationViewController.swift:
 */

import UIKit
import MapKit

class PostLocationViewController: UIViewController {

    @IBOutlet weak var cancelBbi: UIBarButtonItem!
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var whereAtLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var button: UIButton!
    
    var userData:[String:AnyObject]?
    
    var locationFound = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.isHidden = true
        button.isEnabled = false
        activityIndicator.isHidden = true
    }
    
    @IBAction func cancelBbiPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        if !locationFound {
            locateOnMap()
        }
        else {
            postLocation()
        }
    }
}

extension PostLocationViewController {
    
    func locateOnMap() {
        
        cancelBbi.isEnabled = false
        button.isEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        stackView.alpha = 0.3
        
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(textField.text!) {
            (placemark, error) in
            
            if error != nil {
                print("error geocoding")
            }
            
            if let placemark = placemark?.last, let coordinate = placemark.location?.coordinate {
                
                //let coord = placemark.location?.coordinate
                let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                let mapRegion = MKCoordinateRegion(center: coordinate, span: span)
                
                // found a valid location
                self.locationFound = true
                
                // update mapView
                DispatchQueue.main.async {
                    self.mapView.isHidden = false
                    self.mapView.setRegion(mapRegion, animated: true)
                    self.button.setTitle("Post Location", for: .normal)
                    self.whereAtLabel.text = "Something Extra..?"
                    self.textField.text = nil
                    self.textField.placeholder = "Add URL"
                }
            }
            
            // restore UI
            DispatchQueue.main.async {
                self.cancelBbi.isEnabled = true
                self.button.isEnabled = true
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.stackView.alpha = 1.0
            }
        }
    }
    
    func postLocation() {
        
    }
}
extension PostLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        button.isEnabled = !(textField.text?.isEmpty)!
        return true
    }
}
