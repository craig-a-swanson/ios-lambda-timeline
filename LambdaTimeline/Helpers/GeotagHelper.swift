//
//  GeotagHelper.swift
//  LambdaTimeline
//
//  Created by Craig Swanson on 3/22/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation
import MapKit
import CoreLocation

class geotagHelper: NSObject {
    
    var geoLocationManager: CLLocationManager = CLLocationManager()
    private let regionInMeters: Double = 15000.0
    
    override init() {}
    
    private func setupLocationManager() {
        geoLocationManager.delegate = self
        geoLocationManager.desiredAccuracy = kCLLocationAccuracyBest
    }
    
    func currentUserLocation() -> CLLocationCoordinate2D {
        checkLocationServices()
        guard let currentLocation = geoLocationManager.location?.coordinate else { return CLLocationCoordinate2D() }
        return currentLocation
    }
    private func checkLocationServices() {
        if CLLocationManager.locationServicesEnabled() {
            // setup our location manager
            setupLocationManager()
            geoLocationManager.requestWhenInUseAuthorization()
        } else {
            print("Location services is turned off")
            // show alert letting the user know that have to turn it on
        }
    }
}

extension geotagHelper: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
    }
}
