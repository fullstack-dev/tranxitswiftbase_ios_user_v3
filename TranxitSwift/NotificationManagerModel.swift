//
//  NotificationManagerModel.swift
//  Provider
//
//  Created by Sravani on 11/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation

import Foundation
struct NotificationManagerModel : Codable {
    let id : Int?
    let notify_type : String?
    let image : String?
    let description : String?
    let expiry_date : String?
    let status : String?
    
    enum CodingKeys: String, CodingKey {
        
        case id = "id"
        case notify_type = "notify_type"
        case image = "image"
        case description = "description"
        case expiry_date = "expiry_date"
        case status = "status"
    }
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try values.decodeIfPresent(Int.self, forKey: .id)
        notify_type = try values.decodeIfPresent(String.self, forKey: .notify_type)
        image = try values.decodeIfPresent(String.self, forKey: .image)
        description = try values.decodeIfPresent(String.self, forKey: .description)
        expiry_date = try values.decodeIfPresent(String.self, forKey: .expiry_date)
        status = try values.decodeIfPresent(String.self, forKey: .status)
    }
    
}
