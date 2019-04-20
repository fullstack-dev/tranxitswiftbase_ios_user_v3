//
//  UserBase.swift
//  User
//
//  Created by CSS on 29/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

protocol UserBase : JSONSerializable {
    
    var id : Int? { get }
    var first_name : String? { get }
    var last_name : String? { get }
    var email : String? { get }
    //var mobile : Int? { get }
}

