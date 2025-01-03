//
//  DetailImageViewModifier.swift
//  Gyundle
//
//  Created by 임채윤 on 1/3/25.
//

import SwiftUI

struct DetailImageViewModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .overlay {
                DetailImageView()
            }
    }
}
