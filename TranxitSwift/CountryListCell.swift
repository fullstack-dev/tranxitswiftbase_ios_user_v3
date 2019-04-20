//
//  CountryListCell.swift
//  ES ECO
//
//  Created by VividMacmini7 on 29/05/18.
//  Copyright © 2018 VividInfotech. All rights reserved.
//

import UIKit

class CountryListCell: UITableViewCell {
    
    @IBOutlet weak var codeLbl:UILabel!
    @IBOutlet weak var countryNameLbl:UILabel!
    @IBOutlet weak var flagImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
