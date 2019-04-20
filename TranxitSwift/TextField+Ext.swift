//
//  TextField+Ext.swift
//  User
//
//  Created by CSS on 28/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

extension TextField {
    
    func setPasswordView(){
        
        let passwordViewHeight = self.frame.height/2
        
        let passwordView = UIView(frame: CGRect(x: self.frame.width-(passwordViewHeight*2), y: self.frame.height/4, width: passwordViewHeight*2, height: passwordViewHeight))
        passwordView.backgroundColorId = 1
        self.addSubview(passwordView)
        
    }
    
}
