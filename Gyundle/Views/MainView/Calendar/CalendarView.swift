import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    var body: some View {
        VStack {
            CalendarTitle()

            CalendarGrid()
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let translation = value.translation.width

                            if translation > 50 {
                                calendarViewModel.changeToLastMonth()
                            } else if translation < (-50) {
                                calendarViewModel.changeToNextMonth()
                            } else {
                                print("Cancelled")
                            }
                        }
                )
        }
        .onAppear {
            Task {
                memoryViewModel.fetchDailyMemories(date: calendarViewModel.currentDate)
            }
        }
    }
}
#Preview {
    CalendarView()
}
