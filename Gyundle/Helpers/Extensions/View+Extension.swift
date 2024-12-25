//
//  View+Extension.swift
//  Gyundle
//
//  Created by 임채윤 on 12/21/24.
//

import SwiftUI

extension View {
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
}
