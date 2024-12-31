import SwiftUI
import FirebaseStorage
import PhotosUI

enum PhotoStorage {
    case profile
    case dailyMemory
    
    var folderName: String {
        switch self {
        case .profile: return "ProfilePhotos"
        case .dailyMemory: return "DailyMemoryPhotos"
        }
    }
}

class PhotosPickerViewModel: ObservableObject {
    @Published var isUploading: Bool = false
    
    @Published var photoSelections: [PhotosPickerItem] = [] {
        didSet {
            Task {
                try await loadTransferrable(from: photoSelections)
            }
        }
    }
    @Published var selectedPhotos: [UIImage] = []
    
    func uploadPhoto(to storage: PhotoStorage) async throws -> [String] {
        await MainActor.run {
            isUploading = true
        }
        
        let photoDatas = selectedPhotos.compactMap { photo in
            photo.jpegData(compressionQuality: 0.8)
        }
        
        let downloadUrls = try await FirebaseManager.shared.uploadPhoto(with: photoDatas, to: storage.folderName)
        return downloadUrls
    }
}

extension PhotosPickerViewModel {
    private func loadTransferrable(from selections: [PhotosPickerItem]) async throws {
        let photos = await withTaskGroup(of: UIImage?.self) { group in
            for selection in selections {
                group.addTask {
                    if let data = try? await selection.loadTransferable(type: Data.self) {
                        return UIImage(data: data)
                    }
                    
                    return nil
                }
            }
            
            var photos: [UIImage] = []
            
            for await photo in group {
                if let photo {
                    photos.append(photo)
                }
            }
            
            return photos
        }
        
        await MainActor.run {
            selectedPhotos = photos
        }
    }
}
