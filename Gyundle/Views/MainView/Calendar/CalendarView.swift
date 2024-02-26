import SwiftUI

struct CalendarView: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
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
            
            Text(calendarViewModel.selectedDate.toString())
        }
        .onChange(of: calendarViewModel.currentDate) { newValue in
            print(newValue)
        }
    }
}
#Preview {
    CalendarView()
}
