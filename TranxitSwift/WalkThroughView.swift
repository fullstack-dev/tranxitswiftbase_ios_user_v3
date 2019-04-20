//
//  WalkThroughView.swift
//  User
//
//  Created by CSS on 27/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

class WalkThroughView : UIView {
    
    @IBOutlet private weak var imageView : UIImageView!
    @IBOutlet private weak var labelTitle : UILabel!
    @IBOutlet private weak var labelSubTitle : UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setDesign()
    }
    
}

// Mark :- Local methods

extension WalkThroughView {
    
    func set(image : UIImage?, title : String?, description descriptionText : String?){
        
        self.imageView.image = image
        self.labelTitle.text = title
        self.labelSubTitle.text = descriptionText
    }
    
    // Set Designs
    private func setDesign () {
        
        Common.setFont(to: labelTitle, isTitle: true)
        Common.setFont(to: labelSubTitle)
    }
}
