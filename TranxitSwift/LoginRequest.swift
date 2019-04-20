//
//  LoginRequest.swift
//  User
//
//  Created by CSS on 07/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct  LoginRequest : JSONSerializable{

    var grant_type : String?
    var username : String?
    var password : String?
    var client_id : Int?
    var client_secret : String?
    var access_token : String?
    var refresh_token : String?
    var device_token : String?
    var device_id : String?
    var device_type : DeviceType?
}
