//
//  PhotoGridView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/3/25.
//

import SwiftUI

struct PhotoGridView: View {
    @StateObject private var detailImageViewModel = DetailImageViewModel()
    
    var photosURL: [String]
    
    var body: some View {
        HStack(spacing: 4) {
            
            ForEach(photosURL, id: \.self) { photoURL in
                
                CachedAsyncImage(url: URL(string: photoURL)) { phase in
                    PhaseView(phase, url: photoURL)
                }
            }
        }
        .onFirstAppear {
            // 처음 나타날 때 모든 사진을 id만 지정해놓고 이후에 image를 Load해서 추가해주는 방식
            let selection = photosURL.map { DetailImageViewModel.IdentifiableImage(id: $0) }
            detailImageViewModel.selection = selection
        }
        .appWideOverlay(isShowing: $detailImageViewModel.isShowing) {
            DetailImageView()
                .environmentObject(detailImageViewModel)
        }
    }
    
    @ViewBuilder
    private func PhaseView(_ phase: AsyncImagePhase, url photoURL: String) -> some View {
        switch phase {
        case .success(let image):
            if detailImageViewModel.selectedImage?.id != photoURL {
                GeometryReader { let size = $0.size
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                        .onAppear {
                            if let index = detailImageViewModel.selection.firstIndex(where: { $0.id == photoURL } ),
                               detailImageViewModel.selection[index].image == nil {
                                detailImageViewModel.selection[index].image = image
                            }
                        }
                        .onTapGesture {
                            detailImageViewModel.presentView(selectedID: photoURL)
                        }
                }
            } else {
                Color.clear
            }
        case .empty:
            RoundedRectangle(cornerRadius: 8)
                .fill(ColorConstant.bgSecondary)
            
        case .failure(_ ):
            RoundedRectangle(cornerRadius: 8)
                .fill(ColorConstant.bgSecondary)
            
        @unknown default:
            RoundedRectangle(cornerRadius: 8)
                .fill(ColorConstant.bgSecondary)
        }
    }
}
