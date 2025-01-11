//
//  RootView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/11/25.
//

import SwiftUI

struct RootView<Content: View>: View {
    var content: Content
    init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content()
    }
    
    @StateObject private var overlayStore = AppWideOverlayStore()
    
    var body: some View {
        content
            .onAppear(perform: setupOverlayWindow)
            .environmentObject(overlayStore)
    }
    
    private func setupOverlayWindow() {
        guard overlayStore.window == nil,
        let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else { return }
        
        let window = PassthroughWindow(windowScene: windowScene)
        window.isHidden = false
        window.isUserInteractionEnabled = true
        
        let rootViewController = UIHostingController(
            rootView: AppWideOverlayView().environmentObject(overlayStore)
        )
        rootViewController.view.backgroundColor = .clear
        window.rootViewController = rootViewController
        
        overlayStore.window = window
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

fileprivate class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event),
              let rootView = rootViewController?.view else { return nil }
        
        for subView in rootView.subviews.reversed() {
            let subPointView = subView.convert(point, from: rootView)
            
            if subView.hitTest(subPointView, with: event) != nil {
                return hitView
            }
        }
        
        return nil
    }
}
