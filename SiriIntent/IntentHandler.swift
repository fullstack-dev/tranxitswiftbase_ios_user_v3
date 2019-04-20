//
//  IntentHandler.swift
//  SiriIntent
//
//  Created by CSS on 18/06/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Intents
import UIKit

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any? {
        
        if intent is INRequestRideIntent {
            return RideRequestHandler()
        }
        return .none
    }
    
}


public extension UIImage {
    public var inImage: INImage {
        return INImage(imageData: self.pngData()!)
    }
}
