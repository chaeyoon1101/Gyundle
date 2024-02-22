import SwiftUI
import FirebaseStorage
import Kingfisher

class ImageViewModel: ObservableObject {
    @Published var isUploading: Bool = false
    
    func uploadImage(_ image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.5) else {
            return
        }
        
        isUploading = true
        print(isUploading)
        let storage = Storage.storage()
        let storageRef = storage.reference().child("profile_images/\(UUID().uuidString).jpg")
        
        storageRef.putData(imageData, metadata: nil) { (_, error) in
            if let error = error {
                completion(.failure(error))
            } else {
                storageRef.downloadURL { (url, error) in
                    if let error = error {
                        completion(.failure(error))
                    } else if let url = url {
                        completion(.success(url))
                    }
                }
            }
            self.isUploading = false
        }
    }
}
