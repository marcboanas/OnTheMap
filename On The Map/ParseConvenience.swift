//
//  ParseConvenience.swift
//  On The Map
//
//  Created by Marc Boanas on 31/03/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation

extension ParseClient {
    
    // Get an array of Students from Parse
    
    func getStudentsFromParse(limit: Int, completionHandlerForGetStudentsFromParse: @escaping (_ students: [Student]?, _ errorString: String?) -> Void) {
        
        let parameters = [
            ParameterKeys.StudentLimit: 200
        ] as [String: AnyObject]
        
        let _ = taskForGetMethod(Methods.StudentLocation, parameters: parameters) { (JSONResult, error) in
            
            if let error = error {
                completionHandlerForGetStudentsFromParse(nil, "\(error)")
            } else {
                if let results = JSONResult?.value(forKey: ParseClient.JSONResponseKeys.Results) as? [[String: AnyObject]] {
                    let studentsFromResults = ParseStudentModel.studentsFromResults(results)
                    ParseStudentModel.students = studentsFromResults
                    completionHandlerForGetStudentsFromParse(studentsFromResults, "\(String(describing: error))")
                } else {
                    completionHandlerForGetStudentsFromParse(nil, "Could not retrieve results")
                }
            }
        }
    }
    
    // Post student location to Parse
    
    func postStudentLocationToParse(_ student: Student, completitionHandlerForPostStudentToParse: @escaping (_ result: [String: AnyObject]?, _ errorString: String?) -> Void) {
        
        // 1. HTTP body for post request
        let jsonBody = "{\"\(ParseClient.JSONResponseKeys.UniqueKey)\": \"\(student.uniqueKey!)\", \"\(ParseClient.JSONResponseKeys.FirstName)\": \"\(student.firstName!)\", \"\(ParseClient.JSONResponseKeys.LastName)\": \"\(student.lastName!)\",\"\(ParseClient.JSONResponseKeys.MapString)\": \"\(student.mapString!)\", \"\(ParseClient.JSONResponseKeys.MediaURL)\": \"\(student.mediaURL!)\",\"\(ParseClient.JSONResponseKeys.Latitude)\":\(student.latitude!), \"\(ParseClient.JSONResponseKeys.Longitude)\":\(student.longitude!)}"
        
        // 2. Make the request
        let _ = taskForPostMethod(ParseClient.Methods.StudentLocation, parameters: [:], jsonBody: jsonBody) { (results, error) in
            
            if error != nil {
                completitionHandlerForPostStudentToParse(nil, "\(String(describing: error))")
            } else {
                completitionHandlerForPostStudentToParse(results as? [String : AnyObject], nil)
            }
        }
    }
}
