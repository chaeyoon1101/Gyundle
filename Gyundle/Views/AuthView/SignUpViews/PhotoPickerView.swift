import SwiftUI
import PhotosUI

struct PhotoPickerView: View {

    @Binding var image: UIImage?
    
    var body: some View {
        if let image = image {
            Image(uiImage: image)
                .resizable()
                .clipShape(Circle())
                .aspectRatio(contentMode: .fill)
                .background {
                    Circle().fill(.FG)
                }
        } else {
            Image(systemName: "camera.fill")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: 24, height: 24)
                .foregroundStyle(Color.secondary)
                .background {
                    Circle()
                        .fill(.SC)
                        .frame(width: 150, height: 150)
                }
        }
    }
}

#Preview {
    PhotoPickerView(image: .constant(nil))
}
