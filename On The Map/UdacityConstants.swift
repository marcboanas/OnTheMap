//
//  UdacityConstants.swift
//  On The Map
//
//  Created by Marc Boanas on 31/03/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation

extension UdacityClient {
    struct Constants {
        static let ApiScheme: String = "https"
        static let ApiHost: String = "www.udacity.com"
        static let ApiPath: String = "/api"
    }
    
    struct ParameterKeys {
        // Authentication Methods
        static let Udacity: String = "udacity"
        static let Facebook: String = "facebook_mobile"
        // Udacity User Credentials
        static let Username: String = "username"
        static let Password: String = "password"
        // Udacity Facebook Login Token
        static let AccessToken: String = "access_token"
    }
    
    struct Methods {
        static let Session: String = "/session"
        static let UserData: String = "/users/{id}"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
    }
    
    struct JSONResponseKeys {
        // Session
        static let Account: String = "account"
        static let Registered: String = "registered"
        static let Key: String = "key"
        static let Session: String = "session"
        static let SessionID: String = "id"
        static let SessionExpiration: String = "expiration"
        // User Data
        static let User: String = "user"
        static let FirstName: String = "first_name"
        static let LastName: String = "last_name"
    }
}
