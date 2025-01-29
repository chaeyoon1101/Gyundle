import SwiftUI
import MapKit

struct DogWalkingMemoryView: View {
    @EnvironmentObject private var dogWalkingMemoryViewModel: DogWalkingMemoryViewModel
    
    var date: Date
    
    var body: some View {
        if let memories = dogWalkingMemoryViewModel.getMemories(from: date) {
            HeaderView()
                .padding(.bottom, -20)

            let _ = print(memories.map { $0.title }, "View")
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(memories, id: \.uid) { memory in
                        CardView(memory: memory)
                            .onTapGesture {
                                dogWalkingMemoryViewModel.selectedMemory = memory
                                dogWalkingMemoryViewModel.showDetailView = true
                            }
                    }
                }
                .scrollTargetLayout()
            }
            .scrollClipDisabled()
            .scrollTargetBehavior(.viewAligned)
        }
    }
    
    @ViewBuilder
    private func CardView(memory: DogWalkingMemory) -> some View {
        VStack {
            HStack(spacing: 15) {
                MapView(memory: memory)
                    .frame(width: 64, height: 64)
                    .clipShape(.rect(cornerRadius: 8))
                
                VStack(alignment: .leading) {
                    Text(memory.title)
                        .font(.system(size: 18))
                    Text(memory.date.formatting("aa h:mm"))
                        .font(.footnote)
                        .foregroundStyle(ColorConstant.fgSecondary)
                }
            }
            .align(.topLeading)
            
            HStack(spacing: 15) {
                VStack(alignment: .leading) {
                    Text(memory.distance)
                        .font(.system(size: 24)).bold()
                        .lineLimit(1)
                    
                    Text("KM")
                        .font(.subheadline)
                        .foregroundStyle(ColorConstant.fgSecondary)
                }
                .align(.leading)
                
                VStack(alignment: .leading) {
                    Text(memory.calories)
                        .font(.system(size: 24)).bold()
                        .lineLimit(1)
                    
                    Text("Kcal")
                        .font(.subheadline)
                        .foregroundStyle(ColorConstant.fgSecondary)
                }
                .align(.leading)
                
                VStack(alignment: .leading) {
                    Text(memory.time)
                        .font(.system(size: 24)).bold()
                        .lineLimit(1)
                    
                    Text("시간")
                        .font(.subheadline)
                        .foregroundStyle(ColorConstant.fgSecondary)
                }
                .align(.leading)
            }
            .padding([.top, .trailing], 20)
            .align(.topLeading)
        }
        .padding()
        .containerRelativeFrame(.horizontal)
        .frame(height: 180)
        .background(
            ColorConstant.bgContent
                .shadow(.drop(color: .primary.opacity(0.2), radius: 2)),
            in: .rect(cornerRadius: 15)
        )
    }
    
    @ViewBuilder
    private func MapView(memory: DogWalkingMemory) -> some View {
        let cameraPosition = getCameraPosition(coordinates: memory.coordinates)
        
        Map(initialPosition: cameraPosition, interactionModes: []) {
            if !memory.coordinates.isEmpty {
                let coordinates = memory.coordinates.map { $0.toCLLocationCoordinate2D() }
                
                MapPolyline(coordinates: coordinates, contourStyle: .geodesic)
                    .stroke(ColorConstant.fgPrimary, lineWidth: 4)
            }
        }
    }
    
    @ViewBuilder
    private func HeaderView() -> some View {
        HStack {
            Image(systemName: "dog.fill")
                .imageScale(.medium)
            
            Text("산책 기록")
                .font(.headline)
                .bold()
            
            Spacer()
        }
        .padding(.leading)
    }
    
    private func getCameraPosition(coordinates: [Coordinate]) -> MapCameraPosition {
        let latitudes = coordinates.compactMap { Double($0.latitude) }
        let longitudes = coordinates.compactMap { Double($0.longitude) }
        
        let minLatitude = latitudes.min() ?? 0
        let maxLatitude = latitudes.max() ?? 0
        let minLongitude = longitudes.min() ?? 0
        let maxLongitude = longitudes.max() ?? 0
        
        
        // 카메라 중심점
        let center = CLLocationCoordinate2D(
            latitude: (minLatitude + maxLatitude) / 2,
            longitude: (minLongitude + maxLongitude) / 2
        )
        
        
        // 여유 간격
        let span = MKCoordinateSpan(
            latitudeDelta: (maxLatitude - minLatitude) * 1.75,
            longitudeDelta: (maxLongitude - minLongitude) * 1.75
        )
        
        return MapCameraPosition.region(
            .init(center: center, span: span)
        )
    }
}

#Preview {
    HomeView()
}
