//
//  PostDetailView.swift
//  PostDetailView
//
//  Created by Vikash Anand on 21/07/21.
//

import SwiftUI
import CoreLocation

struct PostDetailView: View {
    var post: Post
    let locationManager = LocationManager()
    @State private var currentLocation = CLLocationCoordinate2D()

    var body: some View {
        ZStack {
            MapView(coordinate: currentLocation)
                .edgesIgnoringSafeArea(.all)
        }
        .onAppear(perform: {
            if #available(iOS 15.0, *) {
                Task { await getCurrentLocationAsync() }
            } else {
                getCurrentLocation()
            }
        })
        .navigationTitle(post.title)
        .navigationBarTitleDisplayMode(.inline)
    }

    @available(iOS 15.0, *)
    func getCurrentLocationAsync() async {
        do {
            let locationCoordinate = try await locationManager.requestLocation()
            self.currentLocation.latitude = locationCoordinate?.latitude ?? 0
            self.currentLocation.longitude = locationCoordinate?.longitude ?? 0
        } catch (let error) {
            print(error.localizedDescription)
        }
    }

    func getCurrentLocation() {
        locationManager.requestLocation()
        locationManager.updateLocationCallBack = { (locationCoordinate, error) in
            if let error = error {
                print(error.localizedDescription)
            } else {
                self.currentLocation.latitude = locationCoordinate?.latitude ?? 0
                self.currentLocation.longitude = locationCoordinate?.longitude ?? 0
            }
        }
    }
}

struct PostDetailView_Previews: PreviewProvider {
    static var previews: some View {
        PostDetailView.init(post: Post.init(id: "1", title: "Title"))
    }
}
