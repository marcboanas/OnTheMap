//
//  ParseConstants.swift
//  On The Map
//
//  Created by Marc Boanas on 31/03/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation

extension ParseClient {
    struct Constants {
        static let ApiScheme: String = "https"
        static let ApiHost: String = "parse.udacity.com"
        static let ApiPath: String = "/parse/classes"
    }
    
    struct ParameterKeys {
        static let ParseApplicationID:String = "X-Parse-Application-Id"
        static let ParseRESTAPIKey:String = "X-Parse-REST-API-Key"
        static let StudentLimit:String = "limit"
    }
    
    struct ParameterValues {
        static let ParseApplicationID:String = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let ParseRESTAPIKey:String = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
    }
    
    // Set static limit of 100 students
    struct Methods {
        static let StudentLocation: String = "/StudentLocation"
    }
    
    struct JSONResponseKeys {
        static let ObjectID: String = "objectId"
        static let UniqueKey: String = "uniqueKey"
        static let FirstName: String = "firstName"
        static let LastName: String = "lastName"
        static let MapString: String = "mapString"
        static let MediaURL: String = "mediaURL"
        static let Latitude: String = "latitude"
        static let Longitude: String = "longitude"
        static let Results: String = "results"
        static let UpdateAt: String = "updatedAt"
    }
}
