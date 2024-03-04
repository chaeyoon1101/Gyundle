import SwiftUI
import PhotosUI

struct DailyMemorizeView: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
    @StateObject private var imageViewModel = ImageViewModel()
    
    @Binding var isPresented: Bool
    
    @State private var enteredText: String = ""
    @State private var enteredPhotos: [Image] = []

    @State var selectedItems: [PhotosPickerItem] = []
    
    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack {      
                    ScrollView(.vertical) {
                        if !enteredPhotos.isEmpty {
                            HStack(spacing: 4) {
                                ForEach(0..<enteredPhotos.count, id: \.self) { index in
                                    let size = geometry.size.width / Double(enteredPhotos.count) - 4
                                    DailyMemoryPhoto(
                                        photos: $enteredPhotos,
                                        index: index,
                                        size: size
                                    )
                                }
                            }
                        }
                        
                        DailyMemoryTextEditor(enteredText: $enteredText)
                    }
                    Spacer()
                    
                    bottomBar
                }
                .navigationTitle("\(selectedDateToString())의 기억")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            isPresented = false
                        } label: {
                            Image(systemName: "xmark")
                                .foregroundStyle(.fg)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarTrailing) {
                        Button {
                            Task {
                                await uploadMemory()
                            }
                        } label: {
                            if imageViewModel.isUploading {
                                ProgressView()
                            } else {
                                Text("완료")
                                    .foregroundStyle(.fg)
                            }
                        }
                    }
                }
            }
        }
        .disabled(imageViewModel.isUploading)
    }
    
    private func uploadMemory() async {
        let date = calendarViewModel.selectedDate
        let text = enteredText.replacingOccurrences(of: "\n", with: "\\n")
        let id = date.toDay()
        var photos = [String]()
        
        if selectedItems.isEmpty {
            let memory = DailyMemory(id: id, date: date, text: text, photos: photos)
            memoryViewModel.uploadDailyMemory(memory: memory)
        } else {
            for item in selectedItems {
                if let data = try? await item.loadTransferable(type: Data.self) {
                    if let image = UIImage(data: data) {
                        imageViewModel.uploadImage(image) { result in
                            switch result {
                            case .success(let url):
                                photos.append(url.absoluteString)
                                
                                if photos.count == selectedItems.count {
                                    let memory = DailyMemory(id: id, date: date, text: text, photos: photos)
                                    memoryViewModel.uploadDailyMemory(memory: memory)
                                    
                                    isPresented = false
                                }
                            case .failure(let error):
                                print(error)
                            }
                        }
                    }
                }
            }
        }
    }
    
    private var bottomBar: some View {
        HStack(alignment: .top) {
            PhotosPicker(selection: $selectedItems, maxSelectionCount: 3, matching: .any(of: [.images, .not(.videos)])) {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24)
                    .foregroundStyle(.fg)
            }
            .padding(.leading, 24)
            .onChange(of: selectedItems) { _, newItems in
                Task {
                    var photos: [Image] = []
                    
                    for newItem in newItems {
                        if let image = try? await newItem.loadTransferable(type: Image.self) {
                            photos.append(image)
                        }
                    }
                    
                    enteredPhotos = photos
                }
            }
            
            Spacer()
        }
        .frame(height: 48)
        .background(Color.sc)
    }
    
    private func selectedDateToString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "M월 d일"
       
        let date = calendarViewModel.selectedDate
        
        return dateFormatter.string(from: date)
    }
}

#Preview {
    DailyMemorizeView(isPresented: .constant(true))
        .environmentObject(CalendarViewModel())
}
