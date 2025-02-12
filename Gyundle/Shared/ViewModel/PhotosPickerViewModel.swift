import SwiftUI
import FirebaseStorage
import PhotosUI

final class PhotoAttachment {
    var photoPickerItem: PhotosPickerItem?
    var isDownloaded: Bool
    
    init(photoPickerItem: PhotosPickerItem?, isDownloaded: Bool = false) {
        self.photoPickerItem = photoPickerItem
        self.isDownloaded = isDownloaded
    }
    
    func loadImage() async -> Image? {
        do {
            // PhotosPicker로 선택된 selection이면 itemIdentifier로 정상적인 UIImage를 만들어 리턴
            if let data = try await photoPickerItem?.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                return Image(uiImage: uiImage)
            }
            
            // PhotosPicker로 선택한 게 아닌 URL 데이터를 PhotosPicker로 변환한 경우는 URLSession으로 Image 변환
            if let itemIdentifier = photoPickerItem?.itemIdentifier,
               let url = URL(string: itemIdentifier) {
                let (data, _) = try await URLSession.shared.data(from: url)

                if let uiImage = UIImage(data: data) {
                    return Image(uiImage: uiImage)
                }
            }
        } catch {
            print("selection 데이터가 올바르지 않음:", error)
        }
        
        return nil
    }
}

class PhotosPickerViewModel: ObservableObject {
    @Published var isUploading: Bool = false
    @Published var isDownloading: Bool = false
    @Published var showPhotosPicker: Bool = false
    
    @Published var photoSelections: [PhotosPickerItem] = [] {
        didSet {
            updateAttachments(selections: photoSelections)
        }
    }
    
    @Published var photoAttachments: [PhotoAttachment] = []
    
    func uploadPhoto(to storage: PhotoStorage) async -> [String] {
        await MainActor.run {
            isUploading = true
        }
        
        var downloadUrls: [String] = []
        for attachment in photoAttachments {
            guard attachment.isDownloaded == false else {
                if let url = attachment.photoPickerItem?.itemIdentifier {
                    downloadUrls.append(url)
                }
                continue
            }
            
            do {
                if let data = try await attachment.photoPickerItem?.loadTransferable(type: Data.self) {
                    let downloadURL = try await FirebaseManager.shared.uploadPhoto(with: data, to: storage.folderName)
                    
                    downloadUrls.append(downloadURL)
                }
            } catch {
                print("사진 업로드 실패:", error.localizedDescription)
            }
        }
        
        await MainActor.run {
            isUploading = false
        }
        
        return downloadUrls
    }
    
    func convertToPhotosPickerItem(from photosURL: [String]) {
        for photosURL in photosURL {
            let photoAttachment = PhotoAttachment(photoPickerItem: .init(itemIdentifier: photosURL),
                                                  isDownloaded: true)
            
            self.photoAttachments.append(photoAttachment)
        }
    }
    
    func removeAttachment(_ attachment: PhotoAttachment) {
        withAnimation(.snappy(duration: 0.35)) {
            photoSelections.removeAll(where: { $0 == attachment.photoPickerItem } )
            photoAttachments.removeAll(where: { $0.photoPickerItem == attachment.photoPickerItem } )
        }
    }
    
    private func updateAttachments(selections: [PhotosPickerItem]) {
        let downloadedAttachments = photoAttachments.filter(\.isDownloaded)
        let newAttachments = selections.map { PhotoAttachment(photoPickerItem: $0) }
        
        if (downloadedAttachments.count + newAttachments.count) > 3 {
            print("사진 최대 선택개수는 3개입니다.")
            return
        }
        
        withAnimation {
            photoAttachments = downloadedAttachments + newAttachments
            print(photoAttachments.map { $0.photoPickerItem?.itemIdentifier })
        }
    }
}
