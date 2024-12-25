import SwiftUI

struct CalendarHeader: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            
            HStack(spacing: 18) {
                DateView()
                
                Spacer()
                
                MonthNavigationView()
            }
            .bold()
              
            HStack(spacing: 5) {
                let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]
                
                ForEach(weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                }
            }
        }
    }
    
    @ViewBuilder
    func DateView() -> some View {
        VStack(alignment: .leading) {
            Text(calendarViewModel.currentPageDate.formatting("yyyy년"))
            
            Text(calendarViewModel.currentPageDate.formatting("M월"))
                .font(.title)
        }
        .animation(nil, value: UUID())
    }
    
    @ViewBuilder
    func MonthNavigationView() -> some View {
        Button {
            calendarViewModel.changeToLastMonth()
        } label: {
            Image(systemName: "chevron.left")
                .foregroundStyle(.foreground)
        }
        
        Button {
            calendarViewModel.changeToNextMonth()
        } label: {
            Image(systemName: "chevron.right")
                .foregroundStyle(.foreground)
        }
    }
}

#Preview {
    MainView()
        .environmentObject(UserViewModel())
        .environmentObject(MemoryViewModel())
}
