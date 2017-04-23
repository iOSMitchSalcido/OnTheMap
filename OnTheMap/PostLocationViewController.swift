//
//  PostLocationViewController.swift
//  OnTheMap
//
//  Created by Online Training on 4/22/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

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
        
        cancelBbi.isEnabled = false
        mapView.isHidden = true
        button.isEnabled = false
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
        stackView.alpha = 0.3
        
        guard  let userID = UdacityAPI.shared.myUniqueKey else {
            return
        }
        
        UdacityAPI.shared.getPublicUserData(userID: userID) {
            (params, error) in
            
            DispatchQueue.main.async {
                self.cancelBbi.isEnabled = true
                self.activityIndicator.isHidden = true
                self.activityIndicator.stopAnimating()
                self.stackView.alpha = 1.0
            }
        }
    }
    
    @IBAction func cancelBbiPressed(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func buttonPressed(_ sender: Any) {
        
        if !locationFound {
            
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
                
                if let placemark = placemark?.last {
                    
                    let coord = placemark.location?.coordinate
                    let span = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
                    let mapRegion = MKCoordinateRegion(center: coord!, span: span)
                    
                    DispatchQueue.main.async {
                        
                        self.mapView.isHidden = false
                        self.mapView.setRegion(mapRegion, animated: true)
                    }
                }
                
                DispatchQueue.main.async {
                    
                    self.cancelBbi.isEnabled = true
                    self.button.isEnabled = true
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.stackView.alpha = 1.0
                }
            }
        }
    }
}

extension PostLocationViewController {
    
    func getUserData() {
        
        
    }
}

extension PostLocationViewController: MKMapViewDelegate {
    
}

extension PostLocationViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        button.isEnabled = !(textField.text?.isEmpty)!
        return true
    }
}
