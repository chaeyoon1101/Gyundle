import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @StateObject private var calendarViewModel: CalendarViewModel = CalendarViewModel()
    
    var body: some View {
        CalendarView()
            .environmentObject(calendarViewModel)
    }
}

#Preview {
    MainView()
        .environmentObject(UserViewModel())
}
