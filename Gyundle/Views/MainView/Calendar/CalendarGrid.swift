import SwiftUI

struct CalendarGrid: View {
    private let calendar: Calendar = Calendar.current
    @Binding var currentDate: Date

    var body: some View {
        
        GeometryReader { geometry in
            withAnimation {
                VStack(alignment: .center, spacing: 12) {
                    ForEach(0..<6, id: \.self) { week in
                        HStack(spacing: 5) {
                            ForEach(1..<8, id: \.self) { day in
                                let size = geometry.size.width / 7 - 4
                                if isCurrentMonth(week: week, day: day) {
                                    VStack {
                                        CalendarCell(currentDate: $currentDate, week: week, day: day)
                                            .frame(width: size, height: size)
                                            .cornerRadius(size / 3)
                                    }
                                    
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
    private func dayText(week: Int, day: Int) -> String {
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? Date()
        let startDate = calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: firstDayOfMonth) - 1), to: firstDayOfMonth) ?? Date()

        let date = calendar.date(byAdding: .day, value: (week * 7) + (day - calendar.component(.weekday, from: startDate)), to: startDate) ?? Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "d"

        return formatter.string(from: date)
    }
    
    private func isCurrentMonth(week: Int, day: Int) -> Bool {
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? Date()
        let startDate = calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: firstDayOfMonth) - 1), to: firstDayOfMonth) ?? Date()

        let date = calendar.date(byAdding: .day, value: (week * 7) + (day - calendar.component(.weekday, from: startDate)), to: startDate) ?? Date()

        return calendar.component(.month, from: date) == calendar.component(.month, from: currentDate)
    }
}

#Preview {
    CalendarGrid(currentDate: .constant(Date()))
}
