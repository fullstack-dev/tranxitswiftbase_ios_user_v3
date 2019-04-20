//
//  Work+CoreDataProperties.swift
//  
//
//  Created by CSS on 07/06/18.
//
//

import Foundation
import CoreData


extension Work {

    @nonobjc public class func fetch() -> NSFetchRequest<Work> {
        return NSFetchRequest<Work>(entityName: "Work")
    }

    @NSManaged public var address: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double

}
