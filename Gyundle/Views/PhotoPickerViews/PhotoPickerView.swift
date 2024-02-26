import SwiftUI
import PhotosUI
import Kingfisher

struct PhotoPickerView: View {
    @ObservedObject var imageViewModel: ImageViewModel
    @ObservedObject var uploadData: UserInfoData
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State var selectedImageURL: String
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            PhotoPickerUIView(imageURL: $selectedImageURL)
                .frame(width: 150, height: 150)
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                imageViewModel.isUploading = true
                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                    selectedImageData = data
                    if let selectedImageData,
                       let image = UIImage(data: selectedImageData) {
                        uploadImage(image)
                    }
                }
            }
        }
    }
    
    func uploadImage(_ image: UIImage) {
        imageViewModel.uploadImage(image) { result in
            switch result {
            case .success(let url):
                let url = url.absoluteString
                
                selectedImageURL = url
                uploadData.photo = url
                
                userViewModel.uploadUserInfo(userData: uploadData)
            case .failure(let error):
                print("Image Upload Error", error.localizedDescription)
            }
        }
    } 
}

#Preview {
    PhotoPickerView(imageViewModel: ImageViewModel(), uploadData: UserInfoData(), selectedImageURL: "")
}
