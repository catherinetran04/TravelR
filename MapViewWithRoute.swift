//
//  MapViewWithRoute.swift
//  Traveler
//
//  Created by Catherine Tran on 11/16/24.
//

//
//  MapViewWithRoute.swift
//  Traveler
//
//  Created by Catherine Tran on 11/16/24.
//

import SwiftUI
import MapKit

struct MapViewWithRoute: UIViewRepresentable {
    let region: MKCoordinateRegion
    let route: MKRoute?

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(region, animated: true)
        mapView.showsUserLocation = true
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays) // Remove existing overlays
        if let route = route {
            uiView.addOverlay(route.polyline) // Add route polyline
            uiView.setVisibleMapRect(route.polyline.boundingMapRect, animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 4
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
