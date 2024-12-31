import SwiftUI
import PhotosUI
import Kingfisher

struct PhotoPickerView: View {
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImageData: Data?
    @State var selectedImageURL: String
    
    var body: some View {
        PhotosPicker(selection: $selectedItem, matching: .images) {
            PhotoPickerUIView(imageURL: $selectedImageURL)
                .frame(width: 150, height: 150)
        }
    }
}
