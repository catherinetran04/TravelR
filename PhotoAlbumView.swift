import SwiftUI
import PhotosUI
import UIKit

// Helper function to save image to documents directory
func saveImageToDocumentsDirectory(image: UIImage, fileName: String) -> URL? {
    guard let data = image.pngData() else {
        print("Error: Unable to convert image to PNG data.")
        return nil
    }

    let fileManager = FileManager.default
    let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
    let fileURL = documentDirectory.appendingPathComponent(fileName)
    
    do {
        try data.write(to: fileURL)
        print("Image successfully saved to: \(fileURL.path)")
        
        return fileURL
    } catch {
        print("Error saving image: \(error.localizedDescription)")
        return nil
    }
}

// Helper function to load image from URL
func loadImage(from url: URL) -> UIImage? {
    return UIImage(contentsOfFile: url.path)
}

// Model for ImageItem
struct ImageItem: Identifiable, Codable, Equatable {
    var id: UUID
    var imageURL: URL

    static func == (lhs: ImageItem, rhs: ImageItem) -> Bool {
        return lhs.id == rhs.id && lhs.imageURL == rhs.imageURL
    }
}


struct PhotoAlbumView: View {
    @State private var images: [ImageItem] = []  // Hold images with file URLs
    @State private var isPickerPresented = false
    @State private var isCameraPresented = false
    @State private var selectedImagesForDeletion: Set<UUID> = [] // Track selected images for deletion
    @State private var showDeleteConfirmation = false // Control delete confirmation
    @State private var isEditing = false // Toggle editing mode for delete buttons

    var album: Album

    private func saveImagesToDisk() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentDirectory.appendingPathComponent("\(album.id.uuidString)_images.json")
        
        do {
            let data = try JSONEncoder().encode(images)
            try data.write(to: fileURL)
        } catch {
            print("Error saving images to disk: \(error)")
        }
    }

    private func loadImagesFromDisk() {
        let fileManager = FileManager.default
        let documentDirectory = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let fileURL = documentDirectory.appendingPathComponent("\(album.id.uuidString)_images.json")
        
        do {
            let data = try Data(contentsOf: fileURL)
            images = try JSONDecoder().decode([ImageItem].self, from: data)
        } catch {
            print("Error loading images from disk: \(error)")
        }
    }

    private func deleteSelectedImages() {
        for id in selectedImagesForDeletion {
            if let index = images.firstIndex(where: { $0.id == id }) {
                let imageItem = images[index]
                do {
                    try FileManager.default.removeItem(at: imageItem.imageURL)
                } catch {
                    print("Error deleting image from disk: \(error)")
                }
                images.remove(at: index)
            }
        }
        selectedImagesForDeletion.removeAll()
        saveImagesToDisk()
    }

    var body: some View {
        NavigationView {
            VStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(images) { imageItem in
                            ZStack(alignment: .topTrailing) {
                                NavigationLink(destination: FullScreenImageView(imageURL: imageItem.imageURL)) {
                                    Image(uiImage: loadImage(from: imageItem.imageURL) ?? UIImage())
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .cornerRadius(10)
                                }
                                .disabled(isEditing)

                                if isEditing {
                                    Button(action: {
                                        if selectedImagesForDeletion.contains(imageItem.id) {
                                            selectedImagesForDeletion.remove(imageItem.id)
                                        } else {
                                            selectedImagesForDeletion.insert(imageItem.id)
                                        }
                                    }) {
                                        Image(systemName: selectedImagesForDeletion.contains(imageItem.id) ? "checkmark.circle.fill" : "circle")
                                            .foregroundColor(.green)
                                            .padding(5)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                    }
                    .padding()
                }
                Spacer()
                HStack {
                    if isEditing {
                        Button("Delete Selected") {
                            showDeleteConfirmation = true
                        }
                        .padding()
                        .background(Color.red)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                        .disabled(selectedImagesForDeletion.isEmpty)
                    } else {
                        Button("Pick from Library") {
                            isPickerPresented = true
                        }
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)

                        Button("Take a Picture") {
                            isCameraPresented = true
                        }
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                    }
                }
            }
            .navigationTitle(album.name)
            .navigationBarItems(trailing: Button(isEditing ? "Done" : "Edit") {
                isEditing.toggle()
                if !isEditing {
                    selectedImagesForDeletion.removeAll()
                }
            })
            .onAppear { loadImagesFromDisk() }
            .onDisappear { saveImagesToDisk() }
            .sheet(isPresented: $isPickerPresented) {
                PhotoPickerView(onPhotosSelected: { selectedImages in
                    for image in selectedImages {
                        if let fileURL = saveImageToDocumentsDirectory(image: image, fileName: "\(UUID().uuidString).png") {
                            images.append(ImageItem(id: UUID(), imageURL: fileURL))
                        }
                    }
                    saveImagesToDisk()
                }, albumId: album.id)
            }
            .sheet(isPresented: $isCameraPresented) {
                CameraView(onImageCaptured: { image in
                    if let fileURL = saveImageToDocumentsDirectory(image: image, fileName: "\(UUID().uuidString).png") {
                        images.append(ImageItem(id: UUID(), imageURL: fileURL))
                    }
                    saveImagesToDisk()
                })
            }
            .alert("Delete Selected Images", isPresented: $showDeleteConfirmation) {
                Button("Delete", role: .destructive) { deleteSelectedImages() }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("Are you sure you want to delete the selected images? This action cannot be undone.")
            }
        }
    }
}

