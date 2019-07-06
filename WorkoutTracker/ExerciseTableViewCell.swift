//
//  ExerciseTableViewCell.swift
//  WorkoutTracker
//
//  Created by Isabelle Sauve on 2018-12-13.
//  Copyright © 2018 Isabelle Sauve. All rights reserved.
//

import UIKit
import os.log

class ExerciseTableViewCell: UITableViewCell, UITableViewDataSource, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var notesTextField: UITextField!
    @IBOutlet weak var setTablesView: UITableView!
    @IBOutlet weak var tableHeight: NSLayoutConstraint!
    
    var data = Array<Workout>()
    var currentWorkout = Workout(date:Date(), sets:Array()) // todo probably put this somewhere better
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        notesTextField.delegate = self
        setTablesView.dataSource = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        return true
    }
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (data.isEmpty && currentWorkout.sets.isEmpty) {
            return 3
        }
        if (data.isEmpty) {
            return currentWorkout.sets.count
        }
        return max(data[0].sets.count, currentWorkout.sets.count)
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "SetTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? SetTableViewCell  else {
            fatalError("The dequeued cell is not an instance of SetTableViewCell.")
        }

        cell.setNumberLabel.text = String(indexPath.row + 1)
        
        if (currentWorkout.sets.count > indexPath.row) { // we have a current set for this row
            cell.weightTextField.text = String(currentWorkout.sets[indexPath.row].weight)
            cell.repsTextField.text = String(currentWorkout.sets[indexPath.row].reps)
        }
        
        if (data.isEmpty                                // no previous workouts tracked
            || data[0].sets.count < indexPath.row) {    // previous workout didn't have this many sets
            cell.previousWeightLabel.text = ""
            cell.previousRepsLabel.text = ""
            cell.xLabel.text = "-"
            cell.weightTextField.placeholder = ""   // won't appear if the text is set
            cell.repsTextField.placeholder = ""
            
            return cell
        }

        let previousWorkout = data[0]

        cell.previousWeightLabel.text = String(previousWorkout.sets[indexPath.row].weight)
        cell.previousRepsLabel.text = String(previousWorkout.sets[indexPath.row].reps)
        cell.xLabel.text = "x"
        cell.weightTextField.placeholder = String(previousWorkout.sets[indexPath.row].weight)   // won't appear if the text is set
        cell.repsTextField.placeholder = String(previousWorkout.sets[indexPath.row].reps)

        return cell
    }
    
    // Override to support conditional editing of the table view.
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    // Override to support editing the table view.
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            saveCurrentWorkout()
            currentWorkout.sets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    //MARK: Private Methods
    @IBAction func addSet(_ sender: Any) {
        saveCurrentWorkout()
        
        let newIndexPath = IndexPath(row: currentWorkout.sets.count, section: 0)
        
        if (currentWorkout.sets.isEmpty) {
            currentWorkout.sets.append(Set(weight:0, reps:0))
        } else {
            let lastSet = currentWorkout.sets[currentWorkout.sets.endIndex - 1]
            currentWorkout.sets.append(Set(weight:lastSet.weight, reps:lastSet.reps))
        }
        
        setTablesView.insertRows(at: [newIndexPath], with: .automatic)
    }
    
    func saveCurrentWorkout() {
        currentWorkout.sets.removeAll()
        
        let numberOfTableRows = setTablesView.numberOfRows(inSection: 0)
        var i = 0
        while (i < numberOfTableRows) {
            let cell = setTablesView.cellForRow(at: IndexPath(row: i, section: 0)) as! SetTableViewCell
        
            let weight = Int(cell.weightTextField.text ?? "0") ?? 0
            let reps = Int(cell.repsTextField.text ?? "0") ?? 0
            
            currentWorkout.sets.append(Set(weight:weight, reps:reps))
            i+=1
        }
        
        /*
         TODO
         - fix the table view so that it shows all rows when new ones are added)
         - fix the fact that adding a new sets (saving the curr set) seems to only update the 1st row's data
         - fix the fact that deleting a set doesn't update the other set's set numbers
         - find a way to save the current workout (incl. notes) to the exercise
         - find a way to see the routine when the number/order of exercises changes
         - make the exercises rearrangable
         - make sure you can't add multiple of the same exercise
         - make it prettier
         - make the existing exercises pop up ? or have a way of searching through them when adding
        */
    }
}
