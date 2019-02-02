//
//  Networking.swift
//  OnTheMap
//
//  Created by Online Training on 4/17/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About Networking.swift:
 Provide functionality for URLSessionDataTask. Includes URL creation and Error enum. Also includes constants for use
 by API classes for param creation.
*/

import Foundation

// errors enum
enum NetworkErrors: Swift.Error {
    case networkError(String)   // problems in URLSessionDataTask, networking errors
    case operatorError(String)  // issues such as typos, bad username/password, etc
    case generalError(String)   // misc/unknown error, etc
}

struct Networking {
    
    // data task
    func taskWithParams(_ params:[String:AnyObject], completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {
        
        /*
         Function to peform a URL Session data task.
         This functions takes in a dictionary of params (created in API structs that call this func), and a completion
         closure.
         
         From the params, a URL is created, from which a URL Request is created. params also contain additional
         configration data to complete configuration of the URLRequest (method, httpHeaderFields, body).
         
         Lastly, a dataTask is created and invoked using the URL request. Error checking is performed in the task
         completion.
         */
        
        // retrieve url
        guard let url = urlForParams(params) else {
            
            // unable to create URL. Invoke completion with error.
            completion(nil, NetworkErrors.operatorError("Unable to create valid URL."))
            return
        }
        
        // create/build request
        var request = URLRequest(url: url)
        
        // HTTP Method. Retrieve from params.
        if let method = params[Networking.ParamKeys.httpMethod] as? String {
            request.httpMethod = method
        }
        
        // HTTP Header Field(s). Retrieve from params.
        if let httpHeaderField = params[Networking.ParamKeys.httpHeaderField] as? [String:AnyObject] {
            for (key, value) in httpHeaderField {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        // HTTPBody. Retrieve from params
        if let body = params[Networking.ParamKeys.httpBody] {
            do {
                let postData = try JSONSerialization.data(withJSONObject: body)
                request.httpBody = postData
            }
            catch {
                completion(nil, NetworkErrors.operatorError("Unable to create valid URL."))
                return
            }
        }
        
        // create data task with request
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            // test error
            guard error == nil else {
                // Error during task. Fire completion with error
                completion(nil, NetworkErrors.networkError("Error in data task."))
                return
            }
            
            // test response, statusCode
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                switch statusCode {
                case 200...299:
                    // good status code
                    break
                case 403:
                    // bad creds
                    completion(nil, NetworkErrors.operatorError("Invalid credentials. Check username/password"))
                    return
                default:
                    // bad status code
                    completion(nil, NetworkErrors.networkError("Bad status code returned. non-2xx"))
                    return
                }
            }
            
            // test valid data
            guard var data = data else {
                
                // bad data returned. Fire completion with error.
                completion(nil, NetworkErrors.networkError("No data returned from data task."))
                return
            }
            
            /*
             convert to JSON
             Perform in two try's. First try tests for JSON using data. If error thrown, then try again, only remove
             first five characters per Udacity API spec...might be Udacity data
             */
            
            // JSON object
            let json:[String:AnyObject]!
            do {
                // first pass test
                json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
            }
            catch {
                // failed first pass
                do {
                    // try again, but remove first five characters per Udacity API spec
                    let range = Range(5..<data.count)
                    data = data.subdata(in: range)
                    json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String:AnyObject]
                }
                catch {
                    
                    // bad JSON conversion. Fire completion with error
                    completion(nil, NetworkErrors.networkError("Unable to convert data."))
                    return
                }
            }
            
            // good JSON. Fire completion using JSON object
            completion(json, nil)
        }
        
        task .resume()
    }
    
    // create/return URL from params
    fileprivate func urlForParams(_ params:[String:AnyObject]) -> URL? {
        
        // make a copy..will be pulling items out
        var params = params
        
        /*
         params contains data not implemented in URL creation. Items not implemented are removed from dictionary.
         The remaining params contain info used for URL creation: path extension and api components
        */
        
        // remove extensions, httpBody, and apiComponents
        let extensions = params.removeValue(forKey: Networking.ParamKeys.pathExtension) as? String
        let _ = params.removeValue(forKey: Networking.ParamKeys.httpBody) // not needed for URL creation
        let _ = params.removeValue(forKey: Networking.ParamKeys.httpHeaderField) // not needed
        let _ = params.removeValue(forKey: Networking.ParamKeys.httpMethod) // not needed
        
        // test api components...needed for URL creation
        guard let apiComponents = params.removeValue(forKey: Networking.ParamKeys.components) else {
            return nil
        }

        //.. params now only contains queryItems
        
        // create components
        var components = URLComponents()
        components.host = (apiComponents[Networking.ParamKeys.host] as! String)
        components.scheme = (apiComponents[Networking.ParamKeys.scheme] as! String)
        components.path = (apiComponents[Networking.ParamKeys.path] as! String) + (extensions ?? "")
        
        // add query items
        components.queryItems = [URLQueryItem]()
        for (key, value) in params {
            let item = URLQueryItem(name: key, value: "\(value)")
            components.queryItems?.append(item)
        }
        
        return components.url
    }
}

extension Networking {
    
    // Constants keys for sifting out dictionaries in params passed into taskWithParams
    struct ParamKeys {
        static let pathExtension = "pathExtension"
        static let httpBody = "httpBody"
        static let components = "components"
        static let host = "host"
        static let scheme = "scheme"
        static let path = "path"
        static let httpHeaderField = "httpHeaderField"
        static let httpMethod = "httpMethod"
    }
    
    // Constants values
    struct ParamValues {
        static let unsecureScheme = "http"  // unsecure scheme
        static let secureScheme = "https"   // secure scheme
    }
}
