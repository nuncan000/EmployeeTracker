//
//  EmployeeTableViewCell.swift
//  EmployeeTracker
//
//  Created by Catalyst IT on 7/25/16.
//  Copyright © 2016 Catalyst DevWorks. All rights reserved.
//

import UIKit

class EmployeeTableViewCell: UITableViewCell
{
    // MARK: Properties
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!
    
    // MARK: Parent Member Functions
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
