import SwiftUI

struct MainView: View {
    @StateObject private var memoryViewModel = MemoryViewModel()
    @StateObject private var calendarViewModel: CalendarViewModel = CalendarViewModel()
    
    // MARK: View 상태 관리
    @State private var showingMemorizeView: Bool = false
    
    @State private var isPresentedDailyMemorizeView: Bool = false
    @State private var isPresentedWalkingMemorizeView: Bool = false
    
    var body: some View {
        ZStack {
            Self.background(color: ColorConstant.bgPrimary)
            
            VStack {
                
                ScrollView(.vertical, showsIndicators: false) {
                    
                    VStack(spacing: 24) {
                        CalendarView()
                            .environmentObject(calendarViewModel)
                        
                        let selectedDate = calendarViewModel.selectedDate
                        
                        if let dogWalkingMemory: DogWalkingMemory = memoryViewModel.getMemory(of: .dogWalking, from: selectedDate) {
                            DogWalkingMemoryView(memory: dogWalkingMemory)
                        }
                        
                        if let dailyMemories: DailyMemory = memoryViewModel.getMemory(of: .daily, from: selectedDate) {
                            DailyMemoryView(memory: dailyMemories)
                        }
                    }
                }
                .frame(maxHeight: .infinity)
                .blur(radius: showingMemorizeView ? 3 : 0)
                
                if showingMemorizeView {
                    MemorizeView()
                        .padding(.bottom, 18)
                }
                
                MemorizeButton()
                    .padding(.bottom, 24)
            }
            .padding()
        }
        .fullScreenCover(isPresented: $isPresentedDailyMemorizeView) {
            DailyMemorizeView(isPresented: $isPresentedDailyMemorizeView)
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
                color: Color.brown.opacity(0.5),
                image: "WaitingDog",
                text: "산책하기"
            ) {
                isPresentedWalkingMemorizeView.toggle()
            }
            
            MemorizeViewButton(
                color: Color.indigo.opacity(0.7),
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
        .foregroundStyle(ColorConstant.fgPrimary)
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
    MainView()
        .environmentObject(UserViewModel())
        .environmentObject(MemoryViewModel())
}
