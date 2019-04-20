//
//  CollectionView.swift
//  User
//
//  Created by CSS on 08/02/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

extension UICollectionView {

    
    func reloadCustom(){
        
        DispatchQueue.main.async {
            
            self.reloadData()
            
            var bool = false
            
            for section in 0..<self.numberOfSections {
                bool = self.numberOfItems(inSection: section)>0
            }
            
            self.backgroundView = {
               
                if bool {
                    
                    return nil
                    
                } else {
                   
                    let emptyView = Bundle.main.loadNibNamed(XIB.Names.EmptyData, owner: self, options: [:])?.first as? EmptyDataView
                     self.backgroundView?.frame = CGRect(origin: self.center, size: CGSize(width: self.frame.width*0.6, height: self.frame.width*0.6))
                    return emptyView
                    
                }
                
            }()
           
            
        }
        
    }
    
}
