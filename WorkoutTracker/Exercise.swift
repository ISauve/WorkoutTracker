//
//  Exercise.swift
//  WorkoutTracker
//
//  Created by Isabelle Sauve on 2018-12-13.
//  Copyright © 2018 Isabelle Sauve. All rights reserved.
//

import Foundation
import os.log

struct Set {
    var weight: Int
    var reps: Int
}

struct Workout {
    var date: Date
    var sets: Array<Set>
    // one rep max?
}

class Exercise: NSObject, NSCoding {
    //MARK: Properties
    var name: String
    var notes: String?
    var data: Array<Workout>
    
    //MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("exercises")
    
    //MARK: Types
    struct PropertyKey {
        static let name = "name"
        static let notes = "notes"
        static let data = "data"
    }
    
    //MARK: Initialization
    init?(name: String, notes: String?, data: Array<Workout>) {
        guard !name.isEmpty else {
            return nil
        }
        
        self.name = name
        self.notes = notes
        self.data = data
    }
    
    //MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(name, forKey: PropertyKey.name)
        aCoder.encode(notes, forKey: PropertyKey.notes)
        aCoder.encode(data, forKey: PropertyKey.data)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        // The name is required. If we cannot decode a name string, the initializer should fail.
        guard let name = aDecoder.decodeObject(forKey: PropertyKey.name) as? String else {
            os_log("Unable to decode the name for an Exercise object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        let notes = aDecoder.decodeObject(forKey: PropertyKey.notes) as? String
        
        guard let data = aDecoder.decodeObject(forKey: PropertyKey.data) as? Array<Workout> else {
            os_log("Unable to decode the data for an Exercise object.", log: OSLog.default, type: .debug)
            return nil
        }
        
        // Must call designated initializer.
        self.init(name: name, notes: notes, data: data)
    }
}
