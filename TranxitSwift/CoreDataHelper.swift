//
//  CoreDataHelper.swift
//  User
//
//  Created by CSS on 07/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
import CoreData

enum CoreDataEntity : String {
    
    case work = "Work"
    case home = "Home"
    case other = "Others"
    
}

class CoreDataHelper : NSObject {
    
    var workObject : Work?
    var homeObject : Home?
    
    var context:NSManagedObjectContext = {
        return AppDelegate.shared.persistentContainer.viewContext
    }()
    
    // MARK:- Insert in Core Data
    
    func insert(data : LocationDetail, entityName entity : CoreDataEntity) {
      
        self.deleteData(from: entity.rawValue)
        let entityObject = NSEntityDescription.insertNewObject(forEntityName:  entity.rawValue, into: context)
        switch entity {
            
            case .work:
                let entityValue = entityObject as?  Work
                entityValue?.address = data.address
                entityValue?.latitude = data.coordinate.latitude
                entityValue?.longitude = data.coordinate.longitude
            case .home:
                let entityValue = entityObject as?  Home
                entityValue?.address = data.address
                entityValue?.latitude = data.coordinate.latitude
                entityValue?.longitude = data.coordinate.longitude
            default : break
        }
        self.save()
    }
    
    // MARK:- Save in Core Data
    
    private func save() {
        
        do {
            try self.context.save()
        } catch let err {
            print("Error in Saving Core Data ",err.localizedDescription)
        }
    }
    
    // MARK:- Retrieve in Core Data
    
    func favouriteLocations()->([String : NSManagedObject]) {
        
        var returnObject = [String : NSManagedObject]()
        do {
            
            let workFetch =  Work.fetch()
            let homeFetch = Home.fetch()
            workFetch.returnsObjectsAsFaults = false
            homeFetch.returnsObjectsAsFaults = false
            
            let workArray : [Work] = try self.context.fetch(workFetch)
            let homeArray : [Home] = try self.context.fetch(homeFetch)
            
            if let workObject = workArray.first {
                returnObject.updateValue(workObject, forKey: CoreDataEntity.work.rawValue)
            }
            if let homeObject = homeArray.first {
                returnObject.updateValue(homeObject, forKey: CoreDataEntity.home.rawValue)
            }
            return returnObject
        }
        catch let err {
            
            print("Fetch Error  ", err.localizedDescription)
            return returnObject
        }
    }
    
    // MARK:- Clear Data in Core Data
    
    func deleteData(from entity : String) {
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entity)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        
        do {
            try self.context.execute(deleteRequest)
            self.save()
        } catch let err {
            print("Core Data Delete Err ", err.localizedDescription)
        }
    }
}
