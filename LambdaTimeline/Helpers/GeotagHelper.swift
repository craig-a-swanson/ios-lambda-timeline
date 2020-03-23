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
            checkLocationAuthorization()
        } else {
            print("Location services is turned off")
            // show alert letting the user know that have to turn it on
        }
    }
    
    private func centerViewOnUserLocation() {
        if let location = geoLocationManager.location?.coordinate {
            let region = MKCoordinateRegion.init(center: location, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
        }
    }
    
    private func checkLocationAuthorization() {
        switch CLLocationManager.authorizationStatus() {
        case .authorizedWhenInUse:
//            mapView.showsUserLocation = true
            centerViewOnUserLocation()
            geoLocationManager.startUpdatingLocation()
            break
        case .denied:
            break
        case .notDetermined:
            geoLocationManager.requestWhenInUseAuthorization()
        case .restricted:
            break
        case .authorizedAlways:
            break
        @unknown default:
            preconditionFailure("Future Apple case not covered by app")
        }
    }
}

extension geotagHelper: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        let center = CLLocationCoordinate2D(latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
        let region = MKCoordinateRegion.init(center: center, latitudinalMeters: regionInMeters, longitudinalMeters: regionInMeters)
//        mapView.setRegion(region, animated: true)
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        checkLocationAuthorization()
    }
}
