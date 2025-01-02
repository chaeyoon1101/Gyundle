//
//  ImageDetailView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/1/25.
//

import SwiftUI

struct ImageDetailView: View {
    @EnvironmentObject private var heroImageViewModel: HeroImageViewModel
    
    var body: some View {
        ZStack {
            Self.background(color: .black)
                .opacity(heroImageViewModel.scale)
            
            TabView(selection: $heroImageViewModel.selectedPhoto) {
                
                ForEach(heroImageViewModel.photoSelection, id: \.self) { photoURL in
                    
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
                    .offset(heroImageViewModel.position)
                    .scaleEffect(heroImageViewModel.scale)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
        }
        .gesture(dragGesture)
    }
    
    var dragGesture: AnyGesture<DragGesture.Value> {
        AnyGesture(
            DragGesture()
                .onChanged { value in
                    let position = value.translation
                    
                    let translationHeight = abs(value.translation.height)
                    let screenHeight = getScreenHeight()
                    let scale = (screenHeight - translationHeight) / screenHeight
                    
                    heroImageViewModel.updateTransform(position: position, scale: scale)
                }
                .onEnded { value in
                    let translationHeight = abs(value.translation.height)
                    
                    if translationHeight > 200 {
                        heroImageViewModel.popView()
                    } else {
                        heroImageViewModel.resetTransform()
                    }
                }
        )
    }
}

#Preview {
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserViewModel())
        .environmentObject(HeroImageViewModel())
}
