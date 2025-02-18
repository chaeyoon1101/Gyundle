//
//  SignUpBackButton.swift
//  Gyundle
//
//  Created by 임채윤 on 12/23/24.
//

import SwiftUI

struct SignUpBackButton: View {
    var action: () -> ()
    
    var body: some View {
        Image(systemName: "chevron.left")
            .font(.title)
            .frame(width: 40, height: 40)
            .padding()
            .foregroundStyle(ColorConstant.fgPrimary)
            .background {
                RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .fill(ColorConstant.bgContent)
            }
            .onTapGesture(perform: action)
    }
}

#Preview {
    SignUpBackButton() { }
}
