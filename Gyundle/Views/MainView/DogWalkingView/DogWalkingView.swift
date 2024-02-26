import SwiftUI

struct DogWalkingView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    
    var body: some View {
        VStack {
            MapView()
        }
    }
}

#Preview {
    DogWalkingView()
}
