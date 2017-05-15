//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Online Training on 4/19/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About ParseAPI.swift:
*/

import Foundation

class ParseAPI {
    
    // singleton
    static let shared = ParseAPI()
    private init() {}
}

// Parse methods
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
    
    func postStudentLocation(_ student: Student, completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {
        
        // HTTPHeaderFields
        let httpHeaderFields = ["X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                                "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY",
                                "Content-Type": "application/json"]
        
        // create subcomponents
        let subcomponents = [Networking.ParamKeys.host: Subcomponents.host,
                             Networking.ParamKeys.path: Subcomponents.path,
                             Networking.ParamKeys.scheme: Subcomponents.scheme] as [String:AnyObject]
        
        let httpBody = [Student.Keys.uniqueKey: student.uniqueKey,
                        Student.Keys.firstName: student.firstName,
                        Student.Keys.lastName: student.lastName,
                        Student.Keys.mapString: student.mapString,
                        Student.Keys.mediaURL: student.mediaURL,
                        Student.Keys.latitude: student.latitude,
                        Student.Keys.longitude: student.longitude] as [String : Any]
        
        // place in dictionary
        let parameters = [Networking.ParamKeys.httpHeaderField: httpHeaderFields,
                          Networking.ParamKeys.httpMethod: "POST",
                          Networking.ParamKeys.httpBody: httpBody,
                          Networking.ParamKeys.components: subcomponents,
                          Networking.ParamKeys.pathExtension: Paths.studentLocation] as [String:AnyObject]
        
        // create networking object, run task using params...pass completion along
        let network = Networking()
        network.taskWithParams(parameters, completion: completion)
    }
    
    func putStudentLocation(_ student: Student, completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {
        
        // HTTPHeaderFields
        let httpHeaderFields = ["X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                                "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY",
                                "Content-Type": "application/json"]
        
        // create subcomponents
        let subcomponents = [Networking.ParamKeys.host: Subcomponents.host,
                             Networking.ParamKeys.path: Subcomponents.path,
                             Networking.ParamKeys.scheme: Subcomponents.scheme] as [String:AnyObject]
        
        let httpBody = [Student.Keys.uniqueKey: student.uniqueKey,
                        Student.Keys.firstName: student.firstName,
                        Student.Keys.lastName: student.lastName,
                        Student.Keys.mapString: student.mapString,
                        Student.Keys.mediaURL: student.mediaURL,
                        Student.Keys.latitude: student.latitude,
                        Student.Keys.longitude: student.longitude] as [String : Any]
        
        // path extension
        let pathExtension = Paths.studentLocation + "/" + student.objectId
        
        // place in dictionary
        let parameters = [Networking.ParamKeys.httpHeaderField: httpHeaderFields,
                          Networking.ParamKeys.httpMethod: "PUT",
                          Networking.ParamKeys.httpBody: httpBody,
                          Networking.ParamKeys.components: subcomponents,
                          Networking.ParamKeys.pathExtension: pathExtension] as [String:AnyObject]
        
        // create networking object, run task using params...pass completion along
        let network = Networking()
        network.taskWithParams(parameters, completion: completion)
    }
}

// constants
extension ParseAPI {
    
    // subcomponents used to form URL
    fileprivate struct Subcomponents {
        static let scheme = "https"
        static let host = "parse.udacity.com"
        static let path = "/parse"
    }
    
    // method paths
    fileprivate struct Paths {
        static let studentLocation = "/classes/StudentLocation"
    }
    
    // Parse responses
    struct ResponseKeys {
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
        static let objectId = "objectId"
        static let results = "results"
    }
}
