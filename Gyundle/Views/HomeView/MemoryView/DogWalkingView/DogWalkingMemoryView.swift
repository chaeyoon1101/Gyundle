import SwiftUI

struct DogWalkingMemoryView: View {
    var memory: DogWalkingMemory

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "dog.fill")
                    .imageScale(.medium)
                
                Text("산책 기록")
                    .font(.headline)
                    .bold()
                Spacer()
            }
            .padding(.leading)
        }
        .padding(.horizontal, 8)   
    }
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
        .environmentObject(MemoryViewModel())
}
