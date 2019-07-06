//
//  RoutineTableViewCell.swift
//  WorkoutTracker
//
//  Created by Isabelle Sauve on 2018-12-13.
//  Copyright © 2018 Isabelle Sauve. All rights reserved.
//

import UIKit

class RoutineTableViewCell: UITableViewCell {
    //MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
