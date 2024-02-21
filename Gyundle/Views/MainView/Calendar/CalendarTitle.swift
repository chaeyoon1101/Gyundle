import SwiftUI

struct CalendarTitle: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    
    var body: some View {
        VStack {
            HStack(spacing: 18) {
                Text(calendarViewModel.currentDate, formatter: Self.dateFormatter)
                    .animation(nil)
                
                Spacer()
                
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
            .font(.headline)
            .bold()
            .padding(4)
              
            HStack(spacing: 5) {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .frame(maxWidth: .infinity)
                        .font(.subheadline)
                }
            }
        }
        .padding(.horizontal)
    }
}

extension CalendarTitle {
    static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy년 M월"
        
        return formatter
    }()
  
    static let weekdaySymbols: [String] = {
        let weekdaySymbols = ["일", "월", "화", "수", "목", "금", "토"]

        return weekdaySymbols
    }()
}

#Preview {
    CalendarTitle()
}
