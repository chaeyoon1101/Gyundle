import SwiftUI

struct CalendarCell: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    let week: Int
    let day: Int
    
    var body: some View {
        VStack {
            Image("TestImage")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.7)
                .overlay(
                    Text(self.dayText(week: week, day: day))
                        .foregroundStyle(.primary)
                        .font(.headline)
                        .bold()
                )
            
        }
    }
}

extension CalendarCell {
    private func dayText(week: Int, day: Int) -> String {
        let calendar = Calendar.current
        let currentDate = calendarViewModel.currentDate
        
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: currentDate)) ?? Date()
        let startDate = calendar.date(byAdding: .day, value: -(calendar.component(.weekday, from: firstDayOfMonth) - 1), to: firstDayOfMonth) ?? Date()

        let date = calendar.date(byAdding: .day, value: (week * 7) + (day - calendar.component(.weekday, from: startDate)), to: startDate) ?? Date()

        let formatter = DateFormatter()
        formatter.dateFormat = "d"

        return formatter.string(from: date)
    }
}
#Preview {
    CalendarCell(week: 1, day: 1)
}
