import SwiftUI
import PhotosUI

struct DailyMemorizeView: View {
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    @StateObject private var photosPickerViewModel = PhotosPickerViewModel()
    
    @Binding var isPresented: Bool
    
    @State var text: String = ""
    let date: Date
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                ScrollView(.vertical) {
                    PhotosView()
                    
                    DailyMemoryTextEditor(enteredText: $text)
                }
                
                BottomBar()
            }
            .padding(.horizontal, 4)
            .navigationTitle("\(date.formatting("M월 d일"))의 기억")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(ColorConstant.fgPrimary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            do {
                                let photoUrls = try await photosPickerViewModel.uploadPhoto(to: .dailyMemory)
                                
                                let memory = DailyMemory(
                                    id: date.toDay(),
                                    date: Date(),
                                    text: text,
                                    photos: photoUrls
                                )
                                
                                try await memoryViewModel.uploadMemory(memory: memory)
                            } catch {
                                print(error.localizedDescription)
                            }
                            
                            isPresented.toggle()
                        }
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
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
        .environmentObject(MemoryViewModel())
}
