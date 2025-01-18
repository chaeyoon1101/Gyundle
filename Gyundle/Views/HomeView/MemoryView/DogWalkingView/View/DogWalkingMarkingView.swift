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
    
    @State private var showCameraView: Bool = false
    @State private var image: UIImage?
    
    var body: some View {
        NavigationStack {
            VStack {
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
            .task {
                if let imageURL = dogWalkingMemorizeViewModel.selectedMarker?.imageURL {
                    await loadImage(from: imageURL)
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
                        Button {
                            showCameraView = true
                        } label: {
                            Image(systemName: "camera.fill")
                        }
                        .foregroundStyle(ColorConstant.fgPrimary)
                        
                        Button("저장") {
                            dogWalkingMemorizeViewModel.addMarker(image: image)
                            dismiss()
                        }
                        .foregroundStyle(ColorConstant.accent)
                        .bold()
                    }
                }
            })
            .navigationTitle("산책 메모 작성")
            .fullScreenCover(isPresented: $showCameraView) {
                CameraView(seletedImage: $image)
            }
        }
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
    DogWalkingMemorizeView()
        .environmentObject(DogWalkingMemoryViewModel())
}
