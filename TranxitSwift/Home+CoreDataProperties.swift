//
//  Home+CoreDataProperties.swift
//  
//
//  Created by CSS on 07/06/18.
//
//

import Foundation
import CoreData


extension Home {

    @nonobjc public class func fetch() -> NSFetchRequest<Home> {
        return NSFetchRequest<Home>(entityName: "Home")
    }

    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}
