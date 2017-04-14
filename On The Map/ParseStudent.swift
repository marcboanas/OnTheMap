//
//  ParseStudent.swift
//  On The Map
//
//  Created by Marc Boanas on 31/03/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation

struct Student {
    
    // MARK: Properties
    
    var objectID: String?
    var uniqueKey: String?
    var firstName: String?
    var lastName: String?
    var mapString: String?
    var mediaURL: String?
    var latitude: Double?
    var longitude: Double?
    var updatedAt: String?
    
    // MARK: Initializers
    
    // Construct a Student from a dictionary
    init(dictionary: [String: AnyObject]) {
        objectID = dictionary[ParseClient.JSONResponseKeys.ObjectID] as? String
        uniqueKey = dictionary[ParseClient.JSONResponseKeys.UniqueKey] as? String
        firstName = dictionary[ParseClient.JSONResponseKeys.FirstName] as? String
        lastName = dictionary[ParseClient.JSONResponseKeys.LastName] as? String
        mapString = dictionary[ParseClient.JSONResponseKeys.MapString] as? String
        mediaURL = dictionary[ParseClient.JSONResponseKeys.MediaURL] as? String
        latitude = dictionary[ParseClient.JSONResponseKeys.Latitude] as? Double
        longitude = dictionary[ParseClient.JSONResponseKeys.Longitude] as? Double
        updatedAt = dictionary[ParseClient.JSONResponseKeys.UpdateAt] as? String
    }
    
    static func studentsFromResults(_ results: [[String: AnyObject]]) -> [Student] {
        
        var students = [Student]()
        
        // Iterate through an array of dictionaries -> each Student is a dictionary
        for result in results {
            students.append(Student(dictionary: result))
        }
        
        // Sort students - newest to oldest
        students.sort { $0.updatedAt! > $1.updatedAt! }
        
        return students
    }
}
