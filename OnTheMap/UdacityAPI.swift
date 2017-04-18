//
//  UdacityAPI.swift
//  OnTheMap
//
//  Created by Online Training on 4/17/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import Foundation

struct UdacityAPI {
    
}

extension UdacityAPI {
    
    static func postSessionForUser(_ user:String, password:String, completion:([String:AnyObject]?, NetworkErrors?) -> [String:AnyObject]?) {
        
        // httpBody
        let httpBody = ["udacity": ["username": user, "password": password]]
        
        // create components
        let components = [Networking.ParamKeys.host: Subcomponents.host,
                          Networking.ParamKeys.path: Subcomponents.path,
                          Networking.ParamKeys.scheme: Subcomponents.scheme]
        
        // place in dictionary...note no query items included
        let parameters = [Networking.ParamKeys.httpBody: httpBody,
                          Networking.ParamKeys.components: components,
                          Networking.ParamKeys.pathExtension: Paths.sessionPost] as [String : AnyObject]
        
        let networking = Networking()
        networking.taskWithParams(parameters as [String : AnyObject], completion: completion)
    }
}

// constants
extension UdacityAPI {
    
    struct Subcomponents {
        fileprivate static let scheme = "https"
        fileprivate static let host = "www.udacity.com"
        fileprivate static let path = "/api"
    }
    
    struct Paths {
        fileprivate static let sessionPost = "/session"
        fileprivate static let sessionDelete = "/session"
    }
}
