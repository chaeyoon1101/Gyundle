import SwiftUI
import Kingfisher

struct DailyMemoryView: View {
    var memory: DailyMemory
    
    @State private var isShowingFullText: Bool = false
    
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
            
            GeometryReader { geometry in
                VStack(alignment: .leading) {
                    HStack(spacing: 4) {
                        let size = geometry.size.width / 3 - 4
                        ForEach(memory.photos, id: \.self) { photoURL in
                            KFImage(URL(string: photoURL))
                                .resizable()
                                .frame(width: size, height: size)
                                .frame(maxHeight: geometry.size.width / 3 - 4)
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }
                    }
                    .padding(4)
                    
                    VStack {
                        Text(memory.text)
                            .lineLimit(isShowingFullText ? nil : 4)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding([.horizontal, .bottom])
                    }
                    .onTapGesture {
                        withAnimation {
                            isShowingFullText.toggle()
                        }
                    }
                    
                    Divider()
                    
                    VStack {
                        Text(memory.date.toString())
                    }
                    .padding(8)
                }
                .background(Color.gray)
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .onTapGesture {
                    withAnimation {
                        isShowingFullText.toggle()
                    }
                }
            }.aspectRatio(contentMode: .fill)
        }
        .padding(.horizontal, 8)
    }
    
}
