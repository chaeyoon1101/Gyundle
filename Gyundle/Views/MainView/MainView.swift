import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    
    @StateObject private var calendarViewModel: CalendarViewModel = CalendarViewModel()
//    @StateObject private var mapViewModel: MapViewModel = MapViewModel()
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                CalendarView()
                    .environmentObject(calendarViewModel)
                
                MapView()
                    .frame(width: 400, height: 400)
            }
        }
        
        

    }
}

#Preview {
    MainView()
        .environmentObject(UserViewModel())
}
