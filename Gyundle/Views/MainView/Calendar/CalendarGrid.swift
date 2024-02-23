import SwiftUI

struct CalendarGrid: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    var body: some View {
        
        GeometryReader { geometry in
            withAnimation {
                VStack(alignment: .center, spacing: 12) {
                    ForEach(0..<6, id: \.self) { week in
                        HStack(spacing: 5) {
                            ForEach(1..<8, id: \.self) { day in
                                let size = geometry.size.width / 7 - 4
                                if isCurrentMonth(week: week, day: day) {
                                    let day = self.dayText(week: week, day: day)
    
                                    CalendarCell(day: day, size: size)
                                        .frame(width: size, height: size)
                                    
                                    
                                } else {
                                    Color.clear
                                        .frame(width: size, height: size)
                                }
                            }
                        }
                    }
                }
            }
        }
        .aspectRatio(7/6, contentMode: .fit)
        .padding(.horizontal)
    }
}

extension CalendarGrid {
    private func isCurrentMonth(week: Int, day: Int) -> Bool {
        let calendar = Calendar.current
        let currentDate = calendarViewModel.currentDate
        
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? Date()
        let startDate = calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: firstDayOfMonth) - 1), to: firstDayOfMonth) ?? Date()

        let date = calendar.date(byAdding: .day, value: (week * 7) + (day - calendar.component(.weekday, from: startDate)), to: startDate) ?? Date()

        return calendar.component(.month, from: date) == calendar.component(.month, from: currentDate)
    }
    
    
    private func dayText(week: Int, day: Int) -> Int {
        let calendar = Calendar.current
        let currentDate = calendarViewModel.currentDate
        
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? Date()
        let startDate = calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: firstDayOfMonth) - 1), to: firstDayOfMonth) ?? Date()

        let date = calendar.date(byAdding: .day, value: (week * 7) + (day - calendar.component(.weekday, from: startDate)), to: startDate) ?? Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "d"

        return Int(formatter.string(from: date)) ?? 0
    }
    
}

#Preview {
    CalendarGrid()
        .environmentObject(CalendarViewModel())
}
