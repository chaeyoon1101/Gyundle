import SwiftUI

struct DailyMemoryView: View {
    var memory: DailyMemory
    
    @State private var isShowingFullText: Bool = false
    
    var body: some View {
        HeaderView()
            .padding(.bottom, -20)
        
        VStack {
            PhotoGridView()
            
            MemoryContentView()
        }
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(
                    ColorConstant.bgContent
                        .shadow(.drop(color: .primary.opacity(0.2), radius: 4))
                )
        )
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
    func PhotoGridView() -> some View {
        HStack(spacing: 4) {
            
            ForEach(memory.photos, id: \.self) { photoUrl in
                
                CachedAsyncImage(url: URL(string: photoUrl)) { phase in
                    switch phase {
                    case .success(let image):
                        GeometryReader { let size = $0.size
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: size.width, height: 120)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                                .contentShape(RoundedRectangle(cornerRadius: 8))
                        }
                    case .empty:
                        LoadingView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(ColorConstant.bgSecondary)
                            )
                    case .failure(_ ):
                        Image(systemName: "x.circle")
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        
                    @unknown default:
                        LoadingView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(ColorConstant.bgSecondary)
                            )
                    }
                }
                .frame(height: 120)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(4) 
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
