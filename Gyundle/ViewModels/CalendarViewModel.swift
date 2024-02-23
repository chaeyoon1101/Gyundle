import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject {
    @Published var today: Date = Date()
    @Published var currentDate: Date = Date()
    @Published var selectedDate: Date = Date()

    private let calendar = Calendar.current
    
    func isToday(day: Int) -> Bool {
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        
        let isToday = todayComponents.year  == currentComponents.year &&
                      todayComponents.month == currentComponents.month &&
                      todayComponents.day   == day
        
        return isToday
    }
    
    func isSelectedDate(day: Int) -> Bool {
        let selectComponents = calendar.dateComponents([.year, .month, .day], from: selectedDate)
        
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        
        let isSelectedDate = selectComponents.year  == currentComponents.year &&
                             selectComponents.month == currentComponents.month &&
                             selectComponents.day   == day

        return isSelectedDate
    }
    
    func selectDate(day: Int) {
        let currentComponents = calendar.dateComponents([.year, .month], from: currentDate)
        
        var selectComponents = DateComponents()
        selectComponents.year = currentComponents.year
        selectComponents.month = currentComponents.month
        selectComponents.day = day
        
        selectedDate = calendar.date(from: selectComponents) ?? Date()
        
        print("selected Date:", selectedDate)
    }
    
    func changeToLastMonth() {
        changeMonth(by: -1)
    }
    
    func changeToNextMonth() {
        changeMonth(by: 1)
    }
    
    private func changeMonth(by value: Int) {
        let calendar = Calendar.current
        
        if let newDate = calendar.date(byAdding: .month, value: value, to: currentDate) {
            withAnimation {
                self.currentDate = newDate
            }
        }
    }
}
