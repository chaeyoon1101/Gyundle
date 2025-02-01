//
//  DogWalkingAnnotation.swift
//  Gyundle
//
//  Created by 임채윤 on 2/1/25.
//

import SwiftUI

struct DogWalkingAnnotation: View {
    let annotationType: AnnotationType

    var body: some View {
        ZStack(alignment: .bottom) {
            Path { path in
                path.move(to: CGPoint(x: 16, y: 15))
                path.addLine(to: CGPoint(x: 0, y: -15))
                path.addLine(to: CGPoint(x: 32, y: -15))
                path.closeSubpath()
            }
            .fill(annotationType.color)
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
            .padding(.bottom, 20)
            
            Circle()
                .fill(annotationType.color)
                .frame(width: 32, height: 32)
                .overlay {
                    Text(annotationType.stringValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 50)
        }
        .contentShape(Rectangle())
    }
}
