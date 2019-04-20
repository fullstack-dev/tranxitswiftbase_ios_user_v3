//
//  Payment.swift
//  User
//
//  Created by CSS on 01/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct Payment : JSONSerializable {
    
    let id : Int?
    let request_id : Int?
    let promocode_id : Int?
    let payment_id : String?
    let payment_mode : String?
    let fixed : Float?
    let distance : Float?
    let commision : Float?
    let discount : Float?
    let tax : Float?
    let wallet : Float?
    let surge : Float?
    let total : Float?
    let payable : Float?
    let provider_commission : Float?
    let provider_pay : Float?
    let minute : Float?
    let hour : Float?
    let tips : Float?
    let waiting_amount : Float?
    let toll_charge : Float?
    let round_of : Float?
    let waiting_min_charge : Float?
}


