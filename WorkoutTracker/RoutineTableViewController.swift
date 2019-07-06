//
//  RoutineTableViewController.swift
//  WorkoutTracker
//
//  Created by Isabelle Sauve on 2018-12-13.
//  Copyright © 2018 Isabelle Sauve. All rights reserved.
//

import UIKit
import os.log

class RoutineTableViewController: UITableViewController, UINavigationControllerDelegate {
    //MARK: Properties
    var routines = [Routine]()
    
    var dragInitialIndexPath: IndexPath?
    var dragCellSnapshot: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load any saved routines
        if let savedRoutines = loadRoutines() {
            routines += savedRoutines
        }

        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(sender:)))
        longPress.minimumPressDuration = 0.2
        tableView.addGestureRecognizer(longPress)
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return routines.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier
        let cellIdentifier = "RoutineTableViewCell"
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RoutineTableViewCell  else {
            fatalError("The dequeued cell is not an instance of RoutineTableViewCell.")
        }
        
        let routine = routines[indexPath.row]
        cell.nameLabel.text = routine.name
        
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
            routines.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            saveRoutines()
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch(segue.identifier ?? "") {
            
        case "AddRoutine":
            #if DEBUG_LOGGING
            os_log("Adding a new routine.", log: OSLog.default, type: .debug)
            #endif
            
        case "ShowRoutine":
            guard let exerciseTableViewController = segue.destination as? ExerciseTableViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedRoutineCell = sender as? RoutineTableViewCell else {
                fatalError("Unexpected sender: \(String(describing: sender))")
            }
            
            guard let indexPath = tableView.indexPath(for: selectedRoutineCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            let selectedRoutine = routines[indexPath.row]
            exerciseTableViewController.routine = selectedRoutine
            
        default:
            fatalError("Unexpected Segue Identifier; \(String(describing: segue.identifier))")
        }
    }
    
    // MARK: Actions
    @IBAction func unwindToRoutineList(sender: UIStoryboardSegue) {
        if let sourceViewController = sender.source as? NewRoutineViewController, let routine = sourceViewController.routine {
            let newIndexPath = IndexPath(row: routines.count, section: 0)
            routines.append(routine)
            tableView.insertRows(at: [newIndexPath], with: .automatic)
            #if DEBUG_LOGGING
            os_log("Added a new routine: %@", log: OSLog.default, type: .debug, routine.name)
            #endif
        }
        #if DEBUG_LOGGING
        if let sourceViewController = sender.source as? ExerciseTableViewController, let routine = sourceViewController.routine {
            os_log("Returned from viewing %@", log: OSLog.default, type: .debug, routine.name)
        }
        #endif
        
        saveRoutines()
    }
    
    //MARK: Private Methods
    private func loadRoutines() -> [Routine]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: Routine.ArchiveURL.path) as? [Routine]
    }
    
    private func saveRoutines() {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(routines, toFile: Routine.ArchiveURL.path)
        
        if isSuccessfulSave {
            #if DEBUG_LOGGING
            os_log("Routines successfully saved.", log: OSLog.default, type: .debug)
            #endif
        } else {
            os_log("Failed to save routines...", log: OSLog.default, type: .error)
        }
    }
    
    // MARK: cell reorder / long press
    // source: https://stackoverflow.com/questions/12257008/using-long-press-gesture-to-reorder-cells-in-tableview
    @objc func onLongPressGesture(sender: UILongPressGestureRecognizer) {
        let locationInView = sender.location(in: tableView)
        let indexPath = tableView.indexPathForRow(at: locationInView)
        
        if sender.state == .began {
            if indexPath != nil {
                dragInitialIndexPath = indexPath
                let cell = tableView.cellForRow(at: indexPath!)
                dragCellSnapshot = snapshotOfCell(inputView: cell!)
                var center = cell?.center
                dragCellSnapshot?.center = center!
                dragCellSnapshot?.alpha = 0.0
                tableView.addSubview(dragCellSnapshot!)
                
                UIView.animate(withDuration: 0.25, animations: { () -> Void in
                    center?.y = locationInView.y
                    self.dragCellSnapshot?.center = center!
                    self.dragCellSnapshot?.transform = (self.dragCellSnapshot?.transform.scaledBy(x: 1.05, y: 1.05))!
                    self.dragCellSnapshot?.alpha = 0.99
                    cell?.alpha = 0.0
                }, completion: { (finished) -> Void in
                    if finished {
                        cell?.isHidden = true
                    }
                })
            }
        } else if sender.state == .changed && dragInitialIndexPath != nil {
            var center = dragCellSnapshot?.center
            center?.y = locationInView.y
            dragCellSnapshot?.center = center!
            
            // to lock dragging to same section add: "&& indexPath?.section == dragInitialIndexPath?.section" to the if below
            if indexPath != nil && indexPath != dragInitialIndexPath {
                // update your data model
                let dataToMove = routines[dragInitialIndexPath!.row]
                routines.remove(at: dragInitialIndexPath!.row)
                routines.insert(dataToMove, at: indexPath!.row)
                
                tableView.moveRow(at: dragInitialIndexPath!, to: indexPath!)
                dragInitialIndexPath = indexPath
            }
        } else if sender.state == .ended && dragInitialIndexPath != nil {
            let cell = tableView.cellForRow(at: dragInitialIndexPath!)
            cell?.isHidden = false
            cell?.alpha = 0.0
            UIView.animate(withDuration: 0.25, animations: { () -> Void in
                self.dragCellSnapshot?.center = (cell?.center)!
                self.dragCellSnapshot?.transform = CGAffineTransform.identity
                self.dragCellSnapshot?.alpha = 0.0
                cell?.alpha = 1.0
            }, completion: { (finished) -> Void in
                if finished {
                    self.dragInitialIndexPath = nil
                    self.dragCellSnapshot?.removeFromSuperview()
                    self.dragCellSnapshot = nil
                }
            })
        }
    }
    
    func snapshotOfCell(inputView: UIView) -> UIView {
        UIGraphicsBeginImageContextWithOptions(inputView.bounds.size, false, 0.0)
        inputView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        let cellSnapshot = UIImageView(image: image)
        cellSnapshot.layer.masksToBounds = false
        cellSnapshot.layer.cornerRadius = 0.0
        cellSnapshot.layer.shadowOffset = CGSize(width: -5.0, height: 0.0)
        cellSnapshot.layer.shadowRadius = 5.0
        cellSnapshot.layer.shadowOpacity = 0.4
        return cellSnapshot
    }
}
