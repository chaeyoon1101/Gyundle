import SwiftUI

struct HomeView: View {
    @StateObject private var memoryViewModel = MemoryViewModel()
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    // MARK: View 상태 관리
    @State private var showingMemorizeView: Bool = false
    
    @State private var isPresentedDailyMemorizeView: Bool = false
    @State private var isPresentedWalkingMemorizeView: Bool = false
    
    var body: some View {
        ZStack {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 24) {
                    CalendarView()
                        .environmentObject(calendarViewModel)
                    
                    let selectedDate = calendarViewModel.selectedDate
                    
                    if let dogWalkingMemory: DogWalkingMemory = memoryViewModel.getMemory(of: .dogWalking, from: selectedDate) {
                        DogWalkingMemoryView(memory: dogWalkingMemory)
                    }
                    
//                        if let dailyMemory: DailyMemory = memoryViewModel.getMemory(of: .daily, from: selectedDate) {

                    let dailyMemory = DailyMemory(id: "31", date: Date(), text: "12월 31일 테스트\n2024년도 이제 하루 남았습니다.\n내년도 좋은 날들만 있으면 좋겠네요\n\n 그럼 다들 화이팅~~", photos: [
                        "https://firebasestorage.googleapis.com:443/v0/b/gyundle.appspot.com/o/DailyMemoryPhotos%2F904F7D79-76AF-4BB2-991A-9B9D126AD05A.jpg?alt=media&token=8f5bf5cc-9440-471f-a99d-e21f88f7ebf8",
                        
                        "https://firebasestorage.googleapis.com:443/v0/b/gyundle.appspot.com/o/DailyMemoryPhotos%2FF4FAFABA-D0E3-4A78-8396-5E48E6251515.jpg?alt=media&token=d7ebe5f8-dbf8-4b21-8a8e-325a0b43d781",
                        
                        "https://firebasestorage.googleapis.com:443/v0/b/gyundle.appspot.com/o/DailyMemoryPhotos%2F64D625FB-80EE-4054-8D67-78D00857ED07.jpg?alt=media&token=09fc69e2-ee67-49a4-b3c4-1afbbacbe967"
                        ])
                        
                    DailyMemoryView(memory: dailyMemory)
//                        }
                }
            }
            .safeAreaPadding(.top, getSafeAreaTop())
            .blur(radius: showingMemorizeView ? 3 : 0)
            .scrollClipDisabled()
            
            if showingMemorizeView {
                MemorizeView()
                    .align(.bottom)
                    .padding(.bottom, 120)
            }
            
            MemorizeButton()
                .align(.bottom)
                .padding(.bottom, 24)
        }
        .padding()
        .ignoresSafeArea()
        .fullScreenCover(isPresented: $isPresentedDailyMemorizeView) {
            DailyMemorizeView(
                isPresented: $isPresentedDailyMemorizeView,
                date: calendarViewModel.selectedDate
            )
        }
        .fullScreenCover(isPresented: $isPresentedWalkingMemorizeView) {
            WalkingMemorizeView(isPresented: $isPresentedWalkingMemorizeView)
        }
        .environmentObject(memoryViewModel)
    }
    
    @ViewBuilder
    private func MemorizeButton() -> some View {
        Button {
            withAnimation {
                showingMemorizeView.toggle()
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
                image: "WaitingDog",
                text: "산책하기"
            ) {
                isPresentedWalkingMemorizeView.toggle()
            }
            
            MemorizeViewButton(
                color: Color.indigo,
                image: "WriteDiary",
                text: "일기쓰기"
            ) {
                isPresentedDailyMemorizeView.toggle()
            }
        }
        .bold()
    }
    
    @ViewBuilder
    func MemorizeViewButton(
        color: Color,
        image: String,
        text: String,
        action: @escaping () -> ()
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
            action()
            showingMemorizeView.toggle()
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
        .environmentObject(MemoryViewModel())
}
