import SwiftUI

struct LoadingView: View {
    var body: some View {

        ProgressView()
            .progressViewStyle(CircularProgressViewStyle())
            .scaleEffect(2)
   
    }
}

#Preview {
    LoadingView()
}
