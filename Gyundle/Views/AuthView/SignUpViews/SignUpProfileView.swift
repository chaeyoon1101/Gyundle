import SwiftUI
import PhotosUI

struct SignUpProfileView: View {
    @ObservedObject var signUpData: SignUpData
    @StateObject var imageViewModel = ImageViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel
    
    @Binding var pageId: SignUpViewPageId
    
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State private var selectedImage: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                if imageViewModel.isUploadingImage {
                    LoadingView()
                }
                
                backButton
                    .position(x: 30, y: 30)
                
                VStack {
                    VStack(spacing: 24) {
                        Text("\(signUpData.name)의 예쁜 사진을 등록해주세요!")
                        
                        PhotosPicker(selection: $selectedItem, matching: .images) {
                            PhotoPickerView(image: $selectedImage)
                                .frame(width: 150, height: 150)
                        }
                        .onChange(of: selectedItem) { newItem in
                            Task {
                                if let data = try? await newItem?.loadTransferable(type: Data.self) {
                                    selectedImageData = data
                                    
                                    if let selectedImageData,
                                       let image = UIImage(data: selectedImageData) {
                                        selectedImage = image
                                        uploadImage(image)
                                    }
                                }
                            }
                        }
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 4)
                    
                    Spacer()
                    
                    Button("완료") {
                        authViewModel.uploadUserInfo(userData: signUpData)
                    }
                    .frame(width: geometry.size.width * 0.9)
                    .buttonStyle(CustomButtonStyle())
                }
            }
        }
        .disabled(imageViewModel.isUploadingImage)
    }

    var backButton: some View {
        Button {
            pageId = .birthdayView
        } label: {
            Image(systemName: "chevron.left")
        }
        .frame(width: 48, height: 48)
        .background(Color.secondary)
        .opacity(0.3)
        .foregroundStyle(.fg)
        .font(.title)
        .cornerRadius(5)
    }
    
    func uploadImage(_ image: UIImage) {
        imageViewModel.uploadImage(image) { result in
            switch result {
            case .success(let url):
                signUpData.photo = url.absoluteString
            case .failure(let error):
                print("Image Upload Error", error.localizedDescription)
            }
        }
    } 
}

#Preview {
    SignUpProfileView(signUpData: SignUpData(), pageId: .constant(.profileView))
}
