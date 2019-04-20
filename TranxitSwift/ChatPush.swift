//
//  ChatPush.swift
//  User
//
//  Created by CSS on 31/08/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct ChatPush : JSONSerializable {
    var sender : UserType?
    var user_id : Int?
    var message : String?
    var device_type : DeviceType?
    var version : String?
    var force_update : Bool?
    var url : String?
}
