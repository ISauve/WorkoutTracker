//
//  Routine.swift
//  WorkoutTracker
//
//  Created by Isabelle Sauve on 2018-12-13.
//  Copyright © 2018 Isabelle Sauve. All rights reserved.
//

import Foundation
import os.log

class Routine: NSObject, NSCoding {
    //MARK: Properties
    var name: String
    var group: String?
    var exercises: Array<String>
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("routines")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let group = "group"
        static let exercises = "exercises"
    }
    
    //MARK: Initialization
    init?(name: String, group: String?, exercises: Array<String>) {
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.group = group
        self.exercises = exercises
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(group, forKey: PropertyKey.group)
        aCoder.encode(exercises, forKey: PropertyKey.exercises)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for a Routine object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Because group is an optional property of Routine, just use conditional cast.
        let group = aDecoder.decodeObject(forKey: PropertyKey.group) as? String
        
        guard let exercises = aDecoder.decodeObject(forKey: PropertyKey.exercises) as? Array<String> else {
            os_log("Unable to decode the exercises for a Routine object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(name: name, group: group, exercises: exercises)
    }
}
