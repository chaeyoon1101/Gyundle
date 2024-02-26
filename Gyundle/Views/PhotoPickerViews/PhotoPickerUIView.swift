import SwiftUI
import PhotosUI
import Kingfisher

struct PhotoPickerUIView: View {

    @Binding var imageURL: String
    
    var body: some View {
        KFImage(URL(string: imageURL))
            .placeholder {
                Image(systemName: "dog.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 24, height: 24)
                    .foregroundStyle(Color.secondary)
                    .background {
                        Circle()
                            .fill(.sc)
                            .frame(width: 150, height: 150)
                    }
            }
            .resizable()
            .clipShape(Circle())
            .aspectRatio(contentMode: .fill)
            .background {
                Circle().fill(.fg)
            }
            .onAppear {
                print("PhotoPickerUIView imageURL: ", imageURL)
            }
    }
}

#Preview {
    PhotoPickerUIView(imageURL: .constant(""))
}
