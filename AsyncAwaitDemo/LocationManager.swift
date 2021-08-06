//
//  LocationManager.swift
//  LocationManager
//
//  Created by Vikash Anand on 21/07/21.
//

import CoreLocation
import CoreLocationUI

final class LocationManager: NSObject {

    private var locationFinder: LocationFinder?
    var updateLocationCallBack: ((CLLocationCoordinate2D?, Error?) -> Void)? {
        didSet {
            locationFinder?.updateLocationCallBack = updateLocationCallBack
        }
    }

    func requestLocation() {
        self.locationFinder = LocationFinder()
        locationFinder?.requestLocation()
    }

    @available(iOS 15.0, *)
    func requestLocation() async throws -> CLLocationCoordinate2D? {
        try await AsyncLocationFinder().requestLocation()
    }
}

@available(iOS 15.0, *)
final class AsyncLocationFinder: NSObject {

    let manager = CLLocationManager()
    var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Error>?
    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    @available(iOS 15.0, *)
    func requestLocation() async throws -> CLLocationCoordinate2D? {
        try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }
}

@available(iOS 15.0, *)
extension AsyncLocationFinder: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        self.locationContinuation?.resume(returning: locations.last?.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationContinuation?.resume(throwing: error)
    }
}


final class LocationFinder: NSObject {

    let manager = CLLocationManager()

    var updateLocationCallBack: ((CLLocationCoordinate2D?, Error?) -> Void)?
    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }
}

extension LocationFinder: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        updateLocationCallBack?(locations.first?.coordinate, nil)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        updateLocationCallBack?(nil, error)
    }
}
