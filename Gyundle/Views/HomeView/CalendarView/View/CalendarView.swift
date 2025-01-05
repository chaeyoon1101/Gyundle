import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var dailyMemoryViewModel: DailyMemoryViewModel
    
    var body: some View {
        VStack {
            CalendarHeader()

            CalendarGrid()
        }
        .padding(.horizontal, 4)
        .task {
            await dailyMemoryViewModel.fetchMemories(from: calendarViewModel.currentPageDate)
        }
        .onChange(of: calendarViewModel.currentPageDate) { _, newValue in
            Task {
                await dailyMemoryViewModel.fetchMemories(from: calendarViewModel.currentPageDate)
            }
        }
    }
}
#Preview {
    HomeView()
        .environmentObject(UserViewModel())
        .environmentObject(DailyMemoryViewModel())
}
