//
//  ReminderTableViewCell.swift
//  ProximityReminders
//
//  Created by Ty Schenk on 09/13/17.
//  Copyright © 2017 Ty Schenk. All rights reserved.
//

import UIKit

class ReminderTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    ///Configure the cell: it sets the titleLabel and the accessory Type
    func configure(withReminder reminder: Reminder) {
        
        self.titleLabel.text = reminder.text
        //if is completes
        if reminder.isCompleted {
            //show the checkmark
            self.accessoryType = .checkmark
        } else {
            //otherwise the arrow
            self.accessoryType = .disclosureIndicator
        }
    }


}
