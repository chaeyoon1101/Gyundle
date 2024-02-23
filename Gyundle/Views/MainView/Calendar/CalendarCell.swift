import SwiftUI

struct CalendarCell: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
//    @State var isToday: Bool
//    @State var isSelectedDay: Bool
    
    let day: Int
    let size: CGFloat
    
    var body: some View {
        ZStack {
            VStack {
                Image("TestImage")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .opacity(0.7)
                    .clipped()
                    .cornerRadius(size / 2.8)
                    .overlay(
                        Text("\(day)")
                            .foregroundStyle(.primary)
                            .font(.headline)
                            .bold()
                    )
            }
        }
        .frame(width: size, height: size)
        .overlay(
            RoundedRectangle(cornerRadius: size / 2.8)
                .stroke(
                    calendarViewModel.isSelectedDate(day: day) ? Color.fg :
                    calendarViewModel.isToday(day: day) ? Color.mint : Color.clear,
                    lineWidth: 4)
        )
        .onTapGesture {
            calendarViewModel.selectDate(day: day)
        }
    
    }
}


#Preview {
    CalendarCell( day: 1, size: CGFloat(150))
}
