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
        animation: Animation? = nil,
        @ViewBuilder content: () -> Content
    ) -> some View {
        self
            .modifier(AppWideOverlayModifier(isShowing: isShowing, animation: animation, content: content))
    }
}

struct AppWideOverlayModifier<ViewContent: View>: ViewModifier {
    @EnvironmentObject private var overlayStore: AppWideOverlayStore
    
    @Binding var isShowing: Bool
    var animation: Animation?
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
        guard let viewID else { return }
        
        withAnimation(animation) {
            overlayStore.overlayViews.append(.init(id: viewID, content: .init(content)))
        }
    }
    
    private func removeView() {
        guard let viewID else { return }
        
        withAnimation(animation) {
            overlayStore.overlayViews.removeAll(where: { $0.id == viewID } )
        }
        
        self.viewID = nil
    }
}

fileprivate struct AppWideOverlayView: View {
    @EnvironmentObject private var overlayStore: AppWideOverlayStore
    
    var body: some View {
        ZStack {
            ForEach(overlayStore.overlayViews) { view in
                view.content
            }
        }
    }
}
