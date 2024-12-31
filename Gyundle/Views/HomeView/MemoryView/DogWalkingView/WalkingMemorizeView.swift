import SwiftUI

struct WalkingMemorizeView: View {
    @EnvironmentObject private var calendarViewModel: CalendarViewModel
    @EnvironmentObject private var memoryViewModel: MemoryViewModel
    
//    @StateObject private var imageViewModel = PhotoViewModel()
    @StateObject var locationDataManager = LocationDataManager()
    
    @Binding var isPresented: Bool
    
    var startTime: Date = Date()
    
    var body: some View {
        NavigationView {
            VStack {
                MapView()
                    .environmentObject(locationDataManager)
                    .frame(height: 250)
                
                VStack {
                    Button {
                        Task {
                            await uploadMemory()
                        }
                    } label: {
                        Image(systemName: "square.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .opacity(0.8)
                            .frame(width: 24, height: 24)
                    }
                    .buttonStyle(WalkingMemoryButtonStyle())
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        isPresented = false
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(ColorConstant.fgPrimary)
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        
                    } label: {
//                        if imageViewModel.isUploading {
//                            ProgressView()
//                        } else {
//                            Text("완료")
//                                .foregroundStyle(ColorConstant.fgPrimary)
//                        }
                    }
                }
            }
        }
    }
    
    private func uploadMemory() async {
        let date = calendarViewModel.selectedDate
        let id = date.toDay()
        let endTime = Date()
        let coordinates = locationDataManager.coordinates.map { $0.toCoordinate() }
        
        let memory = DogWalkingMemory(id: id, date: date, startTime: startTime, endTime: endTime, coordinates: coordinates)
        
//        memoryViewModel.uploadMemory(memory: memory)
        
        locationDataManager.stopUpdatingLocation()
    }
}

#Preview {
    WalkingMemorizeView(isPresented: .constant(true))
        .environmentObject(CalendarViewModel())
        .environmentObject(MemoryViewModel())
}
