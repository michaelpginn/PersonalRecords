//
//  OldRecordCell.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/25/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

class OldRecordCell: UITableViewCell {
    @IBOutlet weak var customContentView: RecordCellContentView!
    @IBOutlet weak var distanceTimeLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
