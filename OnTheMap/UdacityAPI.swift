//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Online Training on 4/17/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About UdacityAPI.swift:
 Interface for Udacity API. Handles posting session, retrieving student info, deleting a session.
 */

import Foundation

class UdacityAPI {
    
    // singleton
    static let shared = UdacityAPI()
    private init() {}
}

extension UdacityAPI {
    
    // post session
    func postSessionForUser(_ user:String, password:String, completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {
        
        /*
         POST a session to get a sessionID, required for authentication of Udacity API requests
         */
        
        // HTTPHeaderFields
        let httpHeaderFields = ["Accept": "application/json", "Content-Type": "application/json"]
        
        // httpBody for post method
        let httpBody = ["udacity": ["username": user, "password": password]]
        
        // create subcomponents
        let subcomponents = [Networking.ParamKeys.host: Subcomponents.host,
                             Networking.ParamKeys.path: Subcomponents.path,
                             Networking.ParamKeys.scheme: Subcomponents.scheme] as [String:AnyObject]
        
        // place in dictionary
        let parameters = [Networking.ParamKeys.httpHeaderField: httpHeaderFields,
                          Networking.ParamKeys.httpMethod: "POST",
                          Networking.ParamKeys.httpBody: httpBody,
                          Networking.ParamKeys.components: subcomponents,
                          Networking.ParamKeys.pathExtension: Paths.postSession] as [String:AnyObject]
        
        // create networking object, run task using params...pass completion along
        let networking = Networking()
        networking.taskWithParams(parameters as [String : AnyObject], completion: completion)
    }
    
    // get public data for a user
    func getPublicUserData(userID: String, completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {
        
        // create subcomponents
        let subcomponents = [Networking.ParamKeys.host: Subcomponents.host,
                             Networking.ParamKeys.path: Subcomponents.path,
                             Networking.ParamKeys.scheme: Subcomponents.scheme]
        
        // path extension
        let pathExtension = Paths.getPublicUserData + "/" + userID
        
        // place in dictionary...note no query items included
        let parameters = [Networking.ParamKeys.components: subcomponents,
                          Networking.ParamKeys.pathExtension: pathExtension] as [String:AnyObject]
        
        // create networking object, run task using params...pass completion along
        let networking = Networking()
        networking.taskWithParams(parameters, completion: completion)
    }
    
    // delete session
    func deleteSession() {
        
        // copied from Udacity, unmodified
        
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

// constants
extension UdacityAPI {
    
    // subcomponents used to form URL
    fileprivate struct Subcomponents {
        static let scheme = "https"
        static let host = "www.udacity.com" // need the www, otherwise won't "register" = 1
        static let path = "/api"
    }
    
    // method paths
    fileprivate struct Paths {
        static let postSession = "/session"
        static let getPublicUserData = "/users"
    }
    
    // keys used to access account info
    struct Account {
        static let account = "account"
        static let key = "key"
        static let registered = "registered"
    }
    
    // Udacity response
    struct ResponseKeys {
        static let user = "user"
        static let firstName = "first_name"
        static let lastName = "last_name"
    }
}
