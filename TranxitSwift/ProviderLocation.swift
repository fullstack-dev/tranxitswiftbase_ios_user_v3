//
//  ProviderLocation.swift
//  TranxitUser
//
//  Created by Ansar on 23/01/19.
//  Copyright © 2019 Appoets. All rights reserved.
//

import Foundation
import Firebase

class ProviderLocation {
    
    var lat: Double?
    var lng: Double?
    var bearing: Double?
    
    init?(from snapshot: DataSnapshot) {
        
        let snapshotValue = snapshot.value as? [String: Any] //check both double and string sometime android return string
        
        var longDouble = 0.0
        var latDouble = 0.0
        var bearingDouble = 0.0
        
        if let latitude = snapshotValue?["lat"] as? Double {
            latDouble = Double(latitude)
        }else{
            let strLat = snapshotValue?["lat"]
            latDouble = Double("\(strLat ?? 0.0)")!
        }
        if let longitude = snapshotValue?["lng"] as? Double {
            longDouble = Double(longitude)
        }else{
            let strLong = snapshotValue?["lng"]
            longDouble = Double("\(strLong ?? 0.0)")!
        }
        if let bearing = snapshotValue?["bearing"] as? Double {
            bearingDouble = bearing
        }
        
        self.lat = latDouble
        self.lng = longDouble
        self.bearing = bearingDouble
       
    }
    
}
