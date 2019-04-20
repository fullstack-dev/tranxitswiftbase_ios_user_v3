//
//  DisputeSenderCell.swift
//  TranxitUser
//
//  Created by Ansar on 19/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import UIKit

class DisputeSenderCell: UITableViewCell {
    
    @IBOutlet weak var imgProfile:UIImageView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblContent:UILabel!
    @IBOutlet weak var viewStatus:UIView!
    @IBOutlet weak var lblStatus:UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setFont()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

extension DisputeSenderCell {
    private func setFont() {
        Common.setFont(to: lblName, isTitle: true, size: 16)
        Common.setFont(to: lblContent, isTitle: false, size: 14)
        Common.setFont(to: lblStatus, isTitle: false, size: 14)
        imgProfile.makeRoundedCorner()
        self.viewStatus.cornerRadius = self.viewStatus.frame.height / 2
    }
}
