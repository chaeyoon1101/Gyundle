//
//  DogWalkingMarkingView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/16/25.
//

import SwiftUI
import CoreLocation

struct DogWalkingMarkingView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dogWalkingMemorizeViewModel: DogWalkingMemorizeViewModel
    
    @State private var isEditing: Bool
    @State private var image: UIImage?
    
    @State private var showCameraView: Bool = false
    @State private var showDeleteConfirmation: Bool = false
    
    init(isEditing: Bool = false) {
        self.isEditing = isEditing
    }
    
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
                                        dogWalkingMemorizeViewModel.removeMarker()
                                        dismiss()
                                    }
                                },
                                message: {
                                    Text("이 메모를 삭제하시겠습니까? 되돌릴 수 없습니다.")
                                }
                            )
                        }
                        
                        Button("저장") {
                            if isUpdating() {
                                dogWalkingMemorizeViewModel.updateMarker(image: image)
                            } else {
                                dogWalkingMemorizeViewModel.addMarker(image: image)
                            }
                            
                            dismiss()
                        }
                        .foregroundStyle(ColorConstant.accent)
                        .bold()
                    }
                }
            })
            .fullScreenCover(isPresented: $showCameraView) {
                CameraView(seletedImage: $image)
            }
        }
        .task {
            if let imageURL = dogWalkingMemorizeViewModel.selectedMarker?.imageURL {
                await loadImage(from: imageURL)
            }
        }
    }
    
    @ViewBuilder
    private func MarkerEditView() -> some View {
        if let image {
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: 150)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 6)
                .clipShape(.rect(cornerRadius: 12))
                .contentShape(.rect(cornerRadius: 12))
        }
        
        TextField(
            "ex) OO이가 냄새를 많이 맡은 곳",
            text: Binding(get: {
                dogWalkingMemorizeViewModel.selectedMarker?.memo ?? ""
            }, set: { newValue in
                dogWalkingMemorizeViewModel.selectedMarker?.memo = newValue
            }),
            axis: .vertical
        )
        .lineLimit(1...4)
        .align(.top)
        .padding()
    }
    
    @ViewBuilder
    private func MarkerView() -> some View {
        ScrollView(.vertical) {
            if let image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(height: 150)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 6)
                    .clipShape(.rect(cornerRadius: 12))
                    .contentShape(.rect(cornerRadius: 12))
            }
            
            Text(dogWalkingMemorizeViewModel.selectedMarker?.memo ?? "")
                .multilineTextAlignment(.leading)
                .align(.topLeading)
                .padding()
        }
    }
    
    private func isUpdating() -> Bool {
        let selectedMarkerID = dogWalkingMemorizeViewModel.selectedMarker?.id
        
        return dogWalkingMemorizeViewModel.dogWalkingMarkers.contains(where: { $0.id == selectedMarkerID })
    }
    
    private func loadImage(from url: String) async {
        guard let selectedMarker = dogWalkingMemorizeViewModel.selectedMarker else { return }
    
        if let cachedImage = ImageCacheManager.shared.getImage(forKey: selectedMarker.id) {
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
                        ImageCacheManager.shared.setImage(Image(uiImage: uiImage), forKey: selectedMarker.id)
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
