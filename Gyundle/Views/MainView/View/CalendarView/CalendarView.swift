import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
    var body: some View {
        VStack {
            CalendarHeader()

            CalendarGrid()
        }
        .padding(.horizontal, 4)
        .task {
            memoryViewModel.fetchMemories(date: calendarViewModel.currentPageDate)
        }
        .onChange(of: calendarViewModel.currentPageDate) { _, newValue in
            Task {
                memoryViewModel.fetchMemories(date: calendarViewModel.currentPageDate)
            }
        }
    }
}
#Preview {
    MainView()
        .environmentObject(UserViewModel())
        .environmentObject(MemoryViewModel())
}
