//
//  StudentsOnTheMap.swift
//  OnTheMap
//
//  Created by Online Training on 4/21/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About StudentsOnTheMap.swift:
 Model/Store class to maintain array of Students (udacions), and provide access to udacions property. Intended for use
 as a singleton to maintain data store retrieved from Parse/Udacity API's
*/

import Foundation

class StudentsOnTheMap {
    
    // singleton
    static let shared = StudentsOnTheMap()
    private init() {}
    
    // array "cohort" of Udacity students who are "On The Map"
    var udacions = [Student]()
    
    // store uniqueKey for user....retrieved during Udacity session post
    var myUniqueKey: String!
    
    // return student in udacions array...if exists. Otherwise return nil
    func onTheMap(uniqueKey: String) -> Student? {
        
        for (_, value) in udacions.enumerated() {
            if value.uniqueKey == uniqueKey {
                return value
            }
        }
        
        return nil
    }
    
    // function to read in array of students, and place into udacians array
    func newCohort(_ cohort: [[String:AnyObject]]) {
        
        // create array
        var students = [Student]()
        for student in cohort {
            // test for good student...failable initializer. Append if good
            if let potentialStudent = Student(student) {
                students.append(potentialStudent)
            }
        }
        
        // remove duplicate student locations..return array with students and their most
        // recent location
        udacions = cleanupStudents(students)
    }
    
    // update cohort array, fire completion
    func updateCohort(completion: @escaping (NetworkErrors?) -> Void) {
        
        ParseAPI().studentLocations() {
            (params, error) in
            
            // test error
            if let error = error {
                
                // fire completion with error
                completion(error)
            }
            // test params
            else if let students = params?[ParseAPI.ResponseKeys.results] as? [[String:AnyObject]] {
                
                // good parse..update udacions array with new cohort
                self.newCohort(students)
                
                // done
                completion(nil)
            }
            // unknown student locations failure
            else {
                
                // fire completion with error
                completion(NetworkErrors.generalError("Unable to retrieve student locations"))
            }
        }
    }
}

// helper functions
extension StudentsOnTheMap {
    
    /*
     Retrieving students locations returns many results..lot's of duplicate students.
     Assuming that students somehow posted their location multiple times without removing old location.
     This function parses a students array, removing duplicate students and placing the latest location update.
     */
    fileprivate func cleanupStudents(_ students: [Student]) -> [Student] {
        
        // track ID's that have been inspected
        var checkedIDs = [String]()
        
        // dictionary to store all postings by a given student
        var studentsByIDs = [String: [Student]]()
        
        // iterate thru students
        for student in students {
            
            // test if ID has been inspected
            if !checkedIDs.contains(student.uniqueKey) {
                
                // ID has not been inspected..add to checkedIDs array
                checkedIDs.append(student.uniqueKey)
                
                // array to store students with idential ID's
                var studentsWithSameIDs = [Student]()
                
                // iterate thru all students again.
                for anotherStudent in students {
                    
                    // Pick out students who's IDs match..add to array
                    if anotherStudent.uniqueKey == student.uniqueKey {
                        studentsWithSameIDs.append(anotherStudent)
                    }
                }
                
                // add to dictionary
                studentsByIDs[student.uniqueKey] = studentsWithSameIDs
            }
        }
        
        // studentsByIDs now contains a dictionary. The keys are "uniqueKey" for a given student, and the value is
        // an array containing each location update/creation for that student.
        
        /*
         Now need to sort out the most recent post/update by a given student
        */
        
        // array to store students..
        var mostRecentStudentPost = [Student]()
        for (_, studentEntries) in studentsByIDs {
            
            // sort post/updates of a given student
            let sorted = studentEntries.sorted() {
                (entry1, entry2) in
                let date1 = entry1.updatedAt
                let date2 = entry2.updatedAt
                return date1.compare(date2) == ComparisonResult.orderedDescending
            }
            
            // retrieve most recent post/update
            if let mostRecent = sorted.first {
                mostRecentStudentPost.append(mostRecent)
            }
        }
        
        // Each Student in "mostRecentStudentPost" array is a unique student, with their most recent
        // posting/update info.

        // Now sort students by post/update date
        let onTheMapAndSortedByDate = mostRecentStudentPost.sorted() {
            (entry1, entry2) in
            let date1 = entry1.updatedAt
            let date2 = entry2.updatedAt
            return date1.compare(date2) == ComparisonResult.orderedDescending
        }
        
        // return array of udacions, sorted by updated posting.
        return onTheMapAndSortedByDate
    }
}
