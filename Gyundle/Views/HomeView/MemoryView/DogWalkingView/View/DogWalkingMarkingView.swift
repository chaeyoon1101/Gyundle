//
//  DogWalkingMarkingView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/16/25.
//

import SwiftUI
import CoreLocation

enum MarkingAction {
    case upsert(marker: DogWalkingMarker)
    case delete(marker: DogWalkingMarker)
}

struct DogWalkingMarkingView: View {
    @Environment(\.dismiss) private var dismiss
    
    // TextField Properties
    @FocusState private var isFocused: Bool
    @State private var isEditing: Bool = true
    
    // Camera & Images Properties
    @StateObject private var detailImageViewModel = DetailImageViewModel()
    @State private var image: UIImage?
    @State private var isImageUploading: Bool = false
    
    // Present Properties
    @State private var showCameraView: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    @State var marker: DogWalkingMarker
    let action: (MarkingAction) -> ()
    
    var body: some View {
        NavigationStack {
            VStack {
                if isEditing {
                    MarkerEditView()
                        .navigationTitle("산책 메모 작성")
                } else {
                    MarkerView()
                        .navigationTitle("산책 메모")
                }
            }
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                    }
                    .foregroundStyle(ColorConstant.fgPrimary)
                }
                
                ToolbarItemGroup(placement: .topBarTrailing) {
                    HStack {
                        if isEditing {
                            Button {
                                showCameraView = true
                            } label: {
                                Image(systemName: "camera.fill")
                            }
                            .foregroundStyle(ColorConstant.fgPrimary)
                        } else {
                            Menu {
                                Button(role: .destructive) {
                                    showDeleteConfirmation = true
                                } label: {
                                    Label("삭제", systemImage: "trash")
                                }
                                
                                Button {
                                    isEditing = true
                                    isFocused = true
                                } label: {
                                    Label("편집", systemImage: "pencil")
                                }
                            } label: {
                                Image(systemName: "ellipsis")
                                    .foregroundStyle(ColorConstant.fgPrimary)
                                    .fontWeight(.bold)
                            }
                            .confirmationDialog(
                                "삭제 확인 알림",
                                isPresented: $showDeleteConfirmation,
                                actions: {
                                    Button("취소", role: .cancel) {
                                        print("취소")
                                    }
                                    
                                    Button("삭제하기", role: .destructive) {
                                        action(.delete(marker: marker))
                                        dismiss()
                                    }
                                },
                                message: {
                                    Text("이 메모를 삭제하시겠습니까? 되돌릴 수 없습니다.")
                                }
                            )
                        }
                        
                        Button("저장") {
                            action(.upsert(marker: marker))
                            dismiss()
                        }
                        .foregroundStyle(ColorConstant.accent)
                        .bold()
                    }
                }
            })
            .fullScreenCover(isPresented: $showCameraView) {
                CameraView(onFinished: { result in
                    switch result {
                    case .finished(let image):
                        self.image = image
                        Task {
                            await uploadImage(image)
                        }
                    case .failed:
                        print("사진을 찍는 과정에서 무언가가 잘못 됨")
                    case .cancelled:
                        print("Cancelled")
                    }
                })
            }
        }
        .appWideOverlay(isShowing: $detailImageViewModel.isShowing) {
            DetailImageView()
                .environmentObject(detailImageViewModel)
        }
        .interactiveDismissDisabled(detailImageViewModel.isShowing)
        .progressView(isShowing: $isImageUploading)
        .onAppear {
            isEditing = marker.memo.isEmpty
        }
    }
    
    @ViewBuilder
    private func MarkerEditView() -> some View {
        ImageView()
        
        TextField("ex) OO이가 냄새를 많이 맡은 곳", text: $marker.memo, axis: .vertical)
            .focused($isFocused)
            .lineLimit(1...4)
            .align(.top)
            .padding()
            .frame(maxHeight: .infinity)
    }
    
    @ViewBuilder
    private func MarkerView() -> some View {
        ScrollView(.vertical) {
            ImageView()
            
            Text(marker.memo)
                .multilineTextAlignment(.leading)
                .align(.topLeading)
                .padding()
        }
    }
    
    @ViewBuilder
    private func ImageView() -> some View {
        if let imageURL = marker.imageURL {
            if let image, !detailImageViewModel.isShowing {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 6)
                    .clipShape(.rect(cornerRadius: 12))
                    .contentShape(.rect(cornerRadius: 12))
                    .onFirstAppear {
                        let image = Image(uiImage: image)
                        let selection = [DetailImageViewModel.IdentifiableImage(id: imageURL, image: image)]
                        detailImageViewModel.selection = selection
                    }
                    .onTapGesture {
                        detailImageViewModel.presentView(selectedID: imageURL)
                    }
            } else {
                RoundedRectangle(cornerRadius: 12)
                    .fill(ColorConstant.bgContent)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 6)
                    .task {
                        await loadImage(from: imageURL)
                    }
            }
        }
    }
    
    @MainActor
    private func uploadImage(_ image: UIImage) async {
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            defer { isImageUploading = false }
            isImageUploading = true
            
            let downloadURL = try? await FirebaseManager.shared.uploadPhoto(
                with: imageData,
                to: PhotoStorage.dogWalkingMemory.folderName
            )

            if let downloadURL {
                marker.imageURL = downloadURL
                ImageCacheManager.shared.setImage(Image(uiImage: image), forKey: downloadURL)
            }
        }
    }
    
    private func loadImage(from url: String) async {
        if let cachedImage = ImageCacheManager.shared.getImage(forKey: url) {
            await MainActor.run {
                self.image = cachedImage.asUIImage()
            }
        } else {
            guard let url = URL(string: url) else { return }
            
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                
                await MainActor.run {
                    if let uiImage = UIImage(data: data) {
                        self.image = uiImage
                        ImageCacheManager.shared.setImage(Image(uiImage: uiImage), forKey: url.absoluteString)
                    }
                }
            } catch {
                print("이미지 로드 실패")
            }
        }
    }
}

#Preview {
    DogWalkingMemorizeView(date: .init())
        .environmentObject(DogWalkingMemoryViewModel())
}
