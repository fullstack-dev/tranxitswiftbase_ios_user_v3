//
//  UserData.swift
//  User
//
//  Created by CSS on 07/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class UserData : UserBase {
    
    var id : Int?
    var first_name : String?
    var last_name : String?
    var email : String?
    var mobile : Int?
    var accessToken : String?

    var device_type : DeviceType?
    var device_token : String?
    var login_by : LoginType?
    var password : String?
    var old_password : String?
    var password_confirmation : String?
    var social_unique_id : String?
    var device_id : String?
    var otp : Int?
    var measurement : String?
    var referral_code:String?
    var country_code: String?
}

class ForgotResponse : JSONSerializable {
    
    var user : UserDataResponse?
}

class UserDataResponse : JSONSerializable {
    
    var id : Int?
    var email : String?
    var device_type : DeviceType?
    var device_token : String?
    var login_by : LoginType?
    var password : String?
    var old_password : String?
    var password_confirmation : String?
    var social_unique_id : String?
    var device_id : String?
    var otp : Int?
    
}


