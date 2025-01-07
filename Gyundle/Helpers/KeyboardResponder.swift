//
//  KeyboardResponder.swift
//  Gyundle
//
//  Created by 임채윤 on 1/7/25.
//

import SwiftUI
import Combine

final class KeyboardResponder: ObservableObject {
    @Published var isVisible: Bool = false
    @Published var keyboardHeight: CGFloat?
    
    private var keyboardFrameCancellable: AnyCancellable?
    private var keyboardHeightCancellable: AnyCancellable?
    
    init() {
        keyboardFrameCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillChangeFrameNotification)
            .sink { notification in
                self.keyboardFrameNotification(notification)
            }
        
        keyboardHeightCancellable = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
            .sink { notification in
                self.keyboardHeightNotification(notification)
            }
    }
    
    deinit {
        keyboardFrameCancellable?.cancel()
        keyboardHeightCancellable?.cancel()
    }
    
    // 키보드의 Height 구하기
    private func keyboardHeightNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            
            if frame.height > 200 {
                keyboardHeight = frame.height
                keyboardHeightCancellable?.cancel()
            }
        }
    }
    
    // 키보드가 나타나고 있는 지 확인
    private func keyboardFrameNotification(_ notification: Notification) {
        if let userInfo = notification.userInfo {
            let frame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            
            // 전체화면의 가장 아랫부분과 키보드의 가장 윗부분이 120이상 차이나면 키보드가 나와있는 상태
            isVisible = (screenBounds.maxY - frame.minY) > 120
        }
    }
    
    private var screenBounds: CGRect {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .zero
        }
        
        return windowScene.screen.bounds
    }
}
