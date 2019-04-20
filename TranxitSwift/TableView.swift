//
//  TableView.swift
//  User
//
//  Created by CSS on 17/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

extension UITableView {
    
    func reloadInMainThread(){
        
        DispatchQueue.main.async {
            self.reloadData()
            
        }
        
    }
    
   
    
    
}
