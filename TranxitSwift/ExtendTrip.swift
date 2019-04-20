//
//  ExtendTrip.swift
//  TranxitUser
//
//  Created by on 14/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation

struct ExtendTrip : JSONSerializable {
    var request_id : Int?
    var latitude : Double?
    var longitude : Double?
    var address:String?
}


struct TokenEntity : JSONSerializable {
    var token : String?
}
