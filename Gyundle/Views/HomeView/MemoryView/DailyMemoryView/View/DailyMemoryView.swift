import SwiftUI

struct DailyMemoryView: View {
    @EnvironmentObject private var dailyMemoryViewModel: DailyMemoryViewModel
    
    @State private var showDetailView: Bool = false
    let date: Date
    
    var body: some View {
        if let memory = dailyMemoryViewModel.getMemory(from: date) {
            HeaderView(memory)
                .padding(.bottom, -20)
            
            NavigationLink {
                DailyMemoryDetailView(memory: memory)
            } label: {
                VStack {
                    if !memory.photosURL.isEmpty {
                        PhotoGridView(photosURL: memory.photosURL)
                            .frame(height: 120)
                            .padding(4)
                    }
                    
                    MemoryContentView(memory)
                        .padding(4)
                }
                .background(
                    ColorConstant.bgContent
                        .shadow(.drop(color: .primary.opacity(0.2), radius: 2)),
                    in: .rect(cornerRadius: 15)
                )
            }
        }
    }
    
    @ViewBuilder
    func HeaderView(_ memory: DailyMemory) -> some View {
        HStack {
            Image(systemName: "dog.fill")
                .imageScale(.medium)
            
            Text("\(memory.date.formatting("M월 d일의")) 기억")
                .font(.headline)
                .bold()
            
            Spacer()
        }
        .padding(.leading)
    }
    
    @ViewBuilder
    func MemoryContentView(_ memory: DailyMemory) -> some View {
        VStack(alignment: .leading) {
            Text(memory.text)
                .lineLimit(5)
            
            Rectangle()
                .frame(height: 1)
                .padding(.horizontal, -8)
                .foregroundStyle(ColorConstant.fgPrimary.opacity(0.2))
            
            Text(memory.date.formatting("a h:mm"))
                .font(.footnote)
                .foregroundStyle(ColorConstant.fgSecondary)
                .offset(y: 8)
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

#Preview {
    HomeView(showMemorizeView: .constant(false))
        .environmentObject(AuthViewModel())
}
