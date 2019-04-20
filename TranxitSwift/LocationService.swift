//
//  LocationService.swift
//  User
//
//  Created by CSS on 04/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct LocationService : JSONSerializable {
    
    var home : [Service]?
    var recent : [Service]?
    var work : [Service]?
    var others : [Service]?
}
