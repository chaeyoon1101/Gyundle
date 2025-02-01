//
//  DogWalkingMarkerView.swift
//  Gyundle
//
//  Created by 임채윤 on 2/1/25.
//

import SwiftUI

struct DogWalkingMarkerView: View {
    let marker: DogWalkingMarker
    
    var body: some View {
        ZStack(alignment: .bottom) {
            Path { path in
                path.move(to: CGPoint(x: 16, y: 15))
                path.addLine(to: CGPoint(x: 0, y: -15))
                path.addLine(to: CGPoint(x: 32, y: -15))
                path.closeSubpath()
            }
            .fill(ColorConstant.accent)
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
            .padding(.bottom, 20)
            
            Circle()
                .fill(ColorConstant.accent)
                .frame(width: 32, height: 32)
                .overlay {
                    if let imageURL = marker.imageURL {
                        CachedAsyncImage(url: URL(string: imageURL)) { phase in
                            if case .success(let image) = phase {
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 28, height: 28)
                                    .clipShape(.circle)
                                    .contentShape(.circle)
                            }
                        }
                    }
                }
                .padding(.bottom, 50)
        }
        .contentShape(Rectangle())
    }
}
