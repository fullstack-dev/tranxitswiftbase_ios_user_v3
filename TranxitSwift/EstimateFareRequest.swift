//
//  EstimateFare.swift
//  User
//
//  Created by CSS on 31/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct EstimateFareRequest : JSONSerializable {
    
    var s_latitude : Double?
    var s_longitude : Double?
    var d_latitude : Double?
    var d_longitude : Double?
    var service_type : Int?
}

