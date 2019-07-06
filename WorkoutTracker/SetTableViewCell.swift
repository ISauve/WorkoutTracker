//
//  SetTableViewCell.swift
//  WorkoutTracker
//
//  Created by Isabelle Sauve on 2018-12-13.
//  Copyright © 2018 Isabelle Sauve. All rights reserved.
//

import UIKit
import os.log

class SetTableViewCell: UITableViewCell, UITextFieldDelegate {
    //MARK: Properties
    @IBOutlet weak var setNumberLabel: UILabel!
    @IBOutlet weak var previousWeightLabel: UILabel!
    @IBOutlet weak var xLabel: UILabel!
    @IBOutlet weak var previousRepsLabel: UILabel!
    @IBOutlet weak var weightTextField: UITextField!
    @IBOutlet weak var repsTextField: UITextField!
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Hide the keyboard.
        textField.resignFirstResponder()
        os_log("wtf", log:OSLog.default, type: .debug)
        return true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        weightTextField.delegate = self
        repsTextField.delegate = self
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}

