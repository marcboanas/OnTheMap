//
//  Helper.swift
//  On The Map
//
//  Created by Marc Boanas on 02/04/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(errorMessage: String?, errorTitle: String? = "Error Message") {
        let alert = UIAlertController(title: errorTitle, message: errorMessage, preferredStyle: .alert)
        let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(defaultAction)
        present(alert, animated: true, completion: nil)
    }
    
    func removeActivityIndicator(uiView: UIView) {
        if let container = uiView.viewWithTag(99) {
            container.removeFromSuperview()
        }
    }
    
    func showActivityIndicator(uiView: UIView) {
        
        // Container to fill entire screen
        let container: UIView = UIView()
        container.backgroundColor = UIColor.white
        container.alpha = 0.5
        container.translatesAutoresizingMaskIntoConstraints = false
        container.tag = 99
        
        // Add Container to view
        uiView.addSubview(container)
        
        let margins = uiView.layoutMarginsGuide
        
        // Constraints: Container View
        container.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0).isActive = true
        container.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0).isActive = true
        container.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: -20).isActive = true
        container.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 20).isActive = true
        
        
        // Loading view for activity indicator
        let loadingView: UIView = UIView()
        loadingView.backgroundColor = UIColor.gray
        loadingView.alpha = 0.9
        loadingView.clipsToBounds = true
        loadingView.layer.cornerRadius = 10
        loadingView.translatesAutoresizingMaskIntoConstraints = false
        
        // Add Loading View to Container
        container.addSubview(loadingView)
        
        // Constraints: Loading View
        loadingView.centerXAnchor.constraint(equalTo: uiView.centerXAnchor).isActive = true
        loadingView.centerYAnchor.constraint(equalTo: uiView.centerYAnchor).isActive = true
        loadingView.heightAnchor.constraint(equalToConstant: 80.0).isActive = true
        loadingView.widthAnchor.constraint(equalToConstant: 80.0).isActive = true
        
        // Activity Indicator
        let activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.whiteLarge
        
        // Add Activity Indicator to Loading View
        loadingView.addSubview(activityIndicator)
        
        // Constraints: Activity Indicator
        activityIndicator.centerYAnchor.constraint(equalTo: uiView.centerYAnchor).isActive = true
        activityIndicator.centerXAnchor.constraint(equalTo: uiView.centerXAnchor).isActive = true
        activityIndicator.heightAnchor.constraint(equalToConstant: 40).isActive = true
        activityIndicator.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
        activityIndicator.startAnimating()
        
        // Bring Activity View to front
        uiView.bringSubview(toFront: container)
    }
    
    // MARK: Hide Keyboard Methods
    
    func hideKeyboardOnTap() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
}
