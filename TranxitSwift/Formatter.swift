//
//  Formatter.swift
//  User
//
//  Created by CSS on 02/02/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation

class Formatter {
    
    static let shared = Formatter()
    private var dateFormatter : DateFormatter?
    private var numberFormatter : NumberFormatter?
    
    // Initializing the Date formatter for the First Time
    private func initializeDateFormatter(){
        
        if self.dateFormatter == nil {
            dateFormatter = DateFormatter()
        }
    }

    // Getting String for Date with required format
    
    func getString(from date : Date?, format : String)->String?{
        
        initializeDateFormatter()
        dateFormatter?.locale = Locale(identifier: selectedLanguage.code)
        dateFormatter?.dateFormat = format
        return date == nil ? nil : dateFormatter?.string(from: date!)
    }
    
    // Getting Date from String Format
    
    func getDate(from string : String?, format : String)->Date?{
        
        initializeDateFormatter()
        dateFormatter?.dateFormat = format
        return string == nil ? nil : dateFormatter?.date(from: string!)
    }
    
    //MARK:- Initilizing Number Formatter
    
    private func initializeNumberFormatter(){
        
        if numberFormatter == nil {
            self.numberFormatter = NumberFormatter()
        }
    }
    
    // MARK:- Limit number to required Decimal Values
    
    func limit(string number : String?, maximumDecimal limit : Int)->String{
        
        //initializeNumberFormatter()
        guard let float = Float(number ?? .Empty) else {
            return .Empty
        }
        return String(format: "%.\(limit)f", float)//numberFormatter?.string(for: NSNumber(value: float))
        
    }
    
    // Make Minimum digits
    
    func makeMinimum(number : NSNumber, digits : Int)->String {
        
        initializeNumberFormatter()
        numberFormatter!.minimumIntegerDigits = digits
        return numberFormatter!.string(from: number) ?? .Empty
    }
    
    //Remove Decimal values from Number
    
    func removeDecimal(from number : Double)->Int?{
        
        initializeNumberFormatter()
        numberFormatter?.numberStyle = .none
        return numberFormatter?.number(from: "\(round(number))") as? Int
    }
    
    // Date to String
    
    func relativePast(for date : Date?) -> String {
        
        guard let date = date else {
            return .Empty
        }
        
        let units = Set<Calendar.Component>([.year, .month, .day, .hour, .minute, .second, .weekOfYear])
        let components = Calendar.current.dateComponents(units, from: date, to: Date())
        
        if components.year! > 0 {
            return "\(components.year!) " + (components.year! > 1 ? "years ago" : "year ago")
            
        }
        else if components.month! > 0 {
            return "\(components.month!) " + (components.month! > 1 ? "months ago" : "month ago")
            
        }
        else if components.weekOfYear! > 0 {
            return "\(components.weekOfYear!) " + (components.weekOfYear! > 1 ? "weeks ago" : "week ago")
            
        }
        else if (components.day! > 0) {
            return (components.day! > 1 ? "\(components.day!) days ago" : "Yesterday")
            
        }
        else if components.hour! > 0 {
            return "\(components.hour!) " + (components.hour! > 1 ? "hours ago" : "hour ago")
            
        }
        else if components.minute! > 0 {
            return "\(components.minute!) " + (components.minute! > 1 ? "minutes ago" : "minute ago")
            
        }
        else {
            return "\(components.second!) " + (components.second! > 1 ? "seconds ago" : "second ago")
        }
    }
    
}
