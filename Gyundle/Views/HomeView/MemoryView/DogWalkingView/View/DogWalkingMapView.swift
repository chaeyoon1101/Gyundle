import SwiftUI
import MapKit

struct DogWalkingMapView: View {
    @EnvironmentObject private var locationDataManager: LocationDataManager
    
    @Namespace var mapScope
    @State private var position: MapCameraPosition = .userLocation(
        followsHeading: true,
        fallback: .automatic
    )
    
    @Binding var isMapExpanded: Bool
    
    var body: some View {
        switch locationDataManager.authorizationStatus {
        case .authorizedAlways, .authorizedWhenInUse:
            Map(position: $position, scope: mapScope) {
                UserAnnotation()
                
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
            
        case .notDetermined, .none:
            ColorConstant.bgContent
        case .restricted, .denied:
            Text("denied or restricted")
        @unknown default:
            Text("unknown")
        }
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
    DogWalkingMemorizeView()
        .environmentObject(DogWalkingMemoryViewModel())
}
