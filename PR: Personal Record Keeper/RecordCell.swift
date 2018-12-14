//
//  RecordCell.swift
//  PR: Personal Record Keeper
//
//  Created by Michael Ginn on 7/5/18.
//  Copyright © 2018 Michael Ginn. All rights reserved.
//

import UIKit

final class RecordCell: OldRecordCell {
    //@IBOutlet weak var customContentView: RecordCellContentView!
    @IBOutlet public weak var distanceNameLabel: UILabel!
    @IBOutlet weak var activityTypeImageView: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
