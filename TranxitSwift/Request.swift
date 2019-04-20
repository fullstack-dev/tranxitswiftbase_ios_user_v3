//
//  Request.swift
//  User
//
//  Created by CSS on 31/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class Request : JSONSerializable {
    
    var s_latitude : Double?
    var s_longitude : Double?
    var d_latitude : Double?
    var d_longitude : Double?
    var service_type : Int?
    var distance : String?
    var distanceInt : Float?
    var amount : String?
    var payment_mode : PaymentType?
    var card_id : String?
    var s_address : String?
    var d_address : String?
    var use_wallet : Int?
    var schedule_date : String?
    var schedule_time : String?
    var request_id : Int?
    var current_provider : Int?
    var id : Int?
    var booking_id : String?
    var travel_time : String?
    var status : RideStatus?
    var provider : Provider?
    var service : Service?
    var provider_service : Service?
    var payment : Payment?
    var otp : String?
    var assigned_at : String?
    var schedule_at : String?
    var static_map : String?
    var surge : Int?
    var rating : Rating?
    var message : String?
    var paid : Int?
    var cancel_reason : String?
    var latitude : Double?
    var longitude : Double?
    var address : String?
    var tips : Float?
    var promocode_id : Int?
    var unit : String?
    var is_scheduled : Bool?
    var is_dispute : Int?
    var dispute : Dispute?
    var lostitem : Lostitem?
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(Int.self, forKey: .id)
        status = try? values.decode(RideStatus.self, forKey: .status)
        booking_id = try? values.decode(String.self, forKey: .booking_id)
        s_address = try? values.decode(String.self, forKey: .s_address)
        s_latitude = try? values.decode(Double.self, forKey: .s_latitude)
        s_longitude = try? values.decode(Double.self, forKey: .s_longitude)
        d_address = try? values.decode(String.self, forKey: .d_address)
        d_latitude = try? values.decode(Double.self, forKey: .d_latitude)
        d_longitude = try? values.decode(Double.self, forKey: .d_longitude)
        use_wallet = try? values.decode(Int.self, forKey: .use_wallet)
        provider = try? values.decode(Provider.self, forKey: .provider)
        distance = try? values.decode(String.self, forKey: .distance)
        distanceInt = try? values.decode(Float.self, forKey: .distance)
        service = try? values.decode(Service.self, forKey: .service_type)
        service_type =  try? values.decode(Int.self, forKey: .service_type)
        schedule_date = try? values.decode(String.self, forKey: .schedule_date)
        schedule_time = try? values.decode(String.self, forKey: .schedule_time)
        request_id = try? values.decode(Int.self, forKey: .request_id)
        current_provider = try? values.decode(Int.self, forKey: .current_provider)
        status = try? values.decode(RideStatus.self, forKey: .status)
        provider_service = try? values.decode(Service.self, forKey: .provider_service)
        payment = try? values.decode(Payment.self, forKey: .payment)
        travel_time = try? values.decode(String.self, forKey: .travel_time)
        payment_mode = try? values.decode(PaymentType.self, forKey: .payment_mode)
        otp = try? values.decode(String.self, forKey: .otp)
        assigned_at = try? values.decode(String.self, forKey: .assigned_at)
        schedule_at = try? values.decode(String.self, forKey: .schedule_at)
        static_map = try? values.decode(String.self, forKey: .static_map)
        surge = try? values.decode(Int.self, forKey: .surge)
        rating = try? values.decode(Rating.self, forKey: .rating)
        message = try? values.decode(String.self, forKey: .message)
        paid = try? values.decode(Int.self, forKey: .paid)
        unit = try? values.decode(String.self, forKey: .unit)
        is_scheduled = (try? values.decode(String.self, forKey: .is_scheduled) == "YES")
        is_dispute = try? values.decode(Int.self, forKey: .is_dispute)
        dispute = try? values.decode(Dispute.self, forKey: .dispute)
        lostitem = try? values.decode(Lostitem.self, forKey: .lostitem)
    }
    
    init() {   }
}


class Dispute: JSONSerializable {
    var comments : String?
    var dispute_name : String?
    var dispute_type : String?
    var id : Int?
    var is_admin : Int?
    var refund_amount : Int?
    var status : String?
    var user_id : Int?
    var provider_id : Int?
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(Int.self, forKey: .id)
        comments = try? values.decode(String.self, forKey: .comments)
        dispute_name = try? values.decode(String.self, forKey: .dispute_name)
        dispute_type = try? values.decode(String.self, forKey: .dispute_type)
        is_admin = try? values.decode(Int.self, forKey: .is_admin)
        refund_amount = try? values.decode(Int.self, forKey: .refund_amount)
        status = try? values.decode(String.self, forKey: .status)
        user_id = try? values.decode(Int.self, forKey: .user_id)
        provider_id = try? values.decode(Int.self, forKey: .provider_id)
    }
    
    init() {   }
}

class Lostitem: JSONSerializable {
    var comments : String?
    var comments_by : String?
    var is_admin : Int?
    var id : Int?
    var lost_item_name : String?
    var parent_id : Int?
    var status : String?
    var user_id : Int?
    var provider_id : Int?
    
    required init(from decoder: Decoder) throws {
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        id = try? values.decode(Int.self, forKey: .id)
        comments = try? values.decode(String.self, forKey: .comments)
        is_admin = try? values.decode(Int.self, forKey: .is_admin)
        lost_item_name = try? values.decode(String.self, forKey: .lost_item_name)
        is_admin = try? values.decode(Int.self, forKey: .is_admin)
        parent_id = try? values.decode(Int.self, forKey: .parent_id)
        status = try? values.decode(String.self, forKey: .status)
        user_id = try? values.decode(Int.self, forKey: .user_id)
        provider_id = try? values.decode(Int.self, forKey: .provider_id)
    }
    
    init() {   }
}
