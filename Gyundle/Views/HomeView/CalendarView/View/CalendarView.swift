import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var dailyMemoryViewModel: DailyMemoryViewModel
    @EnvironmentObject private var dogWalkingMemoryViewModel: DogWalkingMemoryViewModel
    
    var body: some View {
        VStack {
            CalendarHeader()

            CalendarGrid()
        }
        .padding(.horizontal, 4)
        .onChange(of: calendarViewModel.currentPageDate, initial: true) { _, newValue in
            Task {
                await dailyMemoryViewModel.fetchMemories(from: newValue)
                await dogWalkingMemoryViewModel.fetchMemories(from: newValue)
            }
        }
    }
}
#Preview {
    HomeView()
        .environmentObject(DailyMemoryViewModel())
}
