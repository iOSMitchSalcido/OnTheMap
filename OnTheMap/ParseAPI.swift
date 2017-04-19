//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Online Training on 4/19/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import Foundation

class ParseAPI {
    
    // singleton
    static let shared = ParseAPI()
    private init() {}
}

extension ParseAPI {
    
    // retieve student locations
    func studentLocations(completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {

        // HTTPHeaderFields
        let httpHeaderFields = ["X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                                "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"]
        
        // create subcomponents
        let subcomponents = [Networking.ParamKeys.host: Subcomponents.host,
                             Networking.ParamKeys.path: Subcomponents.path,
                             Networking.ParamKeys.scheme: Subcomponents.scheme] as [String:AnyObject]
        
        // place in dictionary
        let parameters = [Networking.ParamKeys.httpHeaderField: httpHeaderFields,
                          Networking.ParamKeys.components: subcomponents,
                          Networking.ParamKeys.pathExtension: Paths.studentLocation] as [String:AnyObject]
        
        // create networking object, run task using params...pass completion along
        let networking = Networking()
        networking.taskWithParams(parameters as [String : AnyObject], completion: completion)
    }
}

// constants
extension ParseAPI {
    
    fileprivate struct Subcomponents {
        static let scheme = "https"
        static let host = "parse.udacity.com"
        static let path = "/parse"
    }
    
    fileprivate struct Paths {
        static let studentLocation = "/classes/StudentLocation"
    }
}
