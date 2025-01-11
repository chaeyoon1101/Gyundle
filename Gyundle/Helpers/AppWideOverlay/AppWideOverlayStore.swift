//
//  AppWideOverlayStore.swift
//  Gyundle
//
//  Created by 임채윤 on 1/11/25.
//

import SwiftUI

final class AppWideOverlayStore: ObservableObject {
    @Published var window: UIWindow?
    @Published var overlayViews: [OverlayView] = []
    
    struct OverlayView: Identifiable {
        var id: String = UUID().uuidString
        var content: AnyView
    }
}
