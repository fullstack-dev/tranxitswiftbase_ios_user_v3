//
//  Bundle.swift
//  User
//
//  Created by CSS on 20/04/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

extension Bundle {
    
    func getVersion()->String{
        
        return "\((Bundle.main.infoDictionary?["CFBundleShortVersionString"])!)"
    }
    
}
