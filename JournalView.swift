import SwiftUI
import PhotosUI
import UIKit

struct Album: Identifiable {
    let id = UUID()
    var name: String
    var imagePaths: [String] // Store file paths of images
}

struct JournalView: View {
    let selectedTrip: Trip

    @State private var albums: [Album] = [
        Album(name: "Airport", imagePaths: []),
        Album(name: "Outfit", imagePaths: []),
        Album(name: "Hotel", imagePaths: []),
        Album(name: "Food and Beverages", imagePaths: []),
        Album(name: "Natural Sights", imagePaths: []),
        Album(name: "Special Landmarks and Attractions", imagePaths: []),
        Album(name: "Events", imagePaths: []),
        Album(name: "Shopping Centers", imagePaths: [])
    ]
    
    @State private var searchText: String = ""
    @State private var isAddAlbumPresented = false
    @State private var newAlbumName: String = ""
    @State private var isEditingAlbum = false
    @State private var selectedAlbum: Album?
    @State private var showDeleteConfirmation = false
    @State private var albumToDelete: Album?

    var filteredAlbums: [Album] {
        if searchText.isEmpty {
            return albums
        } else {
            return albums.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }

    var body: some View {
        VStack {
            Text("Trip: \(selectedTrip.name)")
                .font(.title)
                .padding()

            SearchBar(text: $searchText, placeholder: "Search albums")

            List {
                ForEach(filteredAlbums) { album in
                    NavigationLink(destination: PhotoAlbumView(album: album)) {
                        Text(album.name)
                    }
                    .contextMenu {
                        Button(action: {
                            selectedAlbum = album
                            isEditingAlbum = true
                        }) {
                            Label("Edit", systemImage: "pencil")
                        }
                        
                        Button(action: {
                            albumToDelete = album
                            showDeleteConfirmation = true
                        }) {
                            Label("Delete", systemImage: "trash")
                                .foregroundColor(.red)
                        }
                    }
                }
                .onDelete(perform: deleteAlbum)
            }

            Button(action: {
                isAddAlbumPresented = true
            }) {
                Label("Add New Album", systemImage: "plus")
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
        .navigationTitle("Journal")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isAddAlbumPresented) {
            AddAlbumView(newAlbumName: $newAlbumName) {
                if !newAlbumName.isEmpty {
                    albums.append(Album(name: newAlbumName, imagePaths: []))
                    isAddAlbumPresented = false
                }
            }
        }
        .alert(isPresented: $showDeleteConfirmation) {
            Alert(
                title: Text("Delete Album"),
                message: Text("Are you sure you want to delete this album?"),
                primaryButton: .destructive(Text("Delete")) {
                    if let albumToDelete = albumToDelete,
                       let index = albums.firstIndex(where: { $0.id == albumToDelete.id }) {
                        albums.remove(at: index)
                    }
                },
                secondaryButton: .cancel()
            )
        }
        .sheet(isPresented: $isEditingAlbum) {
            if let selectedAlbum = selectedAlbum {
                EditAlbumView(album: selectedAlbum) { updatedAlbum in
                    if let index = albums.firstIndex(where: { $0.id == updatedAlbum.id }) {
                        albums[index].name = updatedAlbum.name
                    }
                    isEditingAlbum = false
                }
            }
        }
    }

    private func deleteAlbum(at offsets: IndexSet) {
        albums.remove(atOffsets: offsets)
    }
}

struct ImagePickerView: UIViewControllerRepresentable {
    var onImagesSelected: ([UIImage]) -> Void

    func makeCoordinator() -> Coordinator {
        return Coordinator(onImagesSelected: onImagesSelected)
    }

    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0  // No limit on selection
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}

    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onImagesSelected: ([UIImage]) -> Void

        init(onImagesSelected: @escaping ([UIImage]) -> Void) {
            self.onImagesSelected = onImagesSelected
        }

        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            var selectedImages = [UIImage]()
            let dispatchGroup = DispatchGroup()

            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    dispatchGroup.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, _ in
                        if let image = object as? UIImage {
                            selectedImages.append(image)
                        }
                        dispatchGroup.leave()
                    }
                }
            }

            dispatchGroup.notify(queue: .main) {
                self.onImagesSelected(selectedImages)
            }
        }
    }
}

struct SearchBar: View {
    @Binding var text: String
    var placeholder: String

    var body: some View {
        HStack {
            TextField(placeholder, text: $text)
                .padding(7)
                .padding(.horizontal, 25)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .overlay(
                    HStack {
                        if !text.isEmpty {
                            Button(action: { text = "" }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.leading, 8)
                            }
                        }

                        Spacer()

                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                )
                .padding(.horizontal, 10)
        }
        .padding(.vertical, 10)
    }
}

struct AddAlbumView: View {
    @Binding var newAlbumName: String
    var onAdd: () -> Void

    var body: some View {
        VStack {
            Text("New Album")
                .font(.title2)
                .padding(.top, 20)

            TextField("Enter album name", text: $newAlbumName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                onAdd()
            }) {
                Text("Add Album")
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

struct EditAlbumView: View {
    var album: Album
    var onSave: (Album) -> Void
    
    @State private var editableAlbumName: String = ""

    var body: some View {
        VStack {
            Text("Edit Album")
                .font(.title2)
                .padding(.top, 20)

            TextField("Album Name", text: $editableAlbumName)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding()

            Button(action: {
                var updatedAlbum = album
                updatedAlbum.name = editableAlbumName
                onSave(updatedAlbum)
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
        .onAppear {
            editableAlbumName = album.name
        }
    }
}

struct JournalView_Previews: PreviewProvider {
    static var previews: some View {
        JournalView(selectedTrip: Trip(
            name: "Sample Trip",
            description: "This is a sample trip for preview purposes.",
            beginDate: Date(),
            endDate: Date(),
            location: "Sample Location"
        ))
    }
}

