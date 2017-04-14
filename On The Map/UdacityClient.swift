//
//  UdacityClient.swift
//  On The Map
//
//  Created by Marc Boanas on 31/03/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation

class UdacityClient: NSObject {
    
    // MARK: Properties
    
    // Shared session
    var session = URLSession.shared
    
    // User Info
    var sessionID: String?
    var userID: String?
    var firstName: String?
    var lastName: String?
    
    // MARK: Initializers
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    func taskForGETMethod(_ method: String?, parameters: [String: AnyObject], completionHandlerForGETMethod: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // 1. Build the url and configure the request
        let url = udacityURLWithParameters(parameters, withPathExtension: method)
        let request = NSMutableURLRequest(url: url)
        
        // 2. Make the request
        let task = session.dataTask(with: (request as URLRequest)) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGETMethod(nil, NSError(domain: "taskForGetMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard (error == nil) else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // Was there any data returned?
            guard data != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            // 3. Parse the data
            let range = Range(5 ..< data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            self.convertDataWithCompletionHandler(newData!, completioHandlerForConvertData: completionHandlerForGETMethod)
        }
        
        // 4. Start the request
        task.resume()
        
        return task
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(_ method: String?, parameters: [String: AnyObject], jsonBody: [String:AnyObject], completionHandlerForPost: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // 1. Build URL and Configure the Request
        let url = udacityURLWithParameters(parameters, withPathExtension: method)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: jsonBody, options: [])
        
        // 2. Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPost(nil, NSError(domain: "taskForPostMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard error == nil else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            // GUARD: did we get a successful response - 2xx?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            // GUARD: Was there ay data returned?
            guard data != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            // 3. Parse the data
            let range = Range(5 ..< data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            self.convertDataWithCompletionHandler(newData!, completioHandlerForConvertData: completionHandlerForPost)
        }
        
        // 4. Start the request
        task.resume()
        return task
    }
    
    // MARK: Helpers
    
    // Parse the json
    private func convertDataWithCompletionHandler(_ data: Data, completioHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        //let newData = data.subdata(in: Range(uncheckedBounds: (5, upper: data.count - 5)))
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: \(data)"]
            completioHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        completioHandlerForConvertData(parsedResult, nil)
    }
    
    //Substitues the key for the value that is contained within the method name
    func substitueKeyInMethod(_ method: String, key: String, value: String) -> String? {
        if method.range(of: "{\(key)}") != nil {
            return method.replacingOccurrences(of: "{\(key)}", with: value)
        } else {
            return nil
        }
    }
    
    // Create a URL from parameters
    private func udacityURLWithParameters(_ parameters: [String: AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = UdacityClient.Constants.ApiScheme
        components.host = UdacityClient.Constants.ApiHost
        components.path = UdacityClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
}

