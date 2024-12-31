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
            await memoryViewModel.fetchMemories(date: calendarViewModel.currentPageDate)
        }
        .onChange(of: calendarViewModel.currentPageDate) { _, newValue in
            Task {
                await memoryViewModel.fetchMemories(date: calendarViewModel.currentPageDate)
            }
        }
    }
}
#Preview {
    HomeView()
        .environmentObject(UserViewModel())
        .environmentObject(MemoryViewModel())
}
