//
//  SceneDelegate.swift
//  Gyundle
//
//  Created by 임채윤 on 1/3/25.
//

import UIKit
import SwiftUI

class SceneDelegate: NSObject, UIWindowSceneDelegate, ObservableObject {
    var detailImageOverlayWindow: UIWindow?
    
    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        if let windowScene = scene as? UIWindowScene {
            setupDetailImageOverlayWindow(in: windowScene)
        }
    }

    func setupDetailImageOverlayWindow(in scene: UIWindowScene) {
        let content = DetailImageView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        
        let overlayViewController = UIHostingController(
            rootView: content
        )
        
        overlayViewController.view.backgroundColor = .clear
        
        let overlayWindow = PassthroughWindow(windowScene: scene)
        overlayWindow.rootViewController = overlayViewController
        overlayWindow.isHidden = false
        
        self.detailImageOverlayWindow = overlayWindow
    }
}

class PassthroughWindow: UIWindow {
    @ObservedObject var detailImageViewModel = DetailImageViewModel.shared
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let hitView = super.hitTest(point, with: event) else {
            return nil
        }
        
        
        return detailImageViewModel.isPresented ? hitView : nil
    }
}
