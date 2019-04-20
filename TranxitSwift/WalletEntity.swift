//
//  WalletEntity.swift
//  User
//
//  Created by CSS on 02/08/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class WalletEntity : JSONSerializable {
    var message : String?
    var balance : Float?
    var wallet_balance : Float?
    var wallet_transation : [WalletTransaction]?
}

struct WalletTransaction : JSONSerializable {
    var amount : Float?
    var close_balance : Float?
    var transaction_alias : String?
    var created_at : String?
    var transaction_desc : String?
}


struct PayTmEntity : JSONSerializable {
    //Paytm entity
    var MID : String?
    var ORDER_ID : String?
    var CUST_ID : String?
    var INDUSTRY_TYPE_ID : String?
    var CHANNEL_ID : String?
    var TXN_AMOUNT : Double?
    var WEBSITE : String?
    var CALLBACK_URL : String?
    var MOBILE_NO : String?
    var EMAIL : String?
    var CHECKSUMHASH : String?

}

// Mark : payumoney entity

struct PayUMoneyEntity : JSONSerializable {
    var key : String?
    var txnid : String?
    var amount : Double?
    var productinfo : String?
    var firstname : String?
    var email : String?
    var phone : String?
    var surl : String?
    var curl : String?
    var service_provider : String?
    var merchant_id : String?
    var payu_salt : String?
    var hash_string : String?
    var hash : String?
    var udf1 : Int?
    
    var request_id : Int?
    var isWallet : Int?
    var type : String?
    var userId : Int?
}