// Delegate for handling drag and drop
struct DragRelocateDelegate: DropDelegate {
    let item: ImageItem
    @Binding var listData: [ImageItem]
    @Binding var current: ImageItem?
    var saveAction: () -> Void
    
    func dropEntered(info: DropInfo) {
        guard let current = current else { return }
        if current != item {
            let fromIndex = listData.firstIndex(of: current)!
            let toIndex = listData.firstIndex(of: item)!
            listData.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        }
    }
    
    func performDrop(info: DropInfo) -> Bool {
        current = nil
        saveAction()
        return true
    }
}
    
struct PhotoPickerView: UIViewControllerRepresentable {
    var onPhotosSelected: ([UIImage]) -> Void
    var albumId: UUID
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onPhotosSelected: onPhotosSelected, albumId: albumId)
    }
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 0 // No limit on selection
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        var onPhotosSelected: ([UIImage]) -> Void
        var albumId: UUID
        
        init(onPhotosSelected: @escaping ([UIImage]) -> Void, albumId: UUID) {
            self.onPhotosSelected = onPhotosSelected
            self.albumId = albumId
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            picker.dismiss(animated: true)
            
            var selectedImages = [UIImage]()
            let dispatchGroup = DispatchGroup()
            
            for result in results {
                if result.itemProvider.canLoadObject(ofClass: UIImage.self) {
                    dispatchGroup.enter()
                    result.itemProvider.loadObject(ofClass: UIImage.self) { object, error in
                        if let error = error {
                            print("Error loading image: \(error.localizedDescription)")
                        } else if let image = object as? UIImage {
                            DispatchQueue.main.async {
                                selectedImages.append(image)
                            }
                        }
                        dispatchGroup.leave()
                    }
                } else {
                    print("Cannot load object of class UIImage")
                }
            }
            
            dispatchGroup.notify(queue: .main) {
                self.onPhotosSelected(selectedImages)
            }
        }
    }
}
    
struct CameraView: UIViewControllerRepresentable {
    var onImageCaptured: (UIImage) -> Void
    @Environment(\.presentationMode) private var presentationMode
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(onImageCaptured: onImageCaptured, dismiss: { presentationMode.wrappedValue.dismiss() })
    }
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            picker.sourceType = .photoLibrary
            print("Camera not available; falling back to photo library.")
        } else {
            fatalError("No valid source type available.")
        }
        
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        var onImageCaptured: (UIImage) -> Void
        var dismiss: () -> Void
        
        init(onImageCaptured: @escaping (UIImage) -> Void, dismiss: @escaping () -> Void) {
            self.onImageCaptured = onImageCaptured
            self.dismiss = dismiss
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                DispatchQueue.main.async {
                    self.onImageCaptured(image)
                }
            } else {
                print("Failed to retrieve image.")
            }
            dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss()
        }
    }
}
