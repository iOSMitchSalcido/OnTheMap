//
//  Student.swift
//  OnTheMap
//
//  Created by Online Training on 4/20/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About Student.swift:
 */

import Foundation

struct Student {
    
    var objectId: String
    var uniqueKey: String
    var firstName: String
    var lastName: String
    var mapString: String
    var mediaURL: String
    var latitude: Double
    var longitude: Double
    var createdAt: String
    var updatedAt: String

    // failable initializer
    // ...only want the good students..the ones who's info is complete
    init?(_ student: [String:AnyObject]) {
        
        guard let objectId = student[Keys.objectId] as? String,
            let uniqueKey = student[Keys.uniqueKey] as? String,
            let firstName = student[Keys.firstName] as? String,
            let lastName = student[Keys.lastName] as? String,
            let mapString = student[Keys.mapString] as? String,
            let mediaURL = student[Keys.mediaURL] as? String,
            let latitude = student[Keys.latitude] as? Double,
            let longitude = student[Keys.longitude] as? Double,
            let createdAt = student[Keys.createdAt] as? String,
            let updatedAt = student[Keys.updatedAt] as? String else {
                return nil
        }
        
        self.objectId = objectId
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = mapString
        self.mediaURL = mediaURL
        self.latitude = latitude
        self.longitude = longitude
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    // easy init...create a student with only name/ID
    init(uniqueKey: String, firstName: String, lastName: String) {
        self.objectId = "objectId"
        self.uniqueKey = uniqueKey
        self.firstName = firstName
        self.lastName = lastName
        self.mapString = "mapString"
        self.mediaURL = "mediaURL"
        self.latitude = 0.0
        self.longitude = 0.0
        self.createdAt = "createdAt"
        self.updatedAt = "updatedAt"
    }
}

extension Student {
    
    struct Keys {
        static let objectId = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    }
}
