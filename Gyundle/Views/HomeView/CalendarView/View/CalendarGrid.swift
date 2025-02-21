import SwiftUI

struct CalendarGrid: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 12) {
            
            ForEach(0..<6, id: \.self) { week in
                
                HStack(spacing: 5) {
                    
                    ForEach(1..<8, id: \.self) { day in
                        
                        if isCurrentMonth(week: week, day: day) {
                            let day = self.dayText(week: week, day: day)
                            
                            CalendarCell(day: day)
                        } else {
                            Color.clear
                        }
                    }
                }
            }
        }
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

}

extension CalendarGrid {
    // MARK: 특정 week와 day가 현재 표시된 달에 속하는지 확인
    private func isCurrentMonth(week: Int, day: Int) -> Bool {
        let calendar = Calendar.current
        let currentDate = calendarViewModel.currentPageDate
        
        // 이번 달의 1일
        let firstDayOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: currentDate)
        ) ?? Date()
        
        
        // 이번 달의 시작 요일
        let startWeekday = calendar.date(
            byAdding: .day,
            value: -(calendar.component(.weekday, from: firstDayOfMonth) - 1),
            to: firstDayOfMonth
        ) ?? Date()

        
        // 주(week)와 요일(day)을 통해서 날짜 계산
        let date = calendar.date(
            byAdding: .day,
            value: (week * 7) + (day - calendar.component(.weekday, from: startWeekday)),
            to: startWeekday
        ) ?? Date()
        
        
        // 주와 요일을 통해서 계산할 날짜와 실제 현재 날짜와 동일한 지 확인
        return calendar.component(.month, from: date) == calendar.component(.month, from: currentDate)
    }
    
    
    // MARK: week와 day로 며칠인 지 계산
    private func dayText(week: Int, day: Int) -> Int {
        let calendar = Calendar.current
        let currentDate = calendarViewModel.currentPageDate
        
        // 이번 달의 1일
        let firstDayOfMonth = calendar.date(
            from: calendar.dateComponents([.year, .month], from: currentDate)
        ) ?? Date()
        
        
        // 이번 달의 시작 요일
        let startWeekday = calendar.date(
            byAdding: .day,
            value: -(calendar.component(.weekday, from: firstDayOfMonth) - 1),
            to: firstDayOfMonth
        ) ?? Date()

        
        // week와 day를 통해서 날짜 계산
        let date = calendar.date(
            byAdding: .day,
            value: (week * 7) + (day - calendar.component(.weekday, from: startWeekday)),
            to: startWeekday
        ) ?? Date()


        return Int(date.formatting("d")) ?? 0
    }
    
}

#Preview {
    HomeView(showMemorizeView: .constant(false))
        .environmentObject(DailyMemoryViewModel())
}
