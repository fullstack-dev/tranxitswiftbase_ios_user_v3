//
//  File.swift
//  TranxitUser
//
//  Created by on 12/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation

struct DisputeList : JSONSerializable {
    var dispute_type : String?
    var dispute_name : String?
    var lost_item_name : String?
    var comments : String?
    var request_id : Int?
    var user_id : Int?
    var provider_id : Int?
    var message : String?
}
