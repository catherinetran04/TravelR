//
//  MapView.swift
//  Traveler
//
//  Created by Catherine Tran on 11/15/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    @StateObject private var locationManager = LocationManager()
    
    var body: some View {
        ZStack {
            Color(.black)
                .ignoresSafeArea()
            
            Map(coordinateRegion: $locationManager.region, interactionModes: [.all], annotationItems: userLocationAnnotation) { location in
                MapAnnotation(coordinate: location.coordinate) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundColor(.blue)
                        .font(.largeTitle)
                        .shadow(radius: 10)
                }
            }
            .edgesIgnoringSafeArea(.top)
            .shadow(radius: 15)
            
            if locationManager.userLocation == nil {
                Text("Fetching your location...")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(8)
            }
        }
        .onAppear {
            locationManager.requestLocation()
        }
    }
    
    private var userLocationAnnotation: [UserLocation] {
        guard let coordinate = locationManager.userLocation else { return [] }
        return [UserLocation(coordinate: coordinate)]
    }
}

// Supporting struct for annotation
struct UserLocation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView()
    }
}
