import SwiftUI

struct DailyMemoryPhoto: View {
    var photos: [UIImage]
    var index: Int
    
    var body: some View {
        if let photo = photos[safe: index] {
            let screenWidth = getScreenWidth()
            let photoCount = Double(photos.count)
            
            Image(uiImage: photo)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: screenWidth / photoCount - 4,
                    height: screenWidth / photoCount - 4
                )
                .frame(maxHeight: screenWidth / 2)
                .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
}
