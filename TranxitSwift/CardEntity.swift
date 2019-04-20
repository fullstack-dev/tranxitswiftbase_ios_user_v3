//
//  CardEntity.swift
//  User
//
//  Created by CSS on 23/07/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct CardEntity : JSONSerializable {
    var id : Int?
    var last_four : String?
    var card_id : String?
    var is_default : Int?
    var stripe_token : String?
    var _method : String?
    var strCardID : String?
    var amount : String?
    var user_type: String?
    var payment_mode: String?
}


struct AddMoneyEntity : JSONSerializable {
    var amount : String?
    var type : String?
    var payment_mode : String?
}

