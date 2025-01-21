import SwiftUI

struct DogWalkingMemorizeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dogWalkingMemoryViewModel: DogWalkingMemoryViewModel
    
    @StateObject private var dogWalkingMemorizeViewModel = DogWalkingMemorizeViewModel()
    @StateObject private var locationDataManager = LocationDataManager()
    
    @State private var isMapExpanded: Bool = false
    @State private var showMarkingView: Bool = false
    
    let date: Date
    
    var body: some View {
        ZStack {
            Self.background(color: ColorConstant.bgPrimary)
            
            VStack {
                DogWalkingMapView(isMapExpanded: $isMapExpanded)
                    .ignoresSafeArea()
                    .frame(maxHeight: .infinity)
                
                if !isMapExpanded {
                    VStack(spacing: 15) {
                        DogWalkingDataView()
                        
                        HStack(spacing: 45) {
                            DogWalkingStopButton(onStopped: {
                                uploadMemorize()
                            })
                            
                            DogWalkingMarkingButton()
                        }
                        .frame(maxHeight: .infinity, alignment: .center)
                    }
                    .frame(maxHeight: .infinity, alignment: .top)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(ColorConstant.bgSecondary)
                            .ignoresSafeArea()
                    )
                    .padding(.horizontal, 4)
                }
            }
            // TODO: progressView 보여줄건지 고민
            .progressView(isShowing: $dogWalkingMemoryViewModel.isUploading)
            .onReceive(dogWalkingMemorizeViewModel.timerPublisher) { _ in
                dogWalkingMemorizeViewModel.timeSeconds += 1
                
                dogWalkingMemorizeViewModel.updateDogWalkingData(
                    totalDistance: locationDataManager.totalDistance
                )
            }
            .sheet(isPresented: $showMarkingView) {
                DogWalkingMarkingView(isEditing: true)
                    .presentationDetents([.medium, .large])
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .presentationBackground(ColorConstant.bgContent)
            }
        }
        .environmentObject(dogWalkingMemorizeViewModel)
        .environmentObject(locationDataManager)
    }
    
    @ViewBuilder
    private func DogWalkingDataView() -> some View {
        VStack {
            VStack {
                Text(dogWalkingMemorizeViewModel.dogWalkingTime)
                    .font(.system(size: 56))
                    .bold()
                
                Text("산책 시간")
                    .font(.subheadline)
                    .foregroundStyle(ColorConstant.fgSecondary)
            }
            .padding(.bottom, 30)
            
            HStack {
                DogWalkingDataContent(data: dogWalkingMemorizeViewModel.dogWalkingDistance, subtitle: "산책 거리")
                
                DogWalkingDataContent(data: dogWalkingMemorizeViewModel.dogWalkingSpeed, subtitle: "산책 속도")
                
                DogWalkingDataContent(data: dogWalkingMemorizeViewModel.dogWalkingCalories, subtitle: "칼로리 소모량")
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
    }
    
    @ViewBuilder
    private func DogWalkingDataContent(data: String, subtitle: String) -> some View {
        VStack {
            Text(data)
                .font(.title3)
                .bold()
            
            Text(subtitle)
                .font(.subheadline)
                .foregroundStyle(ColorConstant.fgSecondary)
        }
        .frame(maxWidth: .infinity)
    }
    
    @ViewBuilder
    private func DogWalkingMarkingButton() -> some View {
        Button {
            dogWalkingMemorizeViewModel.selectedMarker = DogWalkingMarker(
                coordinate: locationDataManager.currentLocation?.coordinate.toCoordinate() ?? .init(),
                memo: ""
            )
            
            showMarkingView = true
        } label: {
            Image(systemName: "square.and.pencil")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(ColorConstant.fgPrimary)
                .frame(width: 40, height: 40)
                .frame(width: 92, height: 92)
                .background(
                    Circle()
                        .strokeBorder(ColorConstant.fgPrimary, style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round))
                )
        }
    }
    
    private func uploadMemorize() {
        let coordinates = locationDataManager.coordinates.map { $0.toCoordinate() }
        dogWalkingMemoryViewModel.selectedMemory?.coordinates = coordinates
        dogWalkingMemoryViewModel.selectedMemory?.day = date.toDay()
        dogWalkingMemoryViewModel.selectedMemory?.endTime = Date()
        dogWalkingMemoryViewModel.selectedMemory?.calories = dogWalkingMemorizeViewModel.dogWalkingCalories
        dogWalkingMemoryViewModel.selectedMemory?.distance = dogWalkingMemorizeViewModel.dogWalkingDistance
        dogWalkingMemoryViewModel.selectedMemory?.markers = dogWalkingMemorizeViewModel.dogWalkingMarkers
        
        Task {
            await dogWalkingMemoryViewModel.uploadMemory()
            
            await MainActor.run {
                Haptic.notification(type: .success)
                dismiss()
            }
        }
    }
}

fileprivate struct DogWalkingFunctionsButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(width: 20, height: 20)
            .frame(width: 60, height: 60)
            .background(
                Circle()
                    .fill(ColorConstant.bgContent)
                    .strokeBorder(ColorConstant.fgPrimary, lineWidth: 2)
            )
            .opacity(configuration.isPressed ? 0.5 : 1)
    }
}

#Preview {
    DogWalkingMemorizeView(date: .init())
        .environmentObject(DogWalkingMemoryViewModel())
}

