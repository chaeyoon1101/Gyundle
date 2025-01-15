import SwiftUI
import PhotosUI

struct DailyMemoryPhoto: View {
    @EnvironmentObject private var photosPickerViewModel: PhotosPickerViewModel
    var photoAttachment: PhotoAttachment
    @State var image: Image?
    
    var body: some View {
        let screenWidth = getScreenWidth()
        let photoCount = Double(photosPickerViewModel.photoAttachments.count)
        
        if let image {
            image
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(
                    width: max(screenWidth / photoCount - 4, 0),
                    height: max(screenWidth / photoCount - 4, 0)
                )
                .frame(maxHeight: screenWidth / 2)
                .clipShape(.rect(cornerRadius: 8))
                .contentShape(.rect(cornerRadius: 8))
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "xmark")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 12, height: 12)
                        .frame(width: 24, height: 24)
                        .foregroundStyle(ColorConstant.bgSecondary)
                        .background {
                            Circle()
                                .fill(ColorConstant.fgSecondary)
                        }
                        .onTapGesture {
                            photosPickerViewModel.removeAttachment(photoAttachment)
                        }
                        .padding(4)
                }
        } else {
            RoundedRectangle(cornerRadius: 8)
                .fill(ColorConstant.bgSecondary)
                .frame(
                    width: screenWidth / photoCount - 4,
                    height: screenWidth / photoCount - 4
                )
                .frame(maxHeight: screenWidth / 2)
                .overlay {
                    LoadingView()
                }
                .onAppear {
                    Task {
                        self.image = await photoAttachment.loadImage()
                    }
                }
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
}
