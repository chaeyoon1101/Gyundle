//
//  ProgressViewModifier.swift
//  Gyundle
//
//  Created by 임채윤 on 1/20/25.
//

import SwiftUI

struct ProgressViewModifier: ViewModifier {
    @Binding var isShowing: Bool
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(isShowing)

            if isShowing {
                ZStack {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                    
                    LoadingView()
                }
            }
        }
    }
}

extension View {
    func progressView(isShowing: Binding<Bool>) -> some View {
        self
            .modifier(ProgressViewModifier(isShowing: isShowing))
    }
}
