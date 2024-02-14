import SwiftUI

struct CalendarView: View {
    @State private var currentDate: Date = Date()
    
    var body: some View {
        VStack {
            CalendarTitle(currentDate: $currentDate)

            CalendarGrid(currentDate: $currentDate)
                .gesture(
                    DragGesture()
                        .onEnded { value in
                            let translation = value.translation.width

                            if translation > 50 {
                                changeToLastMonth()
                            } else if translation < -50 {
                                changeToNextMonth()
                            } else {
                                print("Cancelled")
                            }
                        }
                )
        }
    }
}

extension CalendarView {
    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            withAnimation {
                self.currentDate = newDate
            }
        }
    }
    
    private func changeToLastMonth() {
        changeMonth(by: -1)
    }
    
    private func changeToNextMonth() {
        changeMonth(by: 1)
    }
}
#Preview {
    CalendarView()
}
