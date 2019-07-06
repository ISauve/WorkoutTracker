//
//  ExerciseTableViewController.swift
//  WorkoutTracker
//
//  Created by Isabelle Sauve on 2018-12-13.
//  Copyright © 2018 Isabelle Sauve. All rights reserved.
//

import UIKit
import os.log

class ExerciseTableViewController: UITableViewController, UINavigationControllerDelegate, UITextFieldDelegate {
    //MARK: Properties
    var routine: Routine?
    var exerciseDictionary = Dictionary<String, Exercise>()
    var exercises = [Exercise]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let savedExercises = loadExerciseDictionary() {
            exerciseDictionary = savedExercises
        }
        
        if let routine = routine {
            navigationItem.title = routine.name
            
            for name in routine.exercises {
                if let exercise = exerciseDictionary[name] {
                    exercises.append(exercise)
                } else {
                    os_log("Couldn't find %@ in exercise dictionary: removing from routine", log: OSLog.default, type: .error, name)
                    guard let position = routine.exercises.firstIndex(of: name) else {
                        continue
                    }
                    routine.exercises.remove(at:position)
                }
            }
        }
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 300
        
        // Allow tapping away to end any input
        let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // gets triggered when back button is pressed
        // this is a hacky way of attaching an unwind seque from this view controller to the routine view controller
        // while still using the given 'back' button (which has the nice arrow!)
        // the alternative would be to create a custom back button which could have a segue directly attached, but then
        // we wouldn't get the arrow
        self.performSegue(withIdentifier: "unwindToRoutineTable", sender:self)
    }
    
    // MARK: Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exercises.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "ExerciseTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ExerciseTableViewCell  else {
            fatalError("The dequeued cell is not an instance of ExerciseTableViewCell.")
        }
        
        let exercise = exercises[indexPath.row]
        cell.nameLabel.text = exercise.name
        if (exercise.notes != nil) {
            cell.notesTextField.text = exercise.notes
        }
        cell.data = exercise.data
        
        return cell
    }
    
     // Override to support conditional editing of the table view.
     override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
         // Return false if you do not want the specified item to be editable.
         return true
     }
    
     // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            guard let routine = routine else {
                os_log("Failed to unwrap routine...", log: OSLog.default, type: .error)
                return
            }
            routine.exercises.remove(at: indexPath.row)
            exercises.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
         } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
         }
     }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // Mark: Private Methods
    @IBAction func addExercise(_ sender: Any) {
        let alert = UIAlertController(title: "Add Exercise", message: "", preferredStyle: UIAlertController.Style.alert)
        alert.addTextField(configurationHandler: {(textField: UITextField!) in
            textField.placeholder = "Exercise name"
            textField.delegate = self
        })
        alert.addAction(UIAlertAction(title: "Add", style: UIAlertAction.Style.default, handler:{action in self.addExerciseHandler(action, alert)}))
        self.present(alert, animated: true, completion: nil)
    }
    
    func addExerciseHandler(_ action: UIAlertAction!, _ alert:UIAlertController) {
        guard let name = alert.textFields![0].text else {
            os_log("Failed to add exercise - name is nil", log: OSLog.default, type: .error)
            return;
        }
        
        // If exercise already exists, use that - otherwise, make a new one
        let wrappedExercise = exerciseDictionary[name] ?? Exercise(name:name, notes:nil, data:Array())
        guard let exercise = wrappedExercise else {
            os_log("Failed to add %@", log: OSLog.default, type: .error, name)
            return
        }
        
        guard let routine = routine else {
            os_log("Failed to unwrap routine...", log: OSLog.default, type: .error)
            return
        }

        let newIndexPath = IndexPath(row: exercises.count, section: 0)
        exercises.append(exercise)
        tableView.insertRows(at: [newIndexPath], with: .automatic)
        routine.exercises.append(exercise.name)
        
        #if DEBUG_LOGGING
        os_log("Added %@ to %@", log: OSLog.default, type: .debug, exercise.name, routine.name)
        #endif

        saveExercises()
    }
    
    private func loadExerciseDictionary() -> Dictionary<String, Exercise>? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Exercise.ArchiveURL.path) as? Dictionary<String, Exercise>
    }
    
    private func saveExercises() {
        for exercise in exercises {
            exerciseDictionary[exercise.name] = exercise
        }
        
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(exerciseDictionary, toFile: Exercise.ArchiveURL.path)
        if isSuccessfulSave {
            #if DEBUG_LOGGING
            os_log("Exercises successfully saved.", log: OSLog.default, type: .debug)
            #endif
        } else {
            os_log("Failed to save exercises...", log: OSLog.default, type: .error)
        }
    }
}
