//
//  LocationEntity.swift
//  TranxitUser
//
//  Created by Ansar on 14/12/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct LocationEntity : JSONSerializable {
    var name : String?
    var address : String?
    var latitude : Double?
    var longitude : Double?
}

struct LocationList: JSONSerializable {
    var location_list : [LocationEntity]?
}
