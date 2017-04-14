//
//  LoginViewController.swift
//  On The Map
//
//  Created by Marc Boanas on 31/03/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit

class LoginViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: IBOutlets
    
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var udacityLoginButton: UIButton!
    @IBOutlet weak var facebookLoginButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardOnTap()
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        
        // Log in with Udacity API if FB access token available
        if FBSDKAccessToken.current() != nil {
            setUIEnabled(false)
            loginWithFacebookAccessToken(FBSDKAccessToken.current().tokenString)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Clear text from text fields
        usernameTextField.text = ""
        passwordTextField.text = ""
        
        // Transform text in text field
        usernameTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10.0, 0.0, 0.0)
        passwordTextField.layer.sublayerTransform = CATransform3DMakeTranslation(10.0, 0.0, 0.0)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if FBSDKAccessToken.current() == nil {
            setUIEnabled(true)
        }
    }
    
    // MARK: IBActions
    
    // Udacity Login
    @IBAction func udacityLoginButtonPressed(_ sender: Any) {
        
        setUIEnabled(false)
        
        // GUARD: Is the username or password field empty?
        guard !usernameTextField.text!.isEmpty && !passwordTextField.text!.isEmpty else {
            showAlert(errorMessage: "You must enter a username AND password!")
            setUIEnabled(true)
            return
        }
        
        // GUARD: Is an internet connection available?
        guard Reachability.isConnectedToNetwork() == true else {
            showAlert(errorMessage: "There is no internet connection! Please check your internet connection and try again.", errorTitle: "No Internet Connection")
            setUIEnabled(true)
            return
        }
        
        // Create a dictionary of user login credentials
        let userLoginCredentials = [
            UdacityClient.ParameterKeys.Username: usernameTextField.text,
            UdacityClient.ParameterKeys.Password: passwordTextField.text
        ]
        
        // Authorize user with Udacity API using login credentials
        UdacityClient.sharedInstance().authenticate(userLoginCredentials: userLoginCredentials as [String : AnyObject], parameterKey: UdacityClient.ParameterKeys.Udacity, completionHandlerForAuth: { (success, errorString) in
            DispatchQueue.main.async {
                if success {
                    self.loggedIn()
                } else {
                    self.setUIEnabled(true)
                    if let error = errorString {
                        self.showAlert(errorMessage: "\(error)")
                    }
                }
            }
        })
    }
    
    // Facebook Login
    @IBAction func facebookLoginPressed(_ sender: Any) {
    
        print("Facebook login button pressed")
        setUIEnabled(false)
        
        // GUARD: Is an internet connection available?
        guard Reachability.isConnectedToNetwork() == true else {
            showAlert(errorMessage: "There is no internet connection! Please check your internet connection and try again.", errorTitle: "No Internet Connection")
            setUIEnabled(true)
            return
        }
        
        // Create Facebook Login Manager
        let fbLoginManager: FBSDKLoginManager = FBSDKLoginManager()
        fbLoginManager.logIn(withReadPermissions: ["email"], from: self) { (result, error) in
            
            DispatchQueue.main.async {
                self.setUIEnabled(false)
            }
            
            // GUARD: Check for errors.
            guard error == nil else {
                print(error!)
                DispatchQueue.main.async {
                    self.setUIEnabled(true)
                    self.showAlert(errorMessage: error!.localizedDescription)
                }
                return
            }
            
            // GUARD: Check if facebook login was cancelled?
            guard !((result?.isCancelled)!) else {
                DispatchQueue.main.async {
                    self.setUIEnabled(true)
                    self.showAlert(errorMessage: "Facebook login was cancelled!")
                }
                return
            }
            
            // GUARD: Check facebook granted permission?
            guard (result?.grantedPermissions.contains("email"))! else {
                DispatchQueue.main.async {
                    self.setUIEnabled(true)
                    self.showAlert(errorMessage: "Facebook did not grant permission!")
                }
                return
            }
            
            self.loginWithFacebookAccessToken((result?.token.tokenString)!)
        }
    }
    
    // Login to Udacity with FB Access Token
    private func loginWithFacebookAccessToken(_ accessToken: String) {
        
        // GUARD: Is an internet connection available?
        guard Reachability.isConnectedToNetwork() == true else {
            showAlert(errorMessage: "There is no internet connection! Please check your internet connection and try again.", errorTitle: "No Internet Connection")
            setUIEnabled(true)
            return
        }
        
        // Create a dictionary of login credentials
        let loginCredentials = [
            UdacityClient.ParameterKeys.AccessToken: accessToken
        ]
        
        // Authorize user with Udacity API and Facebook Token
        UdacityClient.sharedInstance().authenticate(userLoginCredentials: loginCredentials as [String: AnyObject], parameterKey: UdacityClient.ParameterKeys.Facebook, completionHandlerForAuth: { (success, errorString) in
            DispatchQueue.main.async {
                if success {
                    self.loggedIn()
                } else {
                    self.setUIEnabled(true)
                    if let error = errorString {
                        self.showAlert(errorMessage: "\(error)")
                    }
                }
            }
        })
    }
    
    // Udacity Signup
    @IBAction func udacitySignup(_ sender: Any) {
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        UIApplication.shared.open(components.url!, options: [:], completionHandler: nil)
    }
    
    // Complete login - move to new view controller
    private func loggedIn() {
        print("User is logged In!")
        let nextController = storyboard!.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        present(nextController, animated: true, completion: nil)
    }
    
    // MARK: UITextField Delegate Methods
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
}

// MARK: LoginViewController - Configure UI

private extension LoginViewController {
    
    // Disable/Enable UI Elements
    func setUIEnabled(_ enabled: Bool) {
        
        udacityLoginButton.isEnabled = enabled
        facebookLoginButton.isEnabled = enabled
        usernameTextField.isEnabled = enabled
        passwordTextField.isEnabled = enabled
        
        if enabled {
            removeActivityIndicator(uiView: self.view)
        } else {
            showActivityIndicator(uiView: self.view)
        }
    }
}
