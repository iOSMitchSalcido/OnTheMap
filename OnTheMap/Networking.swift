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
    
    func taskWithParams(_ params:[String:AnyObject], completion:([String:AnyObject]?, NetworkErrors?) -> [String:AnyObject]?) {
        
        print("params")
        print(params)
        
        if let url = urlForParams(params) {
            print(url.absoluteString)
        }
        else {
            print("unable to create url")
        }
        let _ = completion(nil, nil)
    }
    
    func urlForParams(_ params:[String:AnyObject]) -> URL? {
        
        // make a copy..will be pulling items out
        var params = params
        
        // remove extensions, httpBody, and apiComponents
        let extensions = params.removeValue(forKey: Networking.ParamKeys.pathExtension) as? String
        let _ = params.removeValue(forKey: Networking.ParamKeys.httpBody) // not needed for URL creation
        guard let apiComponents = params.removeValue(forKey: Networking.ParamKeys.components) else {
            // !! apiComponents are required !!
            return nil
        }
        
        //.. params now only contains queryItems
        
        var components = URLComponents()
        components.host = (apiComponents[Networking.ParamKeys.host] as! String)
        components.scheme = (apiComponents[Networking.ParamKeys.scheme] as! String)
        components.path = (apiComponents[Networking.ParamKeys.path] as! String) + (extensions ?? "")
        
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
    }
}

extension Networking {
    
    func anyFunc() {
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil { // Handle error…
                return
            }
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
        }
        task.resume()
    }
}
