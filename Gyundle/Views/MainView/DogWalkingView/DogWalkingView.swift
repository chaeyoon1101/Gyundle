import SwiftUI

struct DogWalkingView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        GeometryReader { geometry in
            
            MapView()
                .cornerRadius(8)
                .frame(width: geometry.size.width * 0.5, height: geometry.size.height * 0.5)
                .padding()
            
        }
        .background(Color.sc)
        .cornerRadius(8)
        .bold()
    }
}

#Preview {
    DogWalkingView()
        .environmentObject(CalendarViewModel())
}
