//
//  ImageDetailView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/1/25.
//

import SwiftUI

struct DetailImageView: View {
    @ObservedObject private var detailImageViewModel = DetailImageViewModel.shared
    
    var body: some View {
        if detailImageViewModel.isPresented {
            
            ZStack {
                Self.background(color: .black)
                    .opacity(detailImageViewModel.scale)
                
                TabView(selection: $detailImageViewModel.selectedPhoto) {
                    
                    ForEach(detailImageViewModel.photoSelection, id: \.self) { photoURL in
                        
                        CachedAsyncImage(url: URL(string: photoURL)) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                            case .empty:
                                LoadingView()
                            case .failure(_ ):
                                Image(systemName: "xmark.circle")
                            @unknown default:
                                LoadingView()
                            }
                        }
                        .tag(photoURL)
                        .offset(detailImageViewModel.position)
                        .scaleEffect(detailImageViewModel.scale)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
            }
            .gesture(dragGesture)
        }
    }
    
    var dragGesture: AnyGesture<DragGesture.Value> {
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
                        detailImageViewModel.popView()
                    } else {
                        detailImageViewModel.resetTransform()
                    }
                }
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserViewModel())
}
