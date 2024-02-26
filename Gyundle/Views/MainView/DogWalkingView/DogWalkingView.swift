import SwiftUI

struct DogWalkingView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    
    var body: some View {
        VStack {
            Text(calendarViewModel.selectedDate.description)
            MapView()
        }
        
    }
}

#Preview {
    DogWalkingView()
}
