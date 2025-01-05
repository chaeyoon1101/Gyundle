import SwiftUI
import PhotosUI

struct DailyMemorizeView: View {
    @EnvironmentObject private var dailyMemoryViewModel: DailyMemoryViewModel
    @StateObject private var photosPickerViewModel = PhotosPickerViewModel()
    
    let date: Date
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                ScrollView(.vertical) {
                    PhotosView()
                    
                    DailyMemoryTextEditor(
                        enteredText: Binding(
                            get: {
                                dailyMemoryViewModel.selectedMemory?.text ?? ""
                            },
                            set: { newValue in
                                dailyMemoryViewModel.selectedMemory?.text = newValue
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
            .onAppear {
                //
                if dailyMemoryViewModel.selectedMemory?.photos.isEmpty == false {
                    Task {
                        await photosPickerViewModel.loadImage(from: dailyMemoryViewModel.selectedMemory?.photos)
                    }
                }
            }
        }
        .disabled(photosPickerViewModel.isUploading)
    }
    
    @ViewBuilder
    private func PhotosView() -> some View {
        let selectedPhotos = photosPickerViewModel.selectedPhotos
        let selectedPhotosURL = dailyMemoryViewModel.selectedMemory?.photos ?? []
        
        if selectedPhotos.count >= selectedPhotosURL.count {
            HStack(spacing: 4) {
                ForEach(0..<photosPickerViewModel.selectedPhotos.count, id: \.self) { index in
                    DailyMemoryPhoto(
                        photos: photosPickerViewModel.selectedPhotos,
                        index: index
                    )
                }
            }
        } else {
            // URL 데이터를 UIImage로 변환 중인 상태라면 placeholder 띄우기
            
            let screenWidth = getScreenWidth()
            let photoCount = Double(selectedPhotosURL.count)
            
            HStack(spacing: 4) {
                
                ForEach(0..<selectedPhotosURL.count, id: \.self) { index in
                    
                    if let photo = photosPickerViewModel.selectedPhotos[safe: index] {
                        Image(uiImage: photo)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(
                                width: screenWidth / photoCount - 4,
                                height: screenWidth / photoCount - 4
                            )
                            .frame(maxHeight: screenWidth / 2)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(ColorConstant.bgSecondary)
                            .frame(
                                width: screenWidth / photoCount - 4,
                                height: screenWidth / photoCount - 4
                            )
                            .frame(maxHeight: screenWidth / 2)
                    }
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
    
    private func uploadMemory() {
        Task {
            await uploadPhoto()
            dailyMemoryViewModel.selectedMemory?.day = date.toDay()
            dailyMemoryViewModel.selectedMemory?.date = calculateUploadDate()
            
            if isEditing() {
                await dailyMemoryViewModel.updateMemory()
            } else {
                await dailyMemoryViewModel.uploadMemory()
            }
        }
    }
    
    private func uploadPhoto() async {
        let photosURL = await photosPickerViewModel.uploadPhoto(to: .dailyMemory)

        dailyMemoryViewModel.selectedMemory?.photos = photosURL
    }
    
    
    // 작성하고있는 데이터의 uuid가 이미 존재한다면 편집 중 그렇지 않으면 새로 작성 중
    private func isEditing() -> Bool {
        let key = date.toYearMonth()
         
        let containsSelectedMemory = dailyMemoryViewModel.dailyMemories[key]?.contains(
            where: { $0.uid == dailyMemoryViewModel.selectedMemory?.uid }
        )
        
        return containsSelectedMemory ?? false
    }
    
    // 24일의 기록을 25일에 작성 할수도 있기 때문에
    // 선택된 날짜와 작성 당시 시간분초를 합쳐서 저장
    private func calculateUploadDate() -> Date {
        let calendar = Calendar.current
        
        let selectedDateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let uploadDateComponents = calendar.dateComponents([.hour, .minute, .second], from: Date())
        
        var mergedDateComponents = DateComponents()
        mergedDateComponents.year = selectedDateComponents.year
        mergedDateComponents.month = selectedDateComponents.month
        mergedDateComponents.day = selectedDateComponents.day
        mergedDateComponents.hour = uploadDateComponents.hour
        mergedDateComponents.minute = uploadDateComponents.minute
        mergedDateComponents.second = uploadDateComponents.second
        
        
        return calendar.date(from: mergedDateComponents) ?? Date()
        
    }
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
        .environmentObject(DailyMemoryViewModel())
}
