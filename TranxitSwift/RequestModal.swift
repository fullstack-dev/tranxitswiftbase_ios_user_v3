//
//  RequestModal.swift
//  User
//
//  Created by CSS on 07/09/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct RequestModal : JSONSerializable {
    var data : [Request]?
    var cash : Int?
    var card : Int?
    var payumoney : Int?
    var paypal : Int?
    var paypal_adaptive : Int?
    var braintree : Int?
    var paytm : Int?

}
