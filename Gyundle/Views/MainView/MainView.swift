import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @StateObject private var calendarViewModel: CalendarViewModel = CalendarViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                CalendarView()
                    .environmentObject(calendarViewModel)
                
                DogWalkingView()
                    .environmentObject(calendarViewModel)
                    .frame(height: 400)
            }
        }
        
        

    }
}

#Preview {
    MainView()
        .environmentObject(UserViewModel())
}
