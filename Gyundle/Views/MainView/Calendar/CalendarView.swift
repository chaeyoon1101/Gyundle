import SwiftUI

struct CalendarView: View {
    @State private var currentDate: Date = Date()
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    var body: some View {
        ScrollView {
            VStack {
                CalendarTitle()

                CalendarGrid()
                    .gesture(
                        DragGesture()
                            .onEnded { value in
                                let translation = value.translation.width

                                if translation > 50 {
                                    calendarViewModel.changeToLastMonth()
                                } else if translation < -50 {
                                    calendarViewModel.changeToNextMonth()
                                } else {
                                    print("Cancelled")
                                }
                            }
                    )
            }
        }
        
    }
}
#Preview {
    CalendarView()
}
