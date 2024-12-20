import SwiftUI

struct DailyMemoryPhoto: View {
    @Binding var photos: [Image]
    
    var index: Int
    var size: CGFloat
    
    var body: some View {
        if photos.count > index {
            photos[index]
                .resizable()
                .frame(height: size / Double(photos.count) - 4)
                .frame(maxWidth: size / Double(photos.count) - 4, maxHeight: size / 2 - Double(photos.count) * 4)
                .aspectRatio(contentMode: .fill)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    DailyMemoryPhoto(photos: .constant([Image("")]), index: 1, size: 100)
}
