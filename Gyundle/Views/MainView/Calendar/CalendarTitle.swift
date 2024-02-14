import SwiftUI

struct CalendarTitle: View {
    @Binding var currentDate: Date
    
    var body: some View {
        VStack {
            HStack(spacing: 18) {
                Text(currentDate, formatter: Self.dateFormatter)
                    .animation(nil)
                
                Spacer()
                
                Button {
                    changeToLastMonth()
                } label: {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.foreground)
                }
                Button {
                    changeToNextMonth()
                } label: {
                    Image(systemName: "chevron.right")
                        .foregroundStyle(.foreground)
                }
            }
            .font(.headline)
            .padding(4)
            .bold()
              
            HStack(spacing: 5) {
                ForEach(Self.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol).frame(maxWidth: .infinity)
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
    CalendarTitle(currentDate: .constant(Date()))
}
