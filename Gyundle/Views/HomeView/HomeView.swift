import SwiftUI

struct HomeView: View {
    @StateObject private var dailyMemoryViewModel = DailyMemoryViewModel()
    @StateObject private var dogWalkingViewModel = DogWalkingMemoryViewModel()
    @StateObject private var calendarViewModel = CalendarViewModel()
    
    // MARK: View 상태 관리
    @State private var showingMemorizeView: Bool = false
    
    var body: some View {
        ZStack {
            
            ScrollView(.vertical, showsIndicators: false) {
                
                VStack(spacing: 24) {
                    CalendarView()
                        .environmentObject(calendarViewModel)
                    
                    let selectedDate = calendarViewModel.selectedDate
                    
//                    if let dogWalkingMemory: DogWalkingMemory = dailyMemoryViewModel.getMemory(of: .dogWalking, from: selectedDate) {
                    DogWalkingMemoryView(memory: DogWalkingMemory.defaultMemory())
//                    }
                    
                    if let dailyMemory = dailyMemoryViewModel.getMemory(from: selectedDate) {
                        DailyMemoryView(memory: dailyMemory)
                    }
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
        .fullScreenCover(isPresented: $dailyMemoryViewModel.isPresentedMemorizeView) {
            DailyMemorizeView(date: calendarViewModel.selectedDate)
        }
        .fullScreenCover(isPresented: $dogWalkingViewModel.isPresentedMemorizeView) {
            DogWalkingMemorizeView()
        }
        .environmentObject(dailyMemoryViewModel)
        .environmentObject(dogWalkingViewModel)
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
                image: "dog.waiting",
                text: "산책하기"
            ) {
//                memoryViewModel.selectedMemory = DogWalkingMemory.defaultMemory()
                dogWalkingViewModel.isPresentedMemorizeView.toggle()
            }
            
            MemorizeViewButton(
                color: Color.indigo,
                image: "dog.write.diary",
                text: "일기쓰기"
            ) {
                dailyMemoryViewModel.selectedMemory = DailyMemory.defaultMemory()
                dailyMemoryViewModel.isPresentedMemorizeView = true
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
        .environmentObject(AuthViewModel())
}
