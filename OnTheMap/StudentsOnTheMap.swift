//
//  StudentsOnTheMap.swift
//  OnTheMap
//
//  Created by Online Training on 4/21/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import Foundation

class StudentsOnTheMap {
    
    static let shared = StudentsOnTheMap()
    private init() {}
    
    // cohort of Udacity students who are "On The Map"
    var udacions = [Student]()
}

extension StudentsOnTheMap {
    
    func newCohort(_ cohort: [[String:AnyObject]]) {
        
        var students = [Student]()
        
        for student in cohort {
            if let potentialStudent = Student(student) {
                students.append(potentialStudent)
            }
        }
        
        // remove duplicate student locations..return array with students and their most
        // recent location
        udacions = cleanupStudents(students)
    }
}

extension StudentsOnTheMap {
    
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
