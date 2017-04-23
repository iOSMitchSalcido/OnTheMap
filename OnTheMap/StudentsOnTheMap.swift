//
//  StudentsOnTheMap.swift
//  OnTheMap
//
//  Created by Online Training on 4/21/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About StudentsOnTheMap.swift:
 Model/Store class to maintain array of Students (udacions), and provide access to udacions property
*/

import Foundation

class StudentsOnTheMap {
    
    // singleton
    static let shared = StudentsOnTheMap()
    private init() {}
    
    // cohort of Udacity students who are "On The Map"
    fileprivate var udacions = [Student]()
    
    // count of udacions
    var udacionCount: Int {
        get {
            return self.udacions.count
        }
    }
    
    // retrieved when POST session.
    var myUniqueKey:String?
}

// helper functions
extension StudentsOnTheMap {
    
    // return udacion at index
    func udacionAtIndex(_ index: Int) -> Student {
        return udacions[index]
    }
    
    // test if uniqueKey is a udacion who is on the map
    func isUdation(uniqueKey: String) -> Bool {
    
        for udacion in udacions {
            if udacion.uniqueKey == uniqueKey {
                return true
            }
        }
        return true
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
    
    /*
     helper function. Retrieving students locations returns many results..lot's of duplicate students.
     Assuming that students posted their location multiple times without removing old location.
     This function parses a students array, removing duplicate locations and placing the latest location update.
     */
    fileprivate func cleanupStudents(_ students: [Student]) -> [Student] {
        
        var checkedIDs = [String]()
        var studentsByIDs = [String: [Student]]()
        for student in students {
            
            if !checkedIDs.contains(student.uniqueKey) {
                
                checkedIDs.append(student.uniqueKey)
                
                var studentsWithSameIDs = [Student]()
                
                for anotherStudent in students {
                    
                    if anotherStudent.uniqueKey == student.uniqueKey {
                        studentsWithSameIDs.append(anotherStudent)
                    }
                }
                
                studentsByIDs[student.uniqueKey] = studentsWithSameIDs
            }
        }
        
        // studentsByIDs now contains a dictionary. The keys are "uniqueKey" for a given student, and the value is
        // an array containing each location update/creation for that student
        
        // array to store good students
        var cleanedupStudents = [Student]()
        
        for (_, studentEntries) in studentsByIDs {
            
            let sorted = studentEntries.sorted() {
                (entry1, entry2) in
                let date1 = entry1.createdAt
                let date2 = entry2.createdAt
                return date1.compare(date2) == ComparisonResult.orderedAscending
            }
            
            if let mostRecentStudentLocation = sorted.last {
                cleanedupStudents.append(mostRecentStudentLocation)
            }
        }
        
        return cleanedupStudents
    }
}

