import SwiftUI

struct DailyMemoryView: View {
    @ObservedObject private var detailImageViewModel = DetailImageViewModel.shared
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
    @State private var isDetailViewPresented: Bool = false
    var memory: DailyMemory
    
    var body: some View {
        HeaderView()
            .padding(.bottom, -20)
        
        VStack {
            PhotoGridView(photosURL: memory.photos)
                .frame(height: 120)
                .padding(4)
            
            MemoryContentView()
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    ColorConstant.bgContent
                        .shadow(.drop(color: .primary.opacity(0.2), radius: 4))
                )
                .onTapGesture {
                    memoryViewModel.selectedMemory = memory
                    isDetailViewPresented = true
                }
        )
        .sheet(isPresented: $isDetailViewPresented) {
            DailyMemoryDetailView(isPresented: $isDetailViewPresented)
        }
    }
    
    @ViewBuilder
    func HeaderView() -> some View {
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
    func MemoryContentView() -> some View {
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
    HomeView()
        .environmentObject(AuthViewModel())
        .environmentObject(UserViewModel())
}
