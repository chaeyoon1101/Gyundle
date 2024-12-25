import Foundation
import SwiftUI

struct SignUpViewButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .opacity(configuration.isPressed ? 0.8 : 1)
            .background(ColorConstant.accent)
            .foregroundColor(.black)
            .cornerRadius(20.0)
    }
}

struct WalkingMemoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 72, height: 72)
            .background(ColorConstant.fgPrimary)
            .foregroundColor(ColorConstant.bgPrimary)
            .clipShape(Circle())
            .opacity(configuration.isPressed ? 0.8 : 1)
    }
}

struct SelectMemoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(ColorConstant.bgContent)
            .clipShape(RoundedRectangle(cornerRadius: 8))
    }
}

struct AddMemoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 72, height: 72)
            .background(ColorConstant.bgPrimary)
            .foregroundColor(ColorConstant.fgPrimary)
            .clipShape(Circle())
            .opacity(configuration.isPressed ? 0.8 : 1)
            .shadow(color: ColorConstant.fgPrimary.opacity(0.4), radius: 10, x: 10, y: 10)
            .shadow(color: ColorConstant.fgPrimary.opacity(0.1), radius: 10, x: -8, y: -8)
    }
}
