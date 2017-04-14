//
//  AddPinViewController.swift
//  On The Map
//
//  Created by Marc Boanas on 11/04/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class AddPinViewController: UIViewController, MKMapViewDelegate, UITextFieldDelegate {
    
    // Properties
    
    var student = Student(dictionary: [:])
    var address: String!
    
    // MARK: IBOutlets
    
    @IBOutlet weak var formView: UIView!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var mediaURLTextField: UITextField!
    @IBOutlet weak var previewOnMapButton: UIButton!
    @IBOutlet weak var editBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var mapViewContainer: UIView!
    @IBOutlet weak var mapView: MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        locationTextField.delegate = self
        mediaURLTextField.delegate = self
        
        hideKeyboardOnTap()
        
        student.firstName = UdacityClient.sharedInstance().firstName
        student.lastName = UdacityClient.sharedInstance().lastName
        student.uniqueKey = UdacityClient.sharedInstance().userID
    }
    
    func uiSetupFor(preview: Bool) {
        mapViewContainer.isHidden = !preview
        editBarButtonItem.isEnabled = preview
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: IBActions
    
    @IBAction func editBarButtonItemPressed(_ sender: Any) {
        mapView.removeAnnotation(mapView.annotations[0])
        uiSetupFor(preview: false)
    }
    
    @IBAction func cancelBarButtonItemPressed(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
   
    @IBAction func previewOnMap(_ sender: Any) {
        
        showActivityIndicator(uiView: formView)
        
        // GUARD: Check location is not empty?
        guard !(locationTextField.text?.isEmpty)! && !(mediaURLTextField.text?.isEmpty)!  else {
            showAlert(errorMessage: "Please provide a location and url!")
            removeActivityIndicator(uiView: formView)
            return
        }
        
        // Init geocoder
        let geocoder = CLGeocoder()
        
        // Address string
        address = locationTextField.text
        
        // GUARD: Is an internet connection available?
        guard Reachability.isConnectedToNetwork() == true else {
            showAlert(errorMessage: "There is no internet connection! Please check your internet connection and try again.", errorTitle: "No Internet Connection")
            removeActivityIndicator(uiView: formView)
            return
        }
        
        // Geocode address string
        geocoder.geocodeAddressString(address) { (placemarks, error) in
            
            // GUARD: Check for errors?
            guard error == nil else {
                self.showAlert(errorMessage: "Unable to geocode: \(self.address!)")
                self.removeActivityIndicator(uiView: self.formView)
                return
            }
            
            if let placemark = placemarks?[0] {
                
                let lat = CLLocationDegrees((placemark.location?.coordinate.latitude)!)
                let long = CLLocationDegrees((placemark.location?.coordinate.longitude)!)
                
                // Set student location info
                self.student.latitude = lat
                self.student.longitude = long
                self.student.mapString = self.address
                
                // Create coordinates
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                
                // Create annotation
                let annotation = MKPointAnnotation()
                
                // Set annotation coordinates
                annotation.coordinate = coordinate
                
                // Set annotation title
                if let firstName = self.student.firstName, let lastName = self.student.lastName {
                    annotation.title = "\(firstName) \(lastName)"
                }
                
                if let mediaURL = self.mediaURLTextField.text {
                    // Set annotation subtitle
                    annotation.subtitle = mediaURL
                    self.student.mediaURL = mediaURL
                }
                
                // Set mapView region and span (zoom-in on pin)
                let span = MKCoordinateSpan(latitudeDelta: 0.075, longitudeDelta: 0.075)
                let region = MKCoordinateRegion(center: coordinate, span: span)
                self.mapView.setRegion(region, animated: true)
                
                // Add annotation
                self.mapView.addAnnotation(annotation)
                
                // Select annotation (display pin title and subtitle)
                self.mapView.selectAnnotation(self.mapView.annotations[0], animated: true)
                
                self.uiSetupFor(preview: true)
                self.removeActivityIndicator(uiView: self.formView)
            }
        }
    }
    
    @IBAction func addStudentLocationToParse(_ sender: Any) {
        
        showActivityIndicator(uiView: mapViewContainer)
        
        ParseClient.sharedInstance().postStudentLocationToParse(student) { (results, error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.showAlert(errorMessage: "Something went wrong: \(String(describing: error))")
                    self.removeActivityIndicator(uiView: self.mapViewContainer)
                }
            } else {
                DispatchQueue.main.async {
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    
}
