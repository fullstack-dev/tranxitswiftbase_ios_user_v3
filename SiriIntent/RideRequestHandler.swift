//
//  RideRequestHandler.swift
//  SiriIntent
//
//  Created by CSS on 16/06/18.
//  Copyright © 2018 CSS. All rights reserved.
//

import Intents
import UIKit

class RideRequestHandler: NSObject, INRequestRideIntentHandling {
    
    //var urlSession : URLSession?
    
    
    func resolvePartySize(for intent: INRequestRideIntent, with completion: @escaping (INIntegerResolutionResult) -> Void) {
      
        switch intent.partySize {
        case .none :
            completion(.needsValue())
        case let .some(val) where val < 5:
            completion(.success(with : val))
        default:
            completion(.unsupported())
        }

    }
    
    func handle(intent: INRequestRideIntent, completion: @escaping (INRequestRideIntentResponse) -> Void) {
        
        let code : INRequestRideIntentResponseCode
        
        guard let _ = intent.pickupLocation?.location else {
            code = .failureRequiringAppLaunch
            completion(INRequestRideIntentResponse(code: code, userActivity: .none))
            return
        }
        
        guard let _ = intent.dropOffLocation?.location else {
            code = .failureRequiringAppLaunch
            completion(INRequestRideIntentResponse(code: code, userActivity: .none))
            return
        }
        
        
       /* let request = Request()
        request.d_address =  self.destinationLocationDetail?.address
        request.d_latitude = self.destinationLocationDetail?.coordinate.latitude
        request.d_longitude = self.destinationLocationDetail?.coordinate.longitude
        request.s_address = self.sourceLocationDetail?.value?.address
        request.s_latitude = self.sourceLocationDetail?.value?.coordinate.latitude
        request.s_longitude = self.sourceLocationDetail?.value?.coordinate.longitude
        request.service_type = self.service?.id
        request.payment_mode = .CASH
        request.distance = "\(fare.distance ?? 0)"
        request.use_wallet = fare.useWallet
        
        if isScheduled {
            if let dateString = Formatter.shared.getString(from: scheduleDate, format: DateFormat.list.ddMMyyyyhhmma) {
                
                let dateArray = dateString.components(separatedBy: "")
                request.schedule_date = dateArray.first
                request.schedule_time = dateArray.last
            }
        } */
        
        
        
        //let dropOff = intent.dropOffLocation?.location ?? pickUpLocation
        
        let status = INRideStatus()
        status.rideIdentifier = "Ide"
        status.driver = INRideDriver(phoneNumber: "9585290750", nameComponents: nil, displayName: "Jeff", image:  #imageLiteral(resourceName: "userPlaceholder").inImage, rating: "2")
        status.pickupLocation = intent.pickupLocation
        status.dropOffLocation = intent.dropOffLocation
        status.phase = .confirmed
        status.estimatedPickupDate = Date()
        
        let response = INRequestRideIntentResponse(code: .success , userActivity: .none)
        response.rideStatus = status
        completion(response)
        
    }
    
    func confirm(intent: INRequestRideIntent, completion: @escaping (INRequestRideIntentResponse) -> Void) {
        
//        urlSession = URLSession.shared
//
//        let data = UserDefaults(suiteName: Keys.list.appGroup)?.bool(forKey: Keys.list.isLoggedIn)
//        let val = "\(data == nil ? "failed" : "\(data!)")"
//        urlSession?.dataTask(with: URL(string: "http://schedule.deliveryventure.com/api/user/checkapi?test="+val)!, completionHandler: { (_, _, _) in
//
//        }).resume()
//
        let responseCode : INRequestRideIntentResponseCode
        if !(UserDefaults(suiteName: Keys.list.appGroup)?.bool(forKey: Keys.list.isLoggedIn) ?? false) {
            responseCode = .failureRequiringAppLaunchMustVerifyCredentials
        }else if (intent.pickupLocation?.location) != nil {
            responseCode = .ready
        }else {
            responseCode = .failureRequiringAppLaunchNoServiceInArea
        }
        completion(INRequestRideIntentResponse(code: responseCode, userActivity: nil))
        
    }
    
    
    func resolvePickupLocation(for intent: INRequestRideIntent, with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
        
        if let pickUp = intent.pickupLocation {
            completion(.success(with: pickUp))
        } else {
            completion(.needsValue())
        }
    }
    
    func resolveDropOffLocation(for intent: INRequestRideIntent, with completion: @escaping (INPlacemarkResolutionResult) -> Void) {
        if let drop = intent.dropOffLocation {
            completion(.success(with: drop))
        } else {
            completion(.needsValue())
        }
    }

    func resolveScheduledPickupTime(for intent: INRequestRideIntent, with completion: @escaping (INDateComponentsRangeResolutionResult) -> Void) {
        let dateNow = Date(timeInterval: -30, since: Date())
        if let date = intent.scheduledPickupTime, let dateObject = date.startDateComponents?.date, dateNow<=dateObject {
            completion(.success(with: date))
        } else {
            completion(.needsValue())
        }
    }
    

}


extension RideRequestHandler {
 
}
