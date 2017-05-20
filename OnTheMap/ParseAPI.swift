//
//  ParseAPI.swift
//  OnTheMap
//
//  Created by Online Training on 4/19/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About ParseAPI.swift:
 Interface for Parse API. Functionality to retrieve student locations, post/update a student location.
 
 API function create a paramaters dictionionary which contains data required to build a URL, Request, and
 invoke a dataTask. The parameters are then used to call taskWithParams in Networking struct.
*/

import Foundation

struct ParseAPI {
    
    // retieve student locations
    func studentLocations(completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {
        
        /*
         function to retrieve locations of students who are "on the map"
         */
        
        // HTTPHeaderFields
        let httpHeaderFields = ["X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                                "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"]
        
        // create subcomponents
        let subcomponents = [Networking.ParamKeys.host: Subcomponents.host,
                             Networking.ParamKeys.path: Subcomponents.path,
                             Networking.ParamKeys.scheme: Networking.ParamValues.secureScheme]
        
        // place in dictionary
        let parameters = [Networking.ParamKeys.httpHeaderField: httpHeaderFields,
                          Networking.ParamKeys.components: subcomponents,
                          Networking.ParamKeys.pathExtension: Paths.studentLocation] as [String:AnyObject]
        
        // create networking object, run task using params...pass completion along
        let networking = Networking()
        networking.taskWithParams(parameters as [String : AnyObject], completion: completion)
    }
    
    // post new location for a student
    func postStudentLocation(_ student: Student, completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {
        
        /*
         function to post a new location for a student
         */
        
        // HTTPHeaderFields
        let httpHeaderFields = ["X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                                "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY",
                                "Content-Type": "application/json"]
        
        // create subcomponents
        let subcomponents = [Networking.ParamKeys.host: Subcomponents.host,
                             Networking.ParamKeys.path: Subcomponents.path,
                             Networking.ParamKeys.scheme: Networking.ParamValues.secureScheme]
        
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
    
    // update location for a student
    func putStudentLocation(_ student: Student, completion:@escaping ([String:AnyObject]?, NetworkErrors?) -> Void) {
        
        /*
         function to update the location of a student who is "on the map"
         */
        
        // HTTPHeaderFields
        let httpHeaderFields = ["X-Parse-Application-Id": "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr",
                                "X-Parse-REST-API-Key": "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY",
                                "Content-Type": "application/json"]
        
        // create subcomponents
        let subcomponents = [Networking.ParamKeys.host: Subcomponents.host,
                             Networking.ParamKeys.path: Subcomponents.path,
                             Networking.ParamKeys.scheme: Networking.ParamValues.secureScheme]
        
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
