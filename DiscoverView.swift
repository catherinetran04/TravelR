//
//  DiscoverView.swift
//  Traveler
//
//  Created by Catherine Tran on 11/15/24.
//

i//
//  DiscoverView.swift
//  Traveler
//
//  Created by Catherine Tran on 11/15/24.
//

import SwiftUI
import MapKit

struct VacationSpot: Identifiable {
    let id = UUID()
    let name: String
    let imageUrl: String? // Optional image URL
    let latitude: Double
    let longitude: Double
    let description: String
}

struct DiscoverView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var vacationSpots: [VacationSpot] = []
    @State private var isLoading = true
    @State private var errorMessage: String? = nil
    
    let googleAPIKey = "AIzaSyCKnLa8KCwK2MxsxYAak1GwgA6difWB5uI" // Replace with your actual Google API Key
    
    var body: some View {
        NavigationView {
            VStack {
                if locationManager.userLocation != nil {
                    Text("Recommended Vacation Spots Near You")
                        .font(.title)
                        .padding()
                    
                    if isLoading {
                        ProgressView("Fetching vacation spots...")
                            .padding()
                    } else if let errorMessage = errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        List(vacationSpots) { spot in
                            VStack(alignment: .leading) {
                                Text(spot.name)
                                    .font(.headline)
                                
                                if let imageUrl = spot.imageUrl, let url = URL(string: imageUrl) {
                                    AsyncImage(url: url) { phase in
                                        switch phase {
                                        case .empty:
                                            ProgressView()
                                        case .success(let image):
                                            image
                                                .resizable()
                                                .scaledToFill()
                                                .frame(height: 200)
                                                .clipped()
                                        case .failure:
                                            Image(systemName: "photo")
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 200)
                                        @unknown default:
                                            EmptyView()
                                        }
                                    }
                                } else {
                                    Text("No image available.")
                                        .foregroundColor(.gray)
                                        .italic()
                                }
                            }
                            .padding(.bottom)
                        }
                    }
                } else if let error = locationManager.error {
                    Text("Failed to get location: \(error.localizedDescription)")
                        .foregroundColor(.red)
                        .padding()
                } else {
                    Text("Fetching location...")
                        .padding()
                }
            }
            .onAppear {
                fetchVacationSpots()
            }
            .navigationTitle("Discover")
        }
    }
    
    func fetchVacationSpots() {
        guard let userLocation = locationManager.userLocation else { return }
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "Tourist attractions"
        request.region = MKCoordinateRegion(
            center: userLocation,
            span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
        )
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.errorMessage = "Error searching for nearby places: \(error.localizedDescription)"
                    self.isLoading = false
                }
                return
            }
            
            guard let mapItems = response?.mapItems else { return }
            
            let group = DispatchGroup()
            var fetchedSpots: [VacationSpot] = []
            
            for item in mapItems {
                group.enter()
                fetchImageForPlace(placeName: item.name ?? "Unknown Place") { imageUrl in
                    let spot = VacationSpot(
                        name: item.name ?? "Unknown Place",
                        imageUrl: imageUrl,
                        latitude: item.placemark.coordinate.latitude,
                        longitude: item.placemark.coordinate.longitude,
                        description: item.placemark.title ?? "No description available."
                    )
                    fetchedSpots.append(spot)
                    group.leave()
                }
            }
            
            group.notify(queue: .main) {
                self.vacationSpots = fetchedSpots
                self.isLoading = false
            }
        }
    }
    
    func fetchImageForPlace(placeName: String, completion: @escaping (String) -> Void) {
        let urlString = "https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=\(placeName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")&inputtype=textquery&fields=photos&key=\(googleAPIKey)"
        
        guard let url = URL(string: urlString) else {
            completion("https://example.com/default.jpg") // Default placeholder
            return
        }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                completion("https://example.com/default.jpg") // Default placeholder
                return
            }
            
            do {
                let result = try JSONDecoder().decode(GooglePlaceImageResponse.self, from: data)
                if let photoReference = result.candidates.first?.photos?.first?.photoReference {
                    let imageUrl = "https://maps.googleapis.com/maps/api/place/photo?maxwidth=400&photoreference=\(photoReference)&key=\(googleAPIKey)"
                    completion(imageUrl)
                } else {
                    completion("https://example.com/default.jpg") // Default placeholder
                }
            } catch {
                completion("https://example.com/default.jpg") // Default placeholder
            }
        }.resume()
    }
}

struct GooglePlaceImageResponse: Codable {
    let candidates: [GooglePlaceCandidate]
}

struct GooglePlaceCandidate: Codable {
    let photos: [GooglePlacePhoto]?
}

struct GooglePlacePhoto: Codable {
    let photoReference: String
    
    enum CodingKeys: String, CodingKey {
        case photoReference = "photo_reference"
    }
}
