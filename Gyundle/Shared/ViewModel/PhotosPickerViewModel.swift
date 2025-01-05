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
    
    func uploadPhoto(to storage: PhotoStorage) async -> [String] {
        await MainActor.run {
            isUploading = true
        }
        
        let photoDatas = selectedPhotos.compactMap { photo in
            photo.jpegData(compressionQuality: 0.8)
        }
        
        do {
            let downloadUrls = try await FirebaseManager.shared.uploadPhoto(with: photoDatas, to: storage.folderName)
            
            await MainActor.run {
                isUploading = false
            }
            return downloadUrls
        } catch {
            print("사진 업로드 실패:", error.localizedDescription)
            
            await MainActor.run {
                isUploading = false
            }
            return []
        }
    }
    
    func loadImage(from photosURL: [String]?) async {
        for photoURL in photosURL ?? [] {
            guard let url = URL(string: photoURL) else { continue }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                if let uiImage = UIImage(data: data) {
                    await MainActor.run {
                        selectedPhotos.append(uiImage)
                    }
                }
            } catch {
                print("(\(url.absoluteString))이미지 로드 실패:", error.localizedDescription)
            }
        }
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
            withAnimation {
                selectedPhotos = photos
            }
        }
    }
}
