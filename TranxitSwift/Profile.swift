//
//  Profile.swift
//  User
//
//  Created by CSS on 07/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class Profile : JSONSerializable {
    
    var id : Int?
    var first_name : String?
    var last_name : String?
    var email : String?
    var mobile : String?
    var country_code: String?
    var picture : String?
    var device_token : String?
    var access_token : String?
    var currency : String?
    var wallet_balance : Float?
    var sos : String?
    var app_contact : String?
    var measurement : String?
    var language : Language?
    var stripe_secret_key : String?
    var stripe_publishable_key : String?
    var login_by:String?
    var referral_count : String?
    var referral_unique_id : String?
    var referral_total_text : String?
    var referral_text : String?
    var otp : Int?
    var ride_otp : Int?
    var cash : Bool?
    var card : Bool?
    var payumoney : Bool?
    var paypal : Bool?
    var braintree : Bool?
    var paytm : Bool?
    var qrcode_url: String?
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(Int.self, forKey: .id)
        first_name = try? values.decode(String.self, forKey: .first_name)
        last_name = try? values.decode(String.self, forKey: .last_name)
        email = try? values.decode(String.self, forKey: .email)
        picture = try? values.decode(String.self, forKey: .picture)
        device_token = try? values.decode(String.self, forKey: .device_token)
        access_token = try? values.decode(String.self, forKey: .access_token)
        country_code = try? values.decode(String.self, forKey: .country_code)
        currency = try? values.decode(String.self, forKey: .currency)
        sos = try? values.decode(String.self, forKey: .sos)
        wallet_balance = try? values.decode(Float.self, forKey: .wallet_balance)
        app_contact = try? values.decode(String.self, forKey: .app_contact)
        measurement = try? values.decode(String.self, forKey: .measurement)
        if let mobileInt = try? values.decode(Int.self, forKey: .mobile) {
            mobile = "\(mobileInt)"
        } else {
            mobile = try? values.decode(String.self, forKey: .mobile)
        }
        language = try? values.decode(Language.self, forKey: .language)
        stripe_secret_key = try? values.decode(String.self, forKey: .stripe_secret_key)
        stripe_publishable_key = try? values.decode(String.self, forKey: .stripe_publishable_key)
        login_by = try? values.decode(String.self, forKey: .login_by)
        
        referral_count = try? values.decode(String.self, forKey: .referral_count)
        referral_unique_id = try? values.decode(String.self, forKey: .referral_unique_id)
        referral_total_text = try? values.decode(String.self, forKey: .referral_total_text)
        referral_text = try? values.decode(String.self, forKey: .referral_text)
        otp = try? values.decode(Int.self, forKey: .otp)
        ride_otp = try? values.decode(Int.self, forKey: .ride_otp)
        cash = try? values.decode(Bool.self, forKey: .cash)
        card = try? values.decode(Bool.self, forKey: .card)
        paytm = try? values.decode(Bool.self, forKey: .paytm)
        payumoney = try? values.decode(Bool.self, forKey: .payumoney)
        paypal = try? values.decode(Bool.self, forKey: .paypal)
        braintree = try? values.decode(Bool.self, forKey: .braintree)
        qrcode_url = try? values.decode(String.self, forKey: .qrcode_url)
    }
    
    init() {
    }
}

