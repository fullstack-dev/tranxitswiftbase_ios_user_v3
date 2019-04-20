//
//  GoogleMapsHelper.swift
//  User
//
//  Created by CSS on 09/05/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import Foundation
import GoogleMaps
import MapKit

typealias LocationCoordinate = CLLocationCoordinate2D
typealias LocationDetail = (address : String, coordinate :LocationCoordinate)

var drawpolylineCheck : (()->())?

private struct Place : Decodable {
    
    var results : [Address]?
}

private struct Address : Decodable {
    
    var formatted_address : String?
    var geometry : Geometry?
}

private struct Geometry : Decodable {
    
    var location : Location?
}

private struct Location : Decodable {
    
    var lat : Double?
    var lng : Double?
}



class GoogleMapsHelper : NSObject {
    
    var mapView : GMSMapView?
    var locationManager : CLLocationManager?
    private var currentLocation : ((CLLocation)->Void)?
    
    func getMapView(withDelegate delegate: GMSMapViewDelegate? = nil, in view : UIView, withPosition position :LocationCoordinate = defaultMapLocation, zoom : Float = 15) {
        
        mapView = GMSMapView(frame: view.frame)
        self.setMapStyle(to : mapView)
        mapView?.isMyLocationEnabled = true
        mapView?.delegate = delegate
        mapView?.camera = GMSCameraPosition.camera(withTarget: position, zoom: 15)
        view.addSubview(mapView!)
    }
    
    func getCurrentLocation(onReceivingLocation : @escaping ((CLLocation)->Void)){
        
        locationManager = CLLocationManager()
        locationManager?.desiredAccuracy = kCLLocationAccuracyBest
        locationManager?.requestAlwaysAuthorization()
        locationManager?.distanceFilter = 50
        locationManager?.startUpdatingLocation()
        locationManager?.delegate = self
        self.currentLocation = onReceivingLocation
    }
    
    func moveTo(location : LocationCoordinate = defaultMapLocation, with center : CGPoint) {
        
        CATransaction.begin()
        CATransaction.setValue(2, forKey: kCATransactionAnimationDuration)
        CATransaction.setCompletionBlock {
            self.mapView?.animate(to: GMSCameraPosition.camera(withTarget: location, zoom: 15))
        }
        CATransaction.commit()
        self.mapView?.center = center  //  Getting current location marker to center point
        
    }
    // Setting Map Style
    private func setMapStyle(to mapView: GMSMapView?){
        do {
            // Set the map style by passing a valid JSON string.
            if let url = Bundle.main.url(forResource: "Map_style", withExtension: "json") {
                mapView?.mapStyle = try GMSMapStyle(contentsOfFileURL: url)
            }else {
                print("error")
            }
            
        } catch {
            NSLog("One or more of the map styles failed to load. \(error)")
        }
    }
    func getPlaceAddress(from location : LocationCoordinate, on completion : @escaping ((LocationDetail)->())){
        
        /*if !geoCoder.isGeocoding {
         
         geoCoder.reverseGeocodeLocation(CLLocation(latitude: location.latitude, longitude: location.longitude)) { (placeMarks, error) in
         
         guard error == nil, let placeMarks = placeMarks else {
         print("Error in retrieving geocoding \(error?.localizedDescription ?? .Empty)")
         return
         }
         
         
         
         guard let placemark = placeMarks.first, let address = (placeMarks.first?.addressDictionary!["FormattedAddressLines"] as? Array<String>)?.joined(separator: ","), let coordinate = placemark.location else {
         print("Error on parsing geocoding ")
         return
         }
         
         
         completion((address,coordinate.coordinate))
         
         print(placeMarks)
         
         }
         
         } */
        
        
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(location.latitude),\(location.longitude)&key=\(googleMapKey)"
        
        guard let url = URL(string: urlString) else {
            print("Error in creating URL Geocoding")
            return
        }
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            if let places = data?.getDecodedObject(from: Place.self), let address = places.results?.first?.formatted_address, let lattitude = places.results?.first?.geometry?.location?.lat, let longitude = places.results?.first?.geometry?.location?.lng {
                
                completion((address, LocationCoordinate(latitude: lattitude, longitude: longitude)))
            }
            
            }.resume()
        
    }
}

extension GoogleMapsHelper: CLLocationManagerDelegate {
    
    // Handle incoming location events.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            print("Location: \(location)")
            self.currentLocation?(location)
            if polyLinePath.path != nil {
                self.checkPolyline(coordinate: location.coordinate)
            }
        }
    }
    
    // Handle authorization for the location manager.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted:
            print("Location access was restricted.")
        case .denied:
            print("User denied access to location.")
        case .notDetermined:
            print("Location status not determined.")
        case .authorizedAlways: fallthrough
        case .authorizedWhenInUse:
            print("Location status is OK.")
        }
    }
    
    // Handle location manager errors.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationManager?.stopUpdatingLocation()
        print("Error: \(error)")
    }
    
    func checkPolyline(coordinate: CLLocationCoordinate2D)  {
        if GMSGeometryIsLocationOnPathTolerance(coordinate, polyLinePath.path!, true, 100.0)
        {
            print("=== true")
            isRerouteEnable = false
        }
        else
        {
            isRerouteEnable = true
            print("=== false")
        }
    }
}
