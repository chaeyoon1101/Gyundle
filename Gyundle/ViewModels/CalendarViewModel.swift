import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var currentDate: Date = Date()
    
    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            withAnimation {
                self.currentDate = newDate
            }
        }
    }
    
    func changeToLastMonth() {
        changeMonth(by: -1)
    }
    
    func changeToNextMonth() {
        changeMonth(by: 1)
    }
}
