import SwiftUI
import MapKit

struct DogWalkingMapView: View {
    @EnvironmentObject private var locationDataManager: LocationDataManager
    @EnvironmentObject private var dogWalkingMemorizeViewModel: DogWalkingMemorizeViewModel
    
    @Namespace var mapScope
    @State private var position: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .automatic
    )
    @State private var showMarkerDetailView: Bool = false
    
    @Binding var isMapExpanded: Bool
    
    
    var body: some View {
        switch locationDataManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            Map(position: $position, scope: mapScope) {
                // 유저 위치
                UserAnnotation()
                
                
                // 산책 중 메모
                ForEach(dogWalkingMemorizeViewModel.dogWalkingMarkers) { marker in
                    Annotation("", coordinate: marker.coordinate.toCLLocationCoordinate2D()) {
                        MarkerView(marker)
                            .highPriorityGesture(
                                // iOS 18에서부터 Annotation에 .onTapGesture가 항상
                                // 작동하지 않는 버그 때문에 .highPriorityGesture 사용
                                TapGesture().onEnded({ _ in
                                    dogWalkingMemorizeViewModel.selectedMarker = marker
                                    showMarkerDetailView = true
                                })
                            )
                    }
                }
        
                
                // 산책했던 길 라인
                if !locationDataManager.coordinates.isEmpty {
                    MapPolyline(
                        coordinates: locationDataManager.coordinates,
                        contourStyle: .geodesic
                    )
                    .stroke(ColorConstant.fgPrimary, lineWidth: 4)
                }
            }
            .mapControlVisibility(.hidden)
            .mapStyle(.standard(elevation: .realistic))
            .overlay(alignment: .topLeading) {
                if isMapExpanded {
                    Button {
                        withAnimation {
                            isMapExpanded = false
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 18, height: 18)
                            .frame(width: 48, height: 48)
                            .background(
                                Circle().fill(.black.opacity(0.7))
                            )
                    }
                    .foregroundStyle(.white)
                    .safeAreaPadding(.top, 48)
                    .safeAreaPadding(.leading, 18)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                MapControls()
            }
            .mapScope(mapScope)
            .onTapGesture {
                if !isMapExpanded {
                    withAnimation {
                        isMapExpanded = true
                    }
                }
            }
            .sheet(isPresented: $showMarkerDetailView) {
                DogWalkingMarkingView()
                    .presentationDetents([.medium, .large])
                    .presentationBackgroundInteraction(.enabled(upThrough: .medium))
                    .presentationBackground(ColorConstant.bgContent)
            }
            
        case .notDetermined, .none:
            ColorConstant.bgContent
        case .restricted, .denied:
            Text("denied or restricted")
        @unknown default:
            Text("unknown")
        }
    }
    
    @ViewBuilder
    private func MarkerView(_ marker: DogWalkingMarker) -> some View {
        ZStack(alignment: .bottom) {
            Path { path in
                path.move(to: CGPoint(x: 16, y: 15))
                path.addLine(to: CGPoint(x: 0, y: -15))
                path.addLine(to: CGPoint(x: 32, y: -15))
                path.closeSubpath()
            }
            .fill(ColorConstant.accent)
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
            .padding(.bottom, 15)
            
            Circle()
                .fill(ColorConstant.accent)
                .frame(width: 32, height: 32)
                .overlay {
                    if let cachedImage = ImageCacheManager.shared.getImage(forKey: marker.id) {
                        cachedImage
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: 28, height: 28)
                            .clipShape(.circle)
                            .contentShape(.circle)
                    }
                }
                .padding(.bottom, 45)
        }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func MapControls() -> some View {
        VStack(alignment: .trailing, spacing: 12) {
            MapPitchToggle(scope: mapScope)
                .mapControlVisibility(.visible)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorConstant.bgPrimary.opacity(0.85))
                )
                .shadow(radius: 8)
            
            MapUserLocationButton(scope: mapScope)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(ColorConstant.bgPrimary.opacity(0.85))
                )
                .shadow(radius: 8)
            
            if isMapExpanded {
                MapCompass(scope: mapScope)
                
                MapScaleView(scope: mapScope)
            }
        }
        .safeAreaPadding(.all)
    }
}

#Preview {
    DogWalkingMemorizeView(date: .init())
        .environmentObject(DogWalkingMemoryViewModel())
}
