//
//  ReasonEntity.swift
//  TranxitUser
//
//  Created by Ansar on 27/12/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct ReasonEntity : JSONSerializable {
    
//    var reasonList : [Reason]?
    var id : Int?
    var reason : String?
    var status : Int?
    var type : String?
}

struct Reason: JSONSerializable {
    
    var id : Int?
    var reason : String?
    var status : Int?
    var type : String?
}
