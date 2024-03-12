import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userViewModel: UserViewModel
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
    @StateObject private var calendarViewModel: CalendarViewModel = CalendarViewModel()
    
    @State private var isShowingAddMemoryView: Bool = false
    
    @State private var isPresentedDailyMemorizeView: Bool = false
    
    var body: some View {
        ZStack {
            Color.sc.ignoresSafeArea(.all)
        
            GeometryReader { geometry in
                ZStack {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 24) {
                            CalendarView()
                            
                            let selectedDate = calendarViewModel.selectedDate
                            
                            if let dogWalkingMemories = memoryViewModel.dogWalkingMemories[selectedDate.toMonth()],
                               let dogWalkingMemory = dogWalkingMemories[selectedDate.toDay()] {
                                DogWalkingMemoryView()
                            }
                            
                            if let dailyMemories = memoryViewModel.dailyMemories[selectedDate.toMonth()],
                               let dailyMemory = dailyMemories[selectedDate.toDay()] {
                                DailyMemoryView()
                            }
                        }
                        .environmentObject(calendarViewModel)
                    }
                    .blur(radius: isShowingAddMemoryView ? 3 : 0)
                    
                    addMemoryButton
                        .position(x: geometry.size.width / 2, y: geometry.size.height - 20)
                    
                    if isShowingAddMemoryView {
                        HStack {
                            Button {
                                
                            } label: {
                                Text("산책하기")
                            }
                            .buttonStyle(SelectMemoryButtonStyle(size: geometry.size))
                            
                            Button {
                                isPresentedDailyMemorizeView.toggle()
                            } label: {
                                Text("기록하기")
                            }
                            .buttonStyle(SelectMemoryButtonStyle(size: geometry.size))
                        }
                        .position(x: geometry.size.width / 2, y: geometry.size.height - 130)
                    }
                }
                
                .fullScreenCover(isPresented: $isPresentedDailyMemorizeView) {
                    
                    DailyMemorizeView(isPresented: $isPresentedDailyMemorizeView)
                        .environmentObject(calendarViewModel)
            
                    
                }
            }
            .padding(.bottom, 24)
        }
    }
    
    private var addMemoryButton: some View {
        Button {
            withAnimation {
                isShowingAddMemoryView.toggle()
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
}

struct SelectMemoryButtonStyle: ButtonStyle {
    let size: CGSize
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: size.width / 2  - 10, height: size.width / 4)
            .background(Color.secondary.opacity(0.5))
            .cornerRadius(8)
    }
    
    
}

struct AddMemoryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 72, height: 72)
            .background(.bg)
            .foregroundColor(.fg)
            .clipShape(Circle())
            .opacity(configuration.isPressed ? 0.8 : 1)
            .shadow(color: Color.fg.opacity(0.4), radius: 10, x: 10, y: 10)
            .shadow(color: Color.fg.opacity(0.1), radius: 10, x: -8, y: -8)
    }
}

#Preview {
    MainView()
        .environmentObject(UserViewModel())
        .environmentObject(MemoryViewModel())
}
