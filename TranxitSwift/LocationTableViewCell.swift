//
//  LocationTableViewCell.swift
//  User
//
//  Created by CSS on 10/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {
    
    @IBOutlet weak var lblLocationTitle:UILabel!
    @IBOutlet weak var lblLocationSubTitle:UILabel!
    @IBOutlet weak var imageLocationPin:UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
