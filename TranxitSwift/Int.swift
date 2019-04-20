//
//  Normal_Extensions.swift
//  User
//
//  Created by imac on 12/22/17.
//  Copyright © 2017 Appoets. All rights reserved.
//
import UIKit

extension Int {
    
    static func removeNil(_ val : Int?)->Int{
    
         return val ?? 0
    }
    
}


extension Float {
    
    static func removeNil(_ val : Float?)->Float{
        
        return val ?? 0
    }
    
}

extension Double {
    // Rounds the double to decimal places value
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
