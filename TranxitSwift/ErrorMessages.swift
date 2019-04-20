//
//  ErrorMessages.swift
//  User
//
//  Created by CSS on 11/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

struct ErrorMessage {
    
    static let list = ErrorMessage()
    
    let serverError = "Server Could not be reached. \n Try Again"
    let notReachable = "The Internet connection appears to be offline."
    let enterEmail = "Enter Email Id"
    let enterValidEmail = "Enter Valid Email Id"
    let enterPassword = "Enter Password"
    let enterFirstName = "Enter FirstName"
    let enterLastName = "Enter LastName"
    let enterMobileNumber = "Enter Mobile Number"
    let enterCountry = "Enter Country"
    let enterTimezone = "Enter TimeZone"
    let enterConfirmPassword = "Enter Confirm Password"
    let passwordDonotMatch = "Password and Confirm password donot match"
}
