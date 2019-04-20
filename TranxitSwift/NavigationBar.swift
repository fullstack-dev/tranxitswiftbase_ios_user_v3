//
//  NavigationController.swift
//  User
//
//  Created by CSS on 16/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

extension UINavigationItem {
    
    
    func set(title:String?, subtitle:String?) {
        
        let titleLabel = UILabel(frame: CGRect(x: 0, y: -2, width: 0, height: 0))
        
        titleLabel.backgroundColor = .clear
        titleLabel.textColor = .black
        titleLabel.font = UIFont.boldSystemFont(ofSize: 17)
        titleLabel.text = title
        titleLabel.sizeToFit()
        
        let subtitleLabel = UILabel(frame: CGRect(x: 0, y: 18, width: 0, height: 0))
        subtitleLabel.backgroundColor = .clear
        subtitleLabel.textColor = .gray
        subtitleLabel.font = UIFont.systemFont(ofSize: 12)
        subtitleLabel.text = subtitle
        subtitleLabel.sizeToFit()
        
        let titleVieww = UIView(frame: CGRect(origin: .zero, size: CGSize(width: max(titleLabel.frame.size.width, subtitleLabel.frame.size.width), height: 30)))
        titleVieww.addSubview(titleLabel)
        titleVieww.addSubview(subtitleLabel)
        
        let widthDiff = subtitleLabel.frame.size.width - titleLabel.frame.size.width
        
        if widthDiff < 0 {
            let newX = widthDiff / 2
            subtitleLabel.frame.origin.x = abs(newX)
        } else {
            let newX = widthDiff / 2
            titleLabel.frame.origin.x = newX
        }
        
        self.titleView = titleVieww
        
    }
   
    
}
