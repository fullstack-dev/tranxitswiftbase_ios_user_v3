//
//  Rating.swift
//  User
//
//  Created by CSS on 14/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct Rating : JSONSerializable {
    var id : Int?
    var user_comment : String?
    var user_rating : Int?
    var provider_comment : String?
    var provider_rating : Int?
}
