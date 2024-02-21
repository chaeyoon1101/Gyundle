//
//  LoadingView.swift
//  Gyundle
//
//  Created by 임채윤 on 2/21/24.
//

import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle())
                .scaleEffect(2)
        }
    }
}

#Preview {
    LoadingView()
}
