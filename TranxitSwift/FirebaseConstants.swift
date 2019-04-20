//
//  FirebaseConstants.swift
//  ChatPOC
//
//  Created by CSS on 06/03/18.
//  Copyright © 2018 CSS. All rights reserved.
//

import Foundation

struct FirebaseConstants {
    
    static let main = FirebaseConstants()
    
    let dbBase = "BaseUrl"
    let storageBase = "storageBase"
    let reciever = "reciever"
    let timestamp = "timestamp"
    let sender = "sender"
    let read = "read"
    let type = "type"
    let text = "text"
    let url = "url"
    let number = "number"
    let groupId = "groupId"
    let user = "user"
    let readedMembers = "readedMembers"
    var senderType = "senderType"
    
}

// Message Status

enum MessageStatus : Int {
    
    case sent = 0
    case read = 1
}

// Mime Type For Attachments

enum Mime : String {
    
    case text = "text"
    case video = "video"
    case image = "image"
    case audio = "audio"
    
    var contentType : String {
        
        switch self {
        case .image:
            return "image/png"
        case .audio:
            return "audio/wav"
        default :
            return .Empty
        }
    }
    
    var ext : String {
        
        switch self {
        case .image:
            return ".png"
            
        case .audio :
            return ".wav"
            
        case .video:
            return ".mp4"
            
        default:
            return .Empty
        }
    }
}

enum UserType : String, Codable{
    case user
    case provider
}
