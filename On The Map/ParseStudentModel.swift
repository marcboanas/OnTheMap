//
//  ParseStudentModel.swift
//  On The Map
//
//  Created by Marc Boanas on 14/04/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation

class ParseStudentModel {
    
    static var students: [Student] = []
    
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
