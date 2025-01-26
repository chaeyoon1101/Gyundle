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
                .onTapGesture {
                    detailImageViewModel.pushView(
                        with: photoURL,
                        selection: photosURL
                    )
                }
            }
        }
        .appWideOverlay(isShowing: $detailImageViewModel.isShowing, animation: .snappy) {
            DetailImageView()
                .environmentObject(detailImageViewModel)
        }
    }
    
    @ViewBuilder
    private func PhaseView(_ phase: AsyncImagePhase, url photoURL: String) -> some View {
        switch phase {
        case .success(let image):
            if detailImageViewModel.selectedPhoto != photoURL {
                GeometryReader { let size = $0.size
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .contentShape(RoundedRectangle(cornerRadius: 8))
                }
            } else {
                Color.clear
            }
        case .empty:
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorConstant.bgSecondary)
                )
        case .failure(_ ):
            Image(systemName: "x.circle")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            
        @unknown default:
            LoadingView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorConstant.bgSecondary)
                )
        }
    }
}
