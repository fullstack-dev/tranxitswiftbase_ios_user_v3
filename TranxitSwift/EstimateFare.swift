//
//  EstimateFare.swift
//  User
//
//  Created by CSS on 31/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class EstimateFare : JSONSerializable {
    
    var estimated_fare : Float?
    var distance : Float?
    var time : String?
    var surge_value : String?
    var model :String?
    var surge :Int?
    var wallet_balance : Float?
    var useWallet : Int?
    var base_price : Float?
    var service_type : Int?
}


