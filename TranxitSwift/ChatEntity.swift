//
//  ChatEntity.swift
//  ChatPOC
//
//  Created by CSS on 06/03/18.
//  Copyright © 2018 CSS. All rights reserved.
//

import Foundation

class ChatEntity : JSONSerializable {
    
    var user : Int?
    var sender : String?
    var text : String?
    var url : String?
    var timestamp : Int?
    var type : String?
    var read : Int?
    var number : String?
    var groupId : Int?
    var readedMembers : [Int]?
//  var senderType : String?
    var userId : Int?
    var driverId : Int?
}
