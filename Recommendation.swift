import SwiftUI
import MapKit

struct DetailView: View {
    let spot: VacationSpot
    @State private var region: MKCoordinateRegion
    @State private var route: MKRoute?
    @State private var currentLocation: CLLocationCoordinate2D?
    @State private var travelDistance: String = ""
    @State private var travelDistanceKm: String = ""
    @State private var travelTime: String = ""

    init(spot: VacationSpot) {
        self.spot = spot
        _region = State(initialValue: MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude),
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        ))
    }

    var body: some View {
        ScrollView {
            VStack {
                Text(spot.name)
                    .font(.largeTitle)
                    .padding()

                if let imageUrl = spot.imageUrl, let url = URL(string: imageUrl) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .empty:
                            ProgressView()
                        case .success(let image):
                            image
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 500) // Larger height for the image
                                .cornerRadius(10)
                                .padding()
                        case .failure:
                            Image(systemName: "photo")
                                .resizable()
                                .scaledToFit()
                                .frame(maxHeight: 300)
                                .padding()
                        @unknown default:
                            EmptyView()
                        }
                    }
                } else {
                    Text("No image available.")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                }

                // Add description under the image
                Text(spot.description)
                    .font(.body)
                    .foregroundColor(.secondary)
                    .padding([.leading, .trailing, .bottom])

                Text("Location:")
                    .font(.headline)
                    .padding(.top)

                MapViewWithRoute(region: region, route: route)
                    .frame(height: 300)
                    .cornerRadius(10)
                    .padding()

                if !travelDistance.isEmpty && !travelTime.isEmpty {
                    Text("Distance: \(travelDistance) (\(travelDistanceKm))")
                        .font(.subheadline)
                        .padding(.top, 5)

                    Text("Estimated Time: \(travelTime)")
                        .font(.subheadline)
                        .padding(.bottom, 5)
                }

                Button(action: openInMaps) {
                    Text("Open in Maps")
                        .font(.headline)
                        .foregroundColor(.blue)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .onAppear {
            getCurrentLocation()
            calculateRoute()
        }
        .navigationTitle("Details")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func getCurrentLocation() {
        let locationManager = CLLocationManager()
        if let location = locationManager.location {
            currentLocation = location.coordinate
        }
    }

    private func calculateRoute() {
        guard let currentLocation = currentLocation else { return }

        let sourcePlacemark = MKPlacemark(coordinate: currentLocation)
        let destinationPlacemark = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude))

        let directionRequest = MKDirections.Request()
        directionRequest.source = MKMapItem(placemark: sourcePlacemark)
        directionRequest.destination = MKMapItem(placemark: destinationPlacemark)
        directionRequest.transportType = .automobile

        let directions = MKDirections(request: directionRequest)
        directions.calculate { response, error in
            if let error = error {
                print("Error calculating directions: \(error.localizedDescription)")
                return
            }

            if let route = response?.routes.first {
                self.route = route
                self.region = MKCoordinateRegion(route.polyline.boundingMapRect)

                let distanceInMiles = route.distance / 1609.34
                let distanceInKilometers = route.distance / 1000

                self.travelDistance = String(format: "%.2f miles", distanceInMiles)
                self.travelDistanceKm = String(format: "%.2f km", distanceInKilometers)

                let timeInMinutes = route.expectedTravelTime / 60
                self.travelTime = String(format: "%.0f min", timeInMinutes)
            }
        }
    }

    private func openInMaps() {
        let destination = MKPlacemark(coordinate: CLLocationCoordinate2D(latitude: spot.latitude, longitude: spot.longitude))
        let mapItem = MKMapItem(placemark: destination)
        mapItem.name = spot.name
        mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
    }
}
