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
    
    @Binding var location: CLLocation?
    
    @State private var showCameraView: Bool = false
    @State private var image: UIImage?
    
    @State var memoText: String = ""
    
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
                
                TextField("ex) OO이가 냄새를 많이 맡은 곳", text: $memoText, axis: .vertical)
                    .lineLimit(1...4)
                    .align(.top)
                    .padding()
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
                            dogWalkingMemorizeViewModel.addMarker(to: location, memo: memoText, image: image)
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
}

#Preview {
    DogWalkingMemorizeView()
        .environmentObject(DogWalkingMemoryViewModel())
}
