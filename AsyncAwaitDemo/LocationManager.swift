//
//  LocationManager.swift
//  LocationManager
//
//  Created by Vikash Anand on 21/07/21.
//

import CoreLocation
import CoreLocationUI

final class LocationManager: NSObject {

    let manager = CLLocationManager()
    var locationContinuation: CheckedContinuation<CLLocationCoordinate2D?, Error>?
    var updateLocationCallBack: ((CLLocationCoordinate2D?, Error?) -> Void)?
    override init() {
        super.init()
        manager.delegate = self
    }

    func requestLocation() {
        manager.requestLocation()
    }

    func requestLocation() async throws -> CLLocationCoordinate2D? {
        try await withCheckedThrowingContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
        }
    }
}

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //updateLocationCallBack?(locations.first?.coordinate, nil)
        self.locationContinuation?.resume(returning: locations.last?.coordinate)
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        //updateLocationCallBack?(nil, error)
        self.locationContinuation?.resume(throwing: error)
    }
}
