//
//  DisputeCell.swift
//  TranxitUser
//
//  Created by Ranjith Ravichandran on 12/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit

class DisputeCell: UITableViewCell {
    
    @IBOutlet weak var imageRadio:UIImageView!
    @IBOutlet weak var lblTitle:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imageRadio.image = #imageLiteral(resourceName: "circle-shape-outline")
        Common.setFont(to: lblTitle)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
