import SwiftUI
import MapKit

struct DogWalkingMemorizeView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var dogWalkingMemoryViewModel: DogWalkingMemoryViewModel
    
    @StateObject private var dogWalkingMemorizeViewModel = DogWalkingMemorizeViewModel()
    @StateObject private var locationDataManager = LocationDataManager()
    
    @State private var isStopped: Bool = false
    @State private var isMapExpanded: Bool = false
    @State private var showMarkingView: Bool = false
    
    @State var memory: DogWalkingMemory = .defaultMemory()
    let date: Date
    
    var body: some View {
        NavigationStack {
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
                                    setupMemory()
                                    isStopped = true
                                })
                                
                                DogWalkingMarkingButton()
                            }
                            .frame(maxHeight: .infinity, alignment: .center)
                        }
                        .align(.top)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(ColorConstant.bgSecondary)
                                .ignoresSafeArea()
                        )
                        .padding(.horizontal, 4)
                    }
                }
            }
            .onChange(of: isStopped, initial: true) { _, newValue in
                if newValue {
                    locationDataManager.stopUpdatingLocation()
                } else {
                    locationDataManager.startUpdatingLocation()
                }
            }
            .onReceive(dogWalkingMemorizeViewModel.timerPublisher) { _ in
                dogWalkingMemorizeViewModel.timeSeconds += 1
                
                dogWalkingMemorizeViewModel.updateDogWalkingData(
                    totalDistance: locationDataManager.totalDistance
                )
            }
            .sheet(isPresented: $showMarkingView) {
                let coordinate = locationDataManager.currentLocation?.coordinate.toCoordinate()
                
                let marker = DogWalkingMarker(coordinate: coordinate ?? .init())
                
                DogWalkingMarkingView(marker: marker) { action in
                    switch action {
                    case .upsert(let marker):
                        dogWalkingMemorizeViewModel.upsertMarker(marker)
                    case .delete(let marker):
                        dogWalkingMemorizeViewModel.deleteMarker(marker)
                    }
                }
                .presentationDetents([.medium, .large])
                .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                .presentationBackground(ColorConstant.bgSecondary)
            }
            .navigationDestination(isPresented: $isStopped) {
                DogWalkingSummaryView(memory: $memory)
            }
            .toolbar(.hidden, for: .navigationBar)
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
                VStack {
                    Text(dogWalkingMemorizeViewModel.dogWalkingDistance + "km")
                        .font(.title3)
                        .bold()
                    
                    Text("산책 거리")
                        .font(.subheadline)
                        .foregroundStyle(ColorConstant.fgSecondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text(dogWalkingMemorizeViewModel.dogWalkingSpeed + "km/h")
                        .font(.title3)
                        .bold()
                    
                    Text("산책 속도")
                        .font(.subheadline)
                        .foregroundStyle(ColorConstant.fgSecondary)
                }
                .frame(maxWidth: .infinity)
                
                VStack {
                    Text(dogWalkingMemorizeViewModel.dogWalkingCalories + "kcal")
                        .font(.title3)
                        .bold()
                    
                    Text("칼로리 소모")
                        .font(.subheadline)
                        .foregroundStyle(ColorConstant.fgSecondary)
                }
                .frame(maxWidth: .infinity)
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
            showMarkingView = true
        } label: {
            Image(systemName: "square.and.pencil")
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(ColorConstant.accent)
                .frame(width: 40, height: 40)
                .frame(width: 92, height: 92)
                .background(
                    Circle()
                        .strokeBorder(
                            ColorConstant.accent,
                            style: .init(lineWidth: 2, lineCap: .round, lineJoin: .round)
                        )
                )
        }
    }
    
    private func setupMemory() {
        let uid = memory.uid
        let day = date.toDay()
        let date = memory.date
        let title = memory.title
        let coordinates = locationDataManager.coordinates.map { $0.toCoordinate() }
        
        memory = DogWalkingMemory(
            uid: uid,
            day: day,
            date: date,
            dogs: [],
            title: title,
            time: dogWalkingMemorizeViewModel.dogWalkingTime,
            distance: dogWalkingMemorizeViewModel.dogWalkingDistance,
            speed: dogWalkingMemorizeViewModel.dogWalkingSpeed,
            calories: dogWalkingMemorizeViewModel.dogWalkingCalories,
            coordinates: coordinates,
            markers: dogWalkingMemorizeViewModel.dogWalkingMarkers
        )
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

