//
//  ListViewController.swift
//  On The Map
//
//  Created by Marc Boanas on 02/04/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class ListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var refreshButton: UIBarButtonItem!
    
    // MARK: Properties
    
    var students: [Student] = [Student]()
    let reuseID = "StudentCell"

    override func viewDidLoad() {
        super.viewDidLoad()
        loadDatanadReloadTable()
    }
    
    // Obtain student data from parse then update table
    func loadDatanadReloadTable() {
        
        setUIEnabled(enabled: false)
        
        // GUARD: Is an internet connection available?
        guard Reachability.isConnectedToNetwork() == true else {
            showAlert(errorMessage: "There is no internet connection! Please check your internet connection and try again.", errorTitle: "No Internet Connection")
            setUIEnabled(enabled: true)
            return
        }
        
        ParseClient.sharedInstance().getStudentsFromParse { (students, errorString) in
            
            // GUARD: was there an error?
            guard errorString != nil else {
                DispatchQueue.main.async {
                    self.showAlert(errorMessage: "\(errorString!)")
                    self.setUIEnabled(enabled: true)
                }
                return
            }

            print("successfully obtained students from Parse (List)")
            self.students = students!
            print(students!.count)
            
            // Update the UI on the main queue
            DispatchQueue.main.async {
                self.tableView.reloadData()
                self.setUIEnabled(enabled: true)
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

    // MARK: UITableViewDelegate & Datasource Methods
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return students.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseID, for: indexPath) as UITableViewCell
        let student = students[indexPath.row]
        
        if let firstName = student.firstName, let lastName = student.lastName {
            let fullName = "\(firstName) \(lastName)"
            cell.textLabel?.text = fullName
        }
        
        cell.imageView?.image = UIImage(named: "icon_pin")
        
        // GUARD: Check mediaURL is not nil and can be a valid URL
        
        let app = UIApplication.shared
        
        if let toOpen = student.mediaURL {
            if let url = URL(string: toOpen), app.canOpenURL(url) {
                    cell.detailTextLabel?.text = toOpen
                    cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
            } else {
                cell.accessoryType = UITableViewCellAccessoryType.none
                cell.detailTextLabel?.text = ""
            }
        } else {
            cell.accessoryType = UITableViewCellAccessoryType.none
            cell.detailTextLabel?.text = ""
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let app = UIApplication.shared
        if let toOpen = students[indexPath.row].mediaURL {
            if let url = URL(string: toOpen) {
                app.open(url, options: [:], completionHandler: nil)
            }
        }
    }
    
    // MARK: IBActions
    
    @IBAction func refreshButtonPressed(_ sender: Any) {
        loadDatanadReloadTable()
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
