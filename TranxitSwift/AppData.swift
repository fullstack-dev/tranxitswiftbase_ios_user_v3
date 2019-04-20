//
//  AppData.swift
//  User
//
//  Created by CSS on 10/01/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import UIKit

let AppName = "Tranxit"
var deviceTokenString = Constants.string.noDevice
let stripePublishableKey = "pk_test_DbfzA8Pv1MDErUiHakK9XfLe"
let googleMapKey = "AIzaSyCKTSqyNLap7VgehJft0j9amCn52i0u7tQ"
let appSecretKey = "yVnKClKDHPcDlqqO1V05RtDRdvtrVHfvjlfqliha"
let appClientId = 2
let passwordLengthMax = 10
let defaultMapLocation = LocationCoordinate(latitude: 13.009245, longitude: 80.212929)
let baseUrl = "http://schedule.deliveryventure.com/"

var supportNumber = "919585290750"
var supportEmail = "support@tranxit.com"
var offlineNumber = "57777"
let helpSubject = "\(AppName) Help"

let requestInterval : TimeInterval = 60
let requestCheckInterval : TimeInterval = 5
let driverBundleID = "com.appoets.tranxit.provider"

// AppStore URL

enum AppStoreUrl : String {
    
    case user = "https://itunes.apple.com/us/app/tranxit/id1204487551?ls=1&mt=8"
    case driver = "https://itunes.apple.com/us/app/tranxit-driver/id1204269279?mt=8"
    
}
