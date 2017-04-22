//
//  Networking.swift
//  OnTheMap
//
//  Created by Online Training on 4/17/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import Foundation

enum NetworkErrors: Swift.Error {
    case networkError(String)   // problems in URLSessionDataTask
    case operatorError(String)  // issues such as typos, etc
}

class Networking {
    

}

// task functions
extension Networking {
    
    func taskWithParams(_ params:[String:AnyObject], completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {
        
        // retrieve url
        guard let url = urlForParams(params) else {
            completion(nil, NetworkErrors.operatorError("Unable to create valid URL."))
            return
        }
        
        // create/build request
        var request = URLRequest(url: url)
        
        // HTTP MEthod
        if let method = params[Networking.ParamKeys.httpMethod] as? String {
            request.httpMethod = method
        }
        
        // HTTP Header Field(s)
        if let httpHeaderField = params[Networking.ParamKeys.httpHeaderField] as? [String:AnyObject] {
            for (key, value) in httpHeaderField {
                request.addValue(value as! String, forHTTPHeaderField: key)
            }
        }
        
        // HTTPBody
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
        
        // create data task
        let task = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            
            // test error
            guard error == nil else {
                completion(nil, NetworkErrors.networkError("Error in data task."))
                return
            }
            
            // test error
            if let statusCode = (response as? HTTPURLResponse)?.statusCode {
                
                switch statusCode {
                case 200...299:
                    break
                case 403:
                    completion(nil, NetworkErrors.operatorError("Invalid credentials. Check username/password"))
                    return
                default:
                completion(nil, NetworkErrors.networkError("Bad status code returned. non-2xx"))
                    return
                }
            }
            
            // test valid data
            guard var data = data else {
                completion(nil, NetworkErrors.networkError("No data returned from data task."))
                return
            }
            
            /*
             convert to JSON
             Perform in two try's. First try tests for JSON using data. If error thrown, then try again, only remove
             first five characters per Udacity API spec...might be Udacity data
            */
            let json:[String:AnyObject]!
            do {
                // first pass test
                json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            }
            catch {
                // failed first pass
                do {
                    // try again, but remove first five characters per Udacity API spec
                    let range = Range(5..<data.count)
                    data = data.subdata(in: range)
                    json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
                }
                catch {
                    completion(nil, NetworkErrors.networkError("Unable to convert data."))
                    return
                }
            }
            completion(json, nil)
        }
        
        task .resume()
    }
    
    func urlForParams(_ params:[String:AnyObject]) -> URL? {
        
        // make a copy..will be pulling items out
        var params = params
        
        // remove extensions, httpBody, and apiComponents
        let extensions = params.removeValue(forKey: Networking.ParamKeys.pathExtension) as? String
        let _ = params.removeValue(forKey: Networking.ParamKeys.httpBody) // not needed for URL creation
        let _ = params.removeValue(forKey: Networking.ParamKeys.httpHeaderField) // not needed
        let _ = params.removeValue(forKey: Networking.ParamKeys.httpMethod) // not needed
        guard let apiComponents = params.removeValue(forKey: Networking.ParamKeys.components) else {
            // !! apiComponents are required !!
            return nil
        }
        
        //.. params now only contains queryItems
        
        var components = URLComponents()
        components.host = (apiComponents[Networking.ParamKeys.host] as! String)
        components.scheme = (apiComponents[Networking.ParamKeys.scheme] as! String)
        components.path = (apiComponents[Networking.ParamKeys.path] as! String) + (extensions ?? "")
        // TODO: Add items !!!
        return components.url
    }
}

// constants
extension Networking {
    
    // for sifting out dictionaries in params passed into taskWithParams
    // pathExtension: use for appended to endpoint
    // httpBody: for POST, DELETE methods
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
}

extension Networking {
    

}
