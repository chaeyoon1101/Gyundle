//
//  View+Extension.swift
//  Gyundle
//
//  Created by 임채윤 on 12/21/24.
//

import SwiftUI

extension View {
    // MARK: Background 색상 지정
    static func background(color: Color) -> some View {
        color.ignoresSafeArea(.all)
    }
    
    
    // MARK: UI 디자인
    func align(_ alignment: Alignment) -> some View {
        let horizontalAlignments: [Alignment] = [.leading, .center, .trailing, .topLeading, .topTrailing, .bottomLeading, .bottomTrailing]
        let verticalAlignments: [Alignment] = [.top, .bottom, .topLeading, .topTrailing, .bottomLeading, .bottomTrailing]
        
        let isHorizontal = horizontalAlignments.contains(alignment)
        let isVertical = verticalAlignments.contains(alignment)
        
        return self
                    .frame(
                        maxWidth: isHorizontal ? .infinity : nil,
                        maxHeight: isVertical ? .infinity : nil,
                        alignment: alignment
                    )
    }
    
    
    // MARK: 키보드 숨기기
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    
    // MARK: Screen 크기
    func getScreenWidth() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }
        
        return windowScene.screen.bounds.width
    }
    
    func getScreenHeight() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }
        
        return windowScene.screen.bounds.height
    }
    
    func getSafeAreaTop() -> CGFloat {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return 0
        }
        
        return windowScene.windows.first?.safeAreaInsets.top ?? 0
    }
    
    // MARK: Modifiers
    func onFirstAppear(_ action: @escaping () -> ()) -> some View {
        self
            .modifier(FirstAppear(action: action))
    }
}

fileprivate struct FirstAppear: ViewModifier {
    let action: () -> ()
    @State private var hasAppeared = false
    
    func body(content: Content) -> some View {
        content
            .onAppear {
                guard !hasAppeared else { return }
                hasAppeared = true
                action()
            }
    }
}
