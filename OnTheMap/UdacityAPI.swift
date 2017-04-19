//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Online Training on 4/17/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

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
}

// constants
extension UdacityAPI {
    
    fileprivate struct Subcomponents {
        static let scheme = "https"
        static let host = "www.udacity.com"
        static let path = "/api"
    }
    
    fileprivate struct Paths {
        static let postSession = "/session"
        static let deleteSession = "/session"
        static let getPublicUserData = "/users"
    }
}
