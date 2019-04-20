//
//  GMSMapView.swift
//  User
//
//  Created by CSS on 17/02/18.
//  Copyright © 2018 Appoets. All rights reserved.
//

import GoogleMaps

private struct MapPath : Decodable{
    
    var routes : [Route]?
}

private struct Route : Decodable{
    
    var overview_polyline : OverView?
    var legs : [LegsObject]?
}

private struct OverView : Decodable {
    
    var points : String?
}

private struct LegsObject : Decodable {
    var duration : DurationObject?
}

private struct DurationObject : Decodable {
    var text : String?
}

extension GMSMapView {
    
    //MARK:- Call API for polygon points
    
    func drawPolygon(from source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D){
        self.getGoogleResponse(between: source, to: destination) { (mapPath) in
            if let points = mapPath.routes?.first?.overview_polyline?.points {
                
                self.drawPath(with: points)
                gmsPath = GMSPath.init(fromEncodedPath: points)!
            }
        }
    }
    
    // MARK;- Get estimation between coordinates
    
    func getEstimation(between source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion : @escaping((String)->Void)) {
        self.getGoogleResponse(between: source, to: destination) { (mapPath) in
            if let estimationString = mapPath.routes?.first?.legs?.first?.duration?.text {
                completion(estimationString)
            }
        }
    }
    
    // Get response Between Coordinates
    private func getGoogleResponse(between source: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D, completion : @escaping((MapPath)->Void)) {
        
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        
        guard let url = URL(string: "https://maps.googleapis.com/maps/api/directions/json?origin=\(source.latitude),\(source.longitude)&destination=\(destination.latitude),\(destination.longitude)&sensor=false&mode=driving&key=\(googleMapKey)") else {
            return
        }
        
        DispatchQueue.main.async {
            
            session.dataTask(with: url) { (data, response, error) in
                print("Inside Polyline ", data != nil)
                guard data != nil else {
                    return
                }
                
                do {
                    let parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                    print(parsedResult)

                    let mapPath = try JSONDecoder().decode(MapPath.self, from: data!)
                     completion(mapPath)
                    print("Routes === \(mapPath.routes!)")
                    print(mapPath.routes?.first?.overview_polyline?.points as Any)
                } catch let error {
                    
                    print("Failed to draw ",error.localizedDescription)
                }
                
                }.resume()
        }
    }
    
    //MARK:- Draw polygon
    
    private func drawPath(with points : String){
        
        print("Drawing Polyline ", points)
        
        DispatchQueue.main.async {
            
            guard let path = GMSPath(fromEncodedPath: points) else { return }
            let polyline = GMSPolyline(path: path)
            polyline.map = nil
            polyLinePath = polyline
            polyline.strokeWidth = 3.0
            polyline.strokeColor = .primary
            polyline.map = self
            var bounds = GMSCoordinateBounds()
            for index in 1...path.count() {
                bounds = bounds.includingCoordinate(path.coordinate(at: index))
            }
            self.animate(with: .fit(bounds))
        }
    }
}


