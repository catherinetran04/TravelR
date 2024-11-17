import SwiftUI

struct Trip: Identifiable {
    let id: UUID
    var name: String
    var description: String
    var beginDate: Date
    var endDate: Date
    var location: String
    
    init(id: UUID = UUID(), name: String, description: String, beginDate: Date, endDate: Date, location: String) {
        self.id = id
        self.name = name
        self.description = description
        self.beginDate = beginDate
        self.endDate = endDate
        self.location = location
    }
}
    
struct TripsView: View {
    @State private var trips: [Trip] = [
        Trip(name: "Local Area", description: "Explore your local area", beginDate: Date(), endDate: Date(), location: "Home")
    ]
    
    @State private var searchText: String = ""
    @State private var isAddTripPresented = false
    @State private var newTripName: String = ""
    @State private var newTripDescription: String = ""
    @State private var newTripBeginDate: Date = Date()
    @State private var newTripEndDate: Date = Date()
    @State private var newTripLocation: String = ""
    @State private var showDeleteConfirmation = false
    @State private var tripToDelete: Trip?
    @State private var isEditTripPresented = false
    @State private var tripToEdit: Trip?

    var filteredTrips: [Trip] {
        if searchText.isEmpty {
            return trips
        } else {
            return trips.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                SearchBar(text: $searchText, placeholder: "Search trips")
                
                List {
                    ForEach(filteredTrips) { trip in
                        NavigationLink(destination: JournalView(selectedTrip: trip)) {
                            VStack(alignment: .leading) {
                                Text(trip.name)
                                    .font(.headline)
                                Text(trip.description)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                                Text("Dates: \(trip.beginDate, formatter: dateFormatter) - \(trip.endDate, formatter: dateFormatter)")
                                    .font(.caption)
                                Text("Location: \(trip.location)")
                                    .font(.caption)
                            }
                        }
                        .contextMenu {
                            Button(action: {
                                tripToEdit = trip
                                isEditTripPresented = true
                            }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(action: {
                                tripToDelete = trip
                                showDeleteConfirmation = true
                            }) {
                                Label("Delete", systemImage: "trash")
                                    .foregroundColor(.red)
                            }
                        }
                    }
                    .onDelete(perform: deleteTrip)
                }
                
                Button(action: {
                    isAddTripPresented = true
                }) {
                    Label("Add New Trip", systemImage: "plus")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .padding(.horizontal)
                }
                
                Spacer()
            }
            .navigationTitle("Document Your Trips!")
            .sheet(isPresented: $isAddTripPresented) {
                AddTripView(newTripName: $newTripName, newTripDescription: $newTripDescription, newTripBeginDate: $newTripBeginDate, newTripEndDate: $newTripEndDate, newTripLocation: $newTripLocation) {
                    if !newTripName.isEmpty {
                        trips.append(Trip(name: newTripName, description: newTripDescription, beginDate: newTripBeginDate, endDate: newTripEndDate, location: newTripLocation))
                        isAddTripPresented = false
                    }
                }
            }
            .sheet(isPresented: $isEditTripPresented) {
                if let tripToEdit = tripToEdit {
                    EditTripView(trip: tripToEdit) { updatedTrip in
                        if let index = trips.firstIndex(where: { $0.id == updatedTrip.id }) {
                            trips[index] = updatedTrip  // Update trip in the array
                        }
                        isEditTripPresented = false  // Dismiss the sheet
                    }
                }
            }
            .alert(isPresented: $showDeleteConfirmation) {
                Alert(
                    title: Text("Delete Trip"),
                    message: Text("Are you sure you want to delete this trip?"),
                    primaryButton: .destructive(Text("Delete")) {
                        if let tripToDelete = tripToDelete,
                           let index = trips.firstIndex(where: { $0.id == tripToDelete.id }) {
                            trips.remove(at: index)
                        }
                    },
                    secondaryButton: .cancel()
                )
            }
        }
    }

    private func deleteTrip(at offsets: IndexSet) {
        trips.remove(atOffsets: offsets)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
}

    
    struct AddTripView: View {
        @Binding var newTripName: String
        @Binding var newTripDescription: String
        @Binding var newTripBeginDate: Date
        @Binding var newTripEndDate: Date
        @Binding var newTripLocation: String
        var onAdd: () -> Void
        
        var body: some View {
            VStack {
                Text("New Trip")
                    .font(.title2)
                    .padding(.top, 20)
                
                TextField("Enter trip name", text: $newTripName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                TextField("Enter trip description", text: $newTripDescription)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                DatePicker("Start Date", selection: $newTripBeginDate, displayedComponents: .date)
                    .padding()
                
                DatePicker("End Date", selection: $newTripEndDate, displayedComponents: .date)
                    .padding()
                
                TextField("Enter trip location", text: $newTripLocation)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                
                Button(action: {
                    onAdd()
                    resetFields() // Call to reset the fields
                }) {
                    Text("Add Trip")
                        .font(.headline)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.horizontal)
                
                Spacer()
            }
            .padding()
        }
        private func resetFields() {
            newTripName = ""
            newTripDescription = ""
            newTripBeginDate = Date()
            newTripEndDate = Date()
            newTripLocation = ""
        }

    }
    
struct EditTripView: View {
    var trip: Trip
    var onSave: (Trip) -> Void
    
    @State private var editableTripName: String
    @State private var editableTripDescription: String
    @State private var editableBeginDate: Date
    @State private var editableEndDate: Date
    @State private var editableLocation: String
    
    init(trip: Trip, onSave: @escaping (Trip) -> Void) {
        self.trip = trip
        self.onSave = onSave
        
        // Initialize the states with current trip data
        _editableTripName = State(initialValue: trip.name)
        _editableTripDescription = State(initialValue: trip.description)
        _editableBeginDate = State(initialValue: trip.beginDate)
        _editableEndDate = State(initialValue: trip.endDate)
        _editableLocation = State(initialValue: trip.location)
    }
    
    var body: some View {
        VStack {
            Text("Edit Trip")
                .font(.title2)
                .padding(.top, 20)
            
            TextField("Trip Name", text: $editableTripName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            TextField("Trip Description", text: $editableTripDescription)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            DatePicker("Start Date", selection: $editableBeginDate, displayedComponents: .date)
                .padding()
            
            DatePicker("End Date", selection: $editableEndDate, displayedComponents: .date)
                .padding()
            
            TextField("Trip Location", text: $editableLocation)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()
            
            Button(action: {
                var updatedTrip = trip
                updatedTrip.name = editableTripName
                updatedTrip.description = editableTripDescription
                updatedTrip.beginDate = editableBeginDate
                updatedTrip.endDate = editableEndDate
                updatedTrip.location = editableLocation
                onSave(updatedTrip)  // Save the updated trip
            }) {
                Text("Save Changes")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding()
    }
}
