import SwiftUI

struct DogWalkingMemoryView: View {
    var memory: DogWalkingMemory

    var body: some View {
        HeaderView()
            .padding(.bottom, -20)
        
        VStack {
//            DogWalkingMapView()
//                .frame(height: 240)
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    ColorConstant.bgContent
                        .shadow(.drop(color: .primary.opacity(0.2), radius: 4))
                )
        )
    }
    
    @ViewBuilder
    private func HeaderView() -> some View {
        HStack {
            Image(systemName: "dog.fill")
                .imageScale(.medium)
            
            Text("산책 기록")
                .font(.headline)
                .bold()
            
            Spacer()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
        .environmentObject(DailyMemoryViewModel())
}
