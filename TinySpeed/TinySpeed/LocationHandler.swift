//
//  Location.swift
//  Simple GPS Speedometer
//
//  Created by Antti Vekkeli on 30/09/2017.
//  Copyright © 2017 Antti Vekkeli. All rights reserved.
//

import UIKit
import CoreLocation

class LocationHandler: NSObject, CLLocationManagerDelegate {
    
    private var locationManager: CLLocationManager!
    private(set) var lastLocation: CLLocation?
    
    public var didUpdate: ((LocationHandler) -> ())?
    
    public var speedKmh: Int {
        let speed = lastLocation?.speed ?? 0
        return max(Int((speed * 3600.0) / 1000.0), 0)
    }
    
    public var speedMph: Int {
        let speed = lastLocation?.speed ?? 0
        return max(Int((speed * 3600.0) / 1609.34), 0)
    }
    
    public var accuracyMeters: Int? {
        if let lastLocation = lastLocation {
            return Int(max(lastLocation.horizontalAccuracy, lastLocation.verticalAccuracy))
        }
        return nil
    }
    
    func setup() {
        
        if (locationManager == nil) {
            locationManager = CLLocationManager()
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyBest
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func start() {
        if CLLocationManager.locationServicesEnabled() {
            locationManager.startUpdatingLocation()
        }
    }
    
    func stop() {
        locationManager.stopUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            lastLocation = location
            
            didUpdate?(self)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error)
    {
        print("Error \(error)")
    }
}
