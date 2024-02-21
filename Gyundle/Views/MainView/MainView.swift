import SwiftUI
import FirebaseAuth

struct MainView: View {
    @StateObject private var calendarViewModel: CalendarViewModel = CalendarViewModel()
    
    var body: some View {
        CalendarView()
            .environmentObject(calendarViewModel)
    }
}

#Preview {
    MainView()
}
