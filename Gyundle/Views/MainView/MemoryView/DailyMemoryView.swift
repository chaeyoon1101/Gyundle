import SwiftUI

struct DailyMemoryView: View {
    @EnvironmentObject var calendarViewModel: CalendarViewModel
    @EnvironmentObject var memoryViewModel: MemoryViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "dog.fill")
                    .imageScale(.medium)
                
                Text("오늘의 기억")
                    .font(.headline)
                    .bold()
                Spacer()
            }
            .padding(.leading)
        }
        .padding(.horizontal, 8)
    }
}

#Preview {
    DailyMemoryView()
        .environmentObject(CalendarViewModel())
}
