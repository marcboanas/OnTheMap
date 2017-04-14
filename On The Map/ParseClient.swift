//
//  ParseClient.swift
//  On The Map
//
//  Created by Marc Boanas on 31/03/2017.
//  Copyright © 2017 Marc Boanas. All rights reserved.
//

import Foundation

class ParseClient: NSObject {
    
    // MARK: Properties
    
    // Shared session
    var session = URLSession.shared
    var students: [Student]? = nil
    
    // MARK: Inializers
    
    override init() {
        super.init()
    }
    
    // MARK: GET
    
    func taskForGetMethod(_ method: String, parameters: [String: AnyObject]?, completionHandlerForGet: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // 1. Build the URL and configure the Request
        let url = parseURLFromParameters(parameters, withPathExtension: method)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "GET"
        request.addValue(ParameterValues.ParseApplicationID, forHTTPHeaderField: ParameterKeys.ParseApplicationID)
        request.addValue(ParameterValues.ParseRESTAPIKey, forHTTPHeaderField: ParameterKeys.ParseRESTAPIKey)
        
        // 2. Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForGet(nil, NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard error == nil else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx! - \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            
            // GUARD: Was there any data returned?
            guard data != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            // 3. Parse the data
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForGet)
        }
        
        // 4. Start the request
        task.resume()
        return task
    }
    
    // MARK: POST
    
    func taskForPostMethod(_ method: String, parameters: [String: AnyObject]?, jsonBody: String, completionHandlerForPost: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask {
        
        // 1. Build the URL and configure the Request
        let url = parseURLFromParameters(parameters, withPathExtension: method)
        let request = NSMutableURLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue(ParameterValues.ParseApplicationID, forHTTPHeaderField: ParameterKeys.ParseApplicationID)
        request.addValue(ParameterValues.ParseRESTAPIKey, forHTTPHeaderField: ParameterKeys.ParseRESTAPIKey)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonBody.data(using: String.Encoding.utf8)
        
        // 2. Make the request
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            
            func sendError(_ error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey: error]
                completionHandlerForPost(nil, NSError(domain: "taskForPOSTMethod", code: 1, userInfo: userInfo))
            }
            
            // GUARD: Was there an error?
            guard error == nil else {
                sendError("There was an error with your request: \(String(describing: error))")
                return
            }
            
            // GUARD: Did we get a successful 2XX response?
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx! - \(String(describing: (response as? HTTPURLResponse)?.statusCode))")
                return
            }
            
            // GUARD: Was there any data returned?
            guard data != nil else {
                sendError("No data was returned by the request!")
                return
            }
            
            // 3. Parse the data
            self.convertDataWithCompletionHandler(data!, completionHandlerForConvertData: completionHandlerForPost)
        }
        
        // 4. Start the request
        task.resume()
        return task
    }
    
    
    // Parse the JSON
    private func convertDataWithCompletionHandler(_ data: Data, completionHandlerForConvertData: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        var parsedResult: AnyObject! = nil
        do {
            parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
        } catch {
            let userInfo = [NSLocalizedDescriptionKey: "Could not parse the data as JSON: '\(data)'"]
            completionHandlerForConvertData(nil, NSError(domain: "convertDataWithCompletionHandler", code: 1, userInfo: userInfo))
        }
        
        completionHandlerForConvertData(parsedResult, nil)
    }
    
    
    // Create URL from parameters
    private func parseURLFromParameters(_ parameters: [String: AnyObject]?, withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = ParseClient.Constants.ApiScheme
        components.host = ParseClient.Constants.ApiHost
        components.path = ParseClient.Constants.ApiPath + (withPathExtension ?? "")
        
        if let parameters = parameters {
            for (key, value) in parameters {
                let queryItem = URLQueryItem(name: key, value: "\(value)")
                components.queryItems!.append(queryItem)
            }
        }
        
        return components.url!
    }
    
    // MARK: Shared Instance
    
    class func sharedInstance() -> ParseClient {
        struct Singleton {
            static var sharedInstance = ParseClient()
        }
        return Singleton.sharedInstance
    }
}
