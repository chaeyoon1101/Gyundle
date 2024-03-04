import Foundation
import SwiftUI

struct SignUpViewButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(minWidth: 0, maxWidth: .infinity)
            .padding()
            .opacity(configuration.isPressed ? 0.8 : 1)
            .background(Color(red: 222 / 255, green: 184 / 255, blue: 135 / 255))
            .foregroundColor(.black)
            .cornerRadius(20.0)
    }
}


