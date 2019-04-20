//
//  Coupons.swift
//  User
//
//  Created by CSS on 04/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
struct Coupon : JSONSerializable {
   
    var promocode : String?
    
}

struct CouponWallet : JSONSerializable {
    
    var created_at : String?
    var amount : Float?
    var via : String?
    var status : String?
    var promocode : PromoCode?
}

struct PromoCode : JSONSerializable {
    
    var discount_type : String?
    var discount : Float?
    var promo_code : String?
    var status : String?
    
}

