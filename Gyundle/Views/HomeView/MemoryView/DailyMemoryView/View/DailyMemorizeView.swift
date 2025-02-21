import SwiftUI
import PhotosUI

struct DailyMemorizeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dailyMemoryViewModel: DailyMemoryViewModel
    
    @StateObject private var photosPickerViewModel = PhotosPickerViewModel()
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    @FocusState var isFocused: Bool
    
    // ToolbarItemGroup(placement: .keyboard)가 간혈적으로 나타나지 않는 버그를 위한 프로퍼티
    @State var disabled: Bool = true
    
    @State var memory: DailyMemory
    let date: Date
    var isUpdating: Bool
    
    init(date: Date = Date(), memory: DailyMemory = .defaultMemory(), isUpdating: Bool = false) {
        self.date = date
        self.memory = memory
        self.isUpdating = isUpdating
    }
    
    var body: some View {
        NavigationStack {
            
            VStack {
                
                ScrollView(.vertical) {
                    PhotosView()
                    
                    DailyMemoryTextEditor(
                        enteredText: $memory.text,
                        isFocused: Binding(
                            get: {
                                $isFocused
                            },
                            set: { newValue in
                                isFocused = newValue.wrappedValue
                            }
                        )
                    )
                }
                .safeAreaPadding(.bottom, 100)
                .onTapGesture { isFocused = true }
                .scrollDismissesKeyboard(.interactively)
                
                PhotosPickerView()
                    .disabled(true)
                    .padding(.horizontal, -4)
            }
            .padding(.horizontal, 4)
            .toolbar {
                ToolbarItemGroup(placement: keyboardResponder.isVisible ? .keyboard : .bottomBar) {
                    HStack {
                        Button {
                            hideKeyboard()
                            photosPickerViewModel.showPhotosPicker.toggle()
                        } label: {
                            Image(systemName: "photo")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 24)
                        }
                    }
                    .foregroundStyle(.primary)

                    Spacer()
                }
                
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
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
            .toolbarBackground(.visible, for: .bottomBar)
            .navigationTitle("\(date.formatting("M월 d일"))의 기억")
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.container, edges: .bottom)
        }
        .disabled(photosPickerViewModel.isUploading)
        .disabled(disabled) /// View를 inActive 상태로 만들기 위함 0.3초 후에 enable
        .onAppear {
            /// 키보드 Toolbar가 간혈적으로 보이지 않는 버그를 해결하기 위해
            /// View를 inActive 상태로 만들었다가 Active 상태로 만들어 해결
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                changeViewStatusToActive()
            }
            
            if memory.photosURL.isEmpty == false {
                photosPickerViewModel.convertToPhotosPickerItem(
                    from: memory.photosURL
                )
            }
        }
        .toastView(
            isShowing: $dailyMemoryViewModel.showError,
            message: dailyMemoryViewModel.errorMessage
        )
    }
    
    @ViewBuilder
    private func PhotosView() -> some View {
        HStack(spacing: 4) {
            ForEach(photosPickerViewModel.photoAttachments, id: \.photoPickerItem?.itemIdentifier) { photoAttachment in
                DailyMemoryPhoto(photoAttachment: photoAttachment)
            }
        }
        .environmentObject(photosPickerViewModel)
    }

    @ViewBuilder
    private func PhotosPickerView() -> some View {
        let keyboardHeight = keyboardResponder.keyboardHeight ?? 380
        
        PhotosPicker(
            selection: $photosPickerViewModel.photoSelections,
            maxSelectionCount: 3,
            selectionBehavior: .continuous,
            matching: .any(of: [.images, .not(.videos)] ),
            preferredItemEncoding: .current,
            photoLibrary: .shared()
        ) {
            Text("사진 선택")
        }
        .photosPickerStyle(.inline)
        .photosPickerAccessoryVisibility(.hidden, edges: .vertical)
        .frame(height: photosPickerViewModel.showPhotosPicker ? keyboardHeight : 0)
        .offset(y: photosPickerViewModel.showPhotosPicker ? 0 : keyboardHeight)
        .animation(.spring(), value: photosPickerViewModel.showPhotosPicker)
        .cornerRadius(8)
        .onChange(of: keyboardResponder.isVisible) { _, isVisible in
            if isVisible, photosPickerViewModel.showPhotosPicker {
                photosPickerViewModel.showPhotosPicker = false
            }
        }
        .toastView(isShowing: $photosPickerViewModel.showError, message: photosPickerViewModel.errorMessage)
    }
    
    private func uploadMemory() {
        Task {
            await uploadPhoto()
            memory.day = date.toDay()
            memory.date = calculateUploadDate()
            
            if isUpdating {
                await dailyMemoryViewModel.updateMemory(memory, onSuccess: {
                    dismiss()
                })
            } else {
                await dailyMemoryViewModel.uploadMemory(memory, onSuccess: {
                    dismiss()
                })
            }
        }
    }
    
    private func uploadPhoto() async {
        let photosURL = await photosPickerViewModel.uploadPhoto(to: .dailyMemory)

        memory.photosURL = photosURL
    }
    
    // 24일의 기록을 25일에 작성 할 수도 있기 때문에
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
    
    private func changeViewStatusToActive() {
        disabled = false
        isFocused = true
    }
    
}
#Preview {
    HomeView(showMemorizeView: .constant(false))
        .environmentObject(DailyMemoryViewModel())
}
