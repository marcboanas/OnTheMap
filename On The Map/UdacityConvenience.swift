//
//  UdacityConvenience.swift
//  On The Map
//
//  Created by Marc Boanas on 31/03/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation
import FBSDKLoginKit

extension UdacityClient {
    
    // Authenticate User
    
    func authenticate(userLoginCredentials: [String: AnyObject], parameterKey: String!, completionHandlerForAuth: @escaping (_ success: Bool, _ errrorString: String?) -> Void) {
        
        self.getSession(userLoginCredentials: userLoginCredentials, parameterKey: parameterKey) { (success, sessionID, accountKey, error) in
            if success {
                self.sessionID = sessionID!
                self.userID = accountKey!
                self.getUserData({ (firstName, lastName, error) in
                    if error == nil {
                        self.firstName = firstName?.capitalized
                        self.lastName = lastName?.capitalized
                        completionHandlerForAuth(true, nil)
                    } else {
                        completionHandlerForAuth(false, "\(String(describing: (error?.localizedDescription)!))")
                    }
                })
            } else {
                completionHandlerForAuth(false, "\(String(describing: (error?.localizedDescription)!))")
            }
        }
    }
    
    // Logout User
    
    func logout() {
        let loginManager = FBSDKLoginManager()
        loginManager.logOut()
        UdacityClient.sharedInstance().sessionID = nil
        UdacityClient.sharedInstance().userID = nil
        UdacityClient.sharedInstance().firstName = nil
        UdacityClient.sharedInstance().lastName = nil
    }
    
    // Get session (actually uses a post request)
    
    func getSession(userLoginCredentials: [String: AnyObject], parameterKey: String!, completionHandlerForGetSession: @escaping (_ success: Bool, _ sessionID: String?, _ accountKey: String?, _ error: NSError?) -> Void) {
        
        let jsonBody = [parameterKey: userLoginCredentials]
        
        let _ = taskForPOSTMethod(Methods.Session, parameters: [:], jsonBody: jsonBody as [String : AnyObject]) { (JSONresult, error) in
            
            // GUARD: Was there an error?
            guard error == nil else {
                completionHandlerForGetSession(false, nil, nil, error)
                return
            }
            
            // GUARD: Are the keys 'session' && 'account' in JSONResult
            guard let session = JSONresult?[JSONResponseKeys.Session], let account = JSONresult?[JSONResponseKeys.Account] else {
                let userInfo = [NSLocalizedDescriptionKey: "Could not find key 'session' and/or 'account' in: \(String(describing: JSONresult))"]
                completionHandlerForGetSession(false, nil, nil, NSError(domain: "completionHandlerForGetSession", code: 1, userInfo: userInfo))
                return
            }
            
            // GUARD: Are the keys 'id' and 'key' in JSONResult?
            guard let sessionID = (session as AnyObject)[JSONResponseKeys.SessionID], let accountKey = (account as AnyObject)[JSONResponseKeys.Key]  else {
                let userInfo = [NSLocalizedDescriptionKey: "Could not find 'id' key in: \(String(describing: session))"]
                completionHandlerForGetSession(false, nil, nil, NSError(domain: "completionHandlerForGetSession", code: 1, userInfo: userInfo))
                return
            }
            
            completionHandlerForGetSession(true, (sessionID as! String), (accountKey as! String), nil)
        }
    }
    
    // Get user data from Udacity API (first name and last name)
    
    func getUserData(_ completionHandlerForGetUserData: @escaping (_ firstName: String?, _ lastName: String?, _ error: NSError?) -> Void) {
        
        // No parameters
        let parameters: [String: AnyObject] = [:]
        
        var mutableMethod: String = Methods.UserData
        mutableMethod = substitueKeyInMethod(mutableMethod, key: URLKeys.UserID, value: UdacityClient.sharedInstance().userID!)!
        
        // 1. Make the request
        let _ = taskForGETMethod(mutableMethod, parameters: parameters) { (results, error) in
            
            // GUARD: Check for errors?
            guard error == nil else {
                completionHandlerForGetUserData(nil, nil, error!)
                return
            }
            
            // GUARD: Is the key 'user' in the JSON results?
            guard let results = results?[JSONResponseKeys.User] else {
                completionHandlerForGetUserData(nil, nil, NSError(domain: "getUserData parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getDataUser"]))
                return
            }
            
            let firstName = (results as AnyObject)[JSONResponseKeys.FirstName] as! String?
            let lastName = (results as AnyObject)[JSONResponseKeys.LastName] as! String?
            completionHandlerForGetUserData(firstName, lastName, nil)
        }
    }
}
