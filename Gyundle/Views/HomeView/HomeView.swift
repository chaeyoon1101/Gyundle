import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var dailyMemoryViewModel: DailyMemoryViewModel
    @EnvironmentObject private var dogWalkingMemoryViewModel: DogWalkingMemoryViewModel
    
    // MARK: Present 상태 관리
    @Binding var showMemorizeView: Bool
    
    var body: some View {
        VStack {
            DogSelectorView()
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 24) {
                    CalendarView()
                        .environmentObject(calendarViewModel)
                    
                    DogWalkingMemoryView(date: calendarViewModel.selectedDate)
                    
                    DailyMemoryView(date: calendarViewModel.selectedDate)
                }
                .padding()
            }
        }
            
//            if showMemorizeView {
//                MemorizeView()
//                    .align(.bottom)
//                    .padding(.bottom, 120)
//            }
//            
//            MemorizeButton()
//                .align(.bottom)
//                .padding(.bottom, 24)s
//        .safeAreaPadding(.top, getSafeAreaTop())
        .toolbar(.hidden, for: .navigationBar)
        .fullScreenCover(isPresented: $dailyMemoryViewModel.showMemorizeView) {
            DailyMemorizeView(date: calendarViewModel.selectedDate)
        }
        .fullScreenCover(isPresented: $dogWalkingMemoryViewModel.showMemorizeView) {
            DogWalkingMemorizeView(date: calendarViewModel.today)
        }
        .environmentObject(dailyMemoryViewModel)
        .environmentObject(dogWalkingMemoryViewModel)
    }
    
    @ViewBuilder
    private func MemorizeButton() -> some View {
        Button {
            withAnimation {
                showMemorizeView.toggle()
            }
        } label: {
            Image(systemName: "dog.fill")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .opacity(0.8)
                .frame(width: 24, height: 24)
        }
        .buttonStyle(AddMemoryButtonStyle())
    }
    
    @ViewBuilder
    private func MemorizeView() -> some View {
        HStack {
            MemorizeViewButton(
                color: Color.brown,
                image: "dog.waiting",
                text: "산책하기",
                onTapped: {
//                    showDogWalkingMemorizeView = true
                }
            )
            
            
            MemorizeViewButton(
                color: Color.indigo,
                image: "dog.write.diary",
                text: "일기쓰기",
                onTapped: {
//                    showDailyMemorizeView = true
                }
            )
        }
        .bold()
    }
    
    @ViewBuilder
    func MemorizeViewButton(
        color: Color,
        image: String,
        text: String,
        onTapped: @escaping () -> ()
    ) -> some View {
        VStack(spacing: 12) {
            Image(image)
                .resizable()
                .frame(width: 40, height: 40)
                .aspectRatio(contentMode: .fill)
            
            Text(text)
        }
        .frame(height: 120)
        .frame(maxWidth: .infinity)
        .foregroundStyle(Color.white)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(color)
        }
        .onTapGesture {
            onTapped()
            showMemorizeView.toggle()
        }
    }
}

#Preview {
    HomeView(showMemorizeView: .constant(false))
        .environmentObject(DogWalkingMemoryViewModel())
        .environmentObject(DailyMemoryViewModel())
        .environmentObject(CalendarViewModel())
}
