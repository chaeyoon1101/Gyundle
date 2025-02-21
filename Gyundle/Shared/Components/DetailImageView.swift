//
//  ImageDetailView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/1/25.
//

import SwiftUI

struct DetailImageView: View {
    @EnvironmentObject private var detailImageViewModel: DetailImageViewModel
    
    var body: some View {
        ZStack {
            Self.background(color: .black).opacity(detailImageViewModel.scale)
             
            TabView(selection: $detailImageViewModel.selectedImage) {
                
                ForEach(detailImageViewModel.selection) { item in
                    
                    VStack {
                        if let image = item.image {
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .offset(detailImageViewModel.position)
                                .scaleEffect(detailImageViewModel.scale)
                        } else {
                            CachedAsyncImage(url: URL(string: item.id)) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fit)
                                        .offset(detailImageViewModel.position)
                                        .scaleEffect(detailImageViewModel.scale)
                                case .empty:
                                    LoadingView()
                                case .failure(_):
                                    LoadingView()
                                @unknown default:
                                    LoadingView()
                                }
                            }
                        }
                    }
                    .tag(item)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .gesture(dragGesture)
    }
    
    private var dragGesture: AnyGesture<DragGesture.Value> {
        AnyGesture(
            DragGesture()
                .onChanged { value in
                    let position = value.translation
                    
                    let translationHeight = abs(value.translation.height)
                    let screenHeight = getScreenHeight()
                    let scale = (screenHeight - translationHeight) / screenHeight
                    
                    detailImageViewModel.updateTransform(position: position, scale: scale)
                }
                .onEnded { value in
                    let translationHeight = abs(value.translation.height)
                    
                    if translationHeight > 200 {
                        detailImageViewModel.dismissView()
                    } else {
                        detailImageViewModel.resetTransform()
                    }
                }
        )
    }
}

#Preview {
    HomeView(showMemorizeView: .constant(false))
        .environmentObject(AuthViewModel())
}
