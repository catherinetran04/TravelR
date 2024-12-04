
# TravelR

TravelR is a personally designed iOS mobile application crafted to enhance the travel experience for adventurers and explorers. It combines modern technology with elegant design to help users discover new destinations, document their journeys, and manage their trips with ease.

Developed using **Swift** in **Xcode**, TravelR integrates various iOS frameworks such as Core Location, MapKit, and SwiftUI to deliver a seamless user experience.

This project was created in just **30 days**, showcasing the power of rapid learning and application.

---

## Features

### **Discover New Destinations**
- Browse exciting locations and gather inspiration for your next trip.
- Get tailored recommendations based on your interests and current location.
- features a navigation map, displaying the distance and time to arrival
- links to Apple Maps for direct navigation

### **Personalized Recommendations**
- Get smart travel suggestions based on your previous destinations and preferences.
- Recommendations are displayed taking web images with Google images API.

### **Interactive Map View**
- View current location and nearby attractions.
- Plot routes and visualize travel paths with **MapKit** integration.
- view friends and their current locations

### **Photo Journal**
- Record and document trips, including descriptions, locations, and calendar dates
- Capture and store travel memories in a photo album accoriding to each trip.
- View photos in fullscreen with swipe and pinch-to-zoom gestures.
- features to add, edit, or delete for trips, albums, and images

### ✍️ **Travel Journals**
- Document your travel experiences in a personal journal.
- Organize logs by trips, adding rich media like photos and location tags.

### **Trip Planning**
- Plan your trips efficiently, with the ability to add stops and routes.
- View your travel itinerary visually on an interactive map.

---

## Technologies Used

| Component            | Description                                                                           |
|----------------------|---------------------------------------------------------------------------------------|
| **Swift**            | Programming language used for iOS development.                                       |
| **Xcode**            | IDE for designing, building, and testing the app.                                    |
| **SwiftUI**          | Framework for building user interfaces declaratively.                                |
| **Core Location**    | Used for accessing real-time location data.                                          |
| **MapKit**           | Provides map-related functionalities, such as displaying maps and routes.            |
| **Combine Framework**| Reactive programming for data binding between UI and logic.                          |

---

## File Structure

### Core Files

- **`TravelerApp.swift`**: Entry point for the app, defining its lifecycle and app-wide configurations.
- **`ContentView.swift`**: Main view that acts as the navigation hub for the app.

### Views

- **`DiscoverView.swift`**: Handles the discovery of new travel destinations and tailored recommendations.
- **`TripsView.swift`**: Displays a list of planned trips and allows users to organize and manage them.
- **`JournalView.swift`**: Manages user travel logs, enabling the addition of rich text, images, and locations.
- **`PhotoAlbumView.swift`**: Displays travel photos in a user-friendly album format.
- **`FullScreenImageView.swift`**: Displays photos in fullscreen with gestures like pinch-to-zoom.

### Utility Files

- **`LocationManager.swift`**: Handles fetching and monitoring the user's real-time location.
- **`Recommendation.swift`**: Generates personalized travel suggestions based on user data.

### Map-Related Files

- **`MapView.swift`**: Displays an interactive map centered on the user’s location.
- **`MapViewWithRoute.swift`**: Visualizes travel routes and stops on a detailed map.

### Configuration

- **`Info.plist`**: Configuration file containing app metadata and permissions settings.

--- 

## Installation

1. Clone the repository to your local machine.
2. Open the project in Xcode.
3. Connect a physical device or use a simulator.
4. Build and run the app in Xcode.

## Author

Created by **Catherine Tran**.
