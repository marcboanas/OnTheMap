//
//  MapViewController.swift
//  On The Map
//
//  Created by Marc Boanas on 01/04/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit
import MapKit
import FBSDKLoginKit

class MapViewController: UIViewController, MKMapViewDelegate {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: Properties
    
    var annotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadDataAndDisplayOnMap()
    }
    
    func loadDataAndDisplayOnMap() {
        
        setUIEnabled(enabled: false)
        
        // GUARD: Is an internet connection available?
        guard Reachability.isConnectedToNetwork() == true else {
            showAlert(errorMessage: "There is no internet connection! Please check your internet connection and try again.", errorTitle: "No Internet Connection")
            setUIEnabled(enabled: true)
            return
        }
        
        ParseClient.sharedInstance().getStudentsFromParse(limit: 100) { (students, errorString) in
            
            // GUARD: was there an error?
            guard errorString != nil else {
                DispatchQueue.main.async {
                    self.showAlert(errorMessage: "\(errorString!)")
                    self.setUIEnabled(enabled: true)
                }
                return
            }

            print("Successfully obtained students from Parse (Map)")
            
            // Update the UI on the main queue
            DispatchQueue.main.async {
                self.removeAnnotations()
                self.addAnnotations()
                self.mapView.addAnnotations(self.annotations)
                self.setUIEnabled(enabled: true)
            }
        }
    }
    
    func removeAnnotations() {
        annotations = []
        let currentAnnotations = mapView.annotations
        mapView.removeAnnotations(currentAnnotations)
    }
    
    func addAnnotations() {
        for student in ParseStudentModel.students {
            if let long = student.longitude, let lat = student.latitude, let firstName = student.firstName, let lastName = student.lastName {
                let lat = CLLocationDegrees(lat)
                let long = CLLocationDegrees(long)
                let coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
                let fullName = ("\(firstName) \(lastName)")
                let mediaURL = student.mediaURL
                
                let annotation = MKPointAnnotation()
                annotation.coordinate = coordinate
                annotation.title = fullName
                annotation.subtitle = mediaURL
                
                annotations.append(annotation)
            }
        }
    }
    
    // Disable/Enable UI Elements
    func setUIEnabled(enabled: Bool) {
        refreshButton.isEnabled = enabled
        
        if enabled {
            removeActivityIndicator(uiView: self.view)
        } else {
            showActivityIndicator(uiView: self.view)
        }
    }
    
    // MARK: MKMapViewDelegate
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        let reuseID = "pin"
        
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseID) as? MKPinAnnotationView
        
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseID)
            pinView!.canShowCallout = true
            pinView!.pinTintColor = .red
            pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        } else {
            pinView!.annotation = annotation
        }
        return pinView
    }
    
    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        if control == view.rightCalloutAccessoryView {
            let app = UIApplication.shared
            if let toOpen = view.annotation?.subtitle! {
                if let url = URL(string: toOpen), app.canOpenURL(url) {
                    app.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    // MARK: IBActions
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        removeAnnotations()
        loadDataAndDisplayOnMap()
    }
    
    @IBAction func addPinButtonPressed(_ sender: Any) {
        let nextController = storyboard!.instantiateViewController(withIdentifier: "AddPinViewController")
        present(nextController, animated: true, completion: nil)
    }
    
    @IBAction func logoutButtonPressed(_ sender: Any) {
        UdacityClient.sharedInstance().logout()
        dismiss(animated: true, completion: nil)
    }
    
}
