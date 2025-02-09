//
//  AppWideOverlayModifier.swift
//  Gyundle
//
//  Created by 임채윤 on 1/11/25.
//

import SwiftUI

extension View {
    @ViewBuilder
    func appWideOverlay<Content: View>(
        isShowing: Binding<Bool>,
        @ViewBuilder content: () -> Content
    ) -> some View {
        self
            .modifier(AppWideOverlayModifier(isShowing: isShowing, content: content))
    }
    
    @ViewBuilder
    func toastView(
        isShowing: Binding<Bool>,
        message: String?
    ) -> some View {
        self
            .modifier(AppWideOverlayModifier(isShowing: isShowing, content: {
                ToastView(isShowing: isShowing, message: message)
            }))
    }
}

struct AppWideOverlayModifier<ViewContent: View>: ViewModifier {
    @EnvironmentObject private var overlayStore: AppWideOverlayStore
    
    @Binding var isShowing: Bool
    @ViewBuilder var content: ViewContent
    
    @State private var viewID: String?
    
    func body(content: Content) -> some View {
        content
            .onChange(of: isShowing) { _, newValue in
                if newValue {
                    addView()
                } else {
                    removeView()
                }
            }
    }
    
    private func addView() {
        guard overlayStore.window != nil, viewID == nil else { return }
        
        viewID = UUID().uuidString

        if let viewID {
            overlayStore.overlayViews.append(.init(id: viewID, content: .init(content)))
        }
    }
    
    private func removeView() {
        guard let viewID else { return }
        
        overlayStore.overlayViews.removeAll(where: { $0.id == viewID } )
        
        self.viewID = nil
    }
}


