import SwiftUI
import PhotosUI

struct DailyMemorizeView: View {
    @EnvironmentObject private var dailyMemoryViewModel: DailyMemoryViewModel
    @StateObject private var photosPickerViewModel = PhotosPickerViewModel()
    
    @State var text: String = ""
    
    let date: Date
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                ScrollView(.vertical) {
                    PhotosView()
                    
                    DailyMemoryTextEditor(
                        enteredText: Binding(
                            get: {
                                (dailyMemoryViewModel.selectedMemory as? DailyMemory)?.text ?? ""
                            },
                            set: { newValue in
                                if var dailyMemory = dailyMemoryViewModel.selectedMemory as? DailyMemory {
                                    dailyMemory.text = newValue
                                    dailyMemoryViewModel.selectedMemory = dailyMemory
                                }
                            }
                        )
                    )
                }
                
                BottomBar()
            }
            .padding(.horizontal, 4)
            .navigationTitle("\(date.formatting("M월 d일"))의 기억")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dailyMemoryViewModel.isPresentedMemorizeView = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(ColorConstant.fgPrimary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        uploadMemory()
                    } label: {
                        if photosPickerViewModel.isUploading {
                            ProgressView()
                        } else {
                            Text("완료")
                                .foregroundStyle(ColorConstant.fgPrimary)
                        }
                    }
                }
            }
        }
        .disabled(photosPickerViewModel.isUploading)
    }
    
    @ViewBuilder
    private func PhotosView() -> some View {
        if !photosPickerViewModel.selectedPhotos.isEmpty {
            HStack(spacing: 4) {
                ForEach(0..<photosPickerViewModel.selectedPhotos.count, id: \.self) { index in
                    DailyMemoryPhoto(
                        photos: photosPickerViewModel.selectedPhotos,
                        index: index
                    )
                }
            }
        }
    }
    
    @ViewBuilder
    private func BottomBar() -> some View {
        HStack(alignment: .top) {
            
            PhotosPicker(
                selection: $photosPickerViewModel.photoSelections,
                maxSelectionCount: 3,
                matching: .any(of: [.images, .not(.videos)] )
            ) {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                    .foregroundStyle(ColorConstant.fgPrimary)
            }
            .padding(.leading, 24)
            
            Spacer()
        }
        .frame(height: 48)
        .background(ColorConstant.bgSecondary)
    }
    
//    private func 
    
    private func uploadMemory() {
        Task {
            let photosURL = try await photosPickerViewModel.uploadPhoto(to: .dailyMemory)
            
            let uploadMemory = DailyMemory(
                day: date.asDay(),
                date: date,
                text: text,
                photos: photosURL
            )
            
            dailyMemoryViewModel.selectedMemory = uploadMemory
            
            await dailyMemoryViewModel.uploadMemory()
            
            dailyMemoryViewModel.isPresentedMemorizeView = false
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
        .environmentObject(DailyMemoryViewModel())
}
