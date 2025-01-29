//
//  DogWalkingDetailView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/27/25.
//

import SwiftUI
import MapKit

struct DogWalkingDetailView: View {
    @EnvironmentObject private var dogWalkingMemoryViewModel: DogWalkingMemoryViewModel
    @FocusState var isFocused: Bool
    
    var body: some View {
        ZStack {
            Self.background(color: ColorConstant.bgPrimary)
            
            if let memory = dogWalkingMemoryViewModel.selectedMemory {
                VStack(alignment: .leading) {
                    TitleTextField()
                    
                    VStack(alignment: .leading, spacing: 0) {
                        Text(memory.time)
                            .font(.system(size: 64, weight: .bold))
                        
                        Text(getDogWalkingTime(start: memory.date, for: memory
                            .time))
                            .font(.subheadline)
                            .foregroundStyle(ColorConstant.fgSecondary)
                    }
                    .padding(.bottom, 15)
                    
                    HStack {
                        VStack(alignment: .leading) {
                            Text(memory.distance + "km")
                                .font(.title3)
                                .bold()
                            
                            Text("산책 거리")
                                .font(.subheadline)
                                .foregroundStyle(ColorConstant.fgSecondary)
                        }
                        .align(.leading)
                        
                        VStack(alignment: .leading) {
                            Text(memory.calories + "kcal")
                                .font(.title3)
                                .bold()
                            
                            Text("칼로리")
                                .font(.subheadline)
                                .foregroundStyle(ColorConstant.fgSecondary)
                        }
                        .align(.leading)
                        
                        VStack(alignment: .leading) {
                            Text(memory.speed + "km/h")
                                .font(.title3)
                                .bold()
                            
                            Text("산책 속도")
                                .font(.subheadline)
                                .foregroundStyle(ColorConstant.fgSecondary)
                        }
                        .align(.leading)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.trailing, 30)
                    .padding(.bottom, 15)
                    
                    MapView()
                        .clipShape(.rect(cornerRadius: 15))
                        .frame(maxHeight: .infinity)
                }
                .navigationTitle(memory.date.formatting("M월 d일 산책"))
                .navigationBarTitleDisplayMode(.inline)
                .padding()
            }
        }
        .toolbarRole(.editor)
        .toolbar(.hidden, for: .tabBar)

    }
    
    @ViewBuilder
    private func TitleTextField() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("제목")
                .font(.subheadline)
                .foregroundStyle(ColorConstant.fgSecondary)
            
            HStack {
                TextField(
                    "",
                    text: Binding(get: {
                        dogWalkingMemoryViewModel.selectedMemory?.title ?? ""
                    }, set: { newValue in
                        dogWalkingMemoryViewModel.selectedMemory?.title = newValue
                    }),
                    axis: .vertical
                )
                .font(.system(size: 24))
                .lineLimit(2)
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    guard !newValue,
                          let title = dogWalkingMemoryViewModel.selectedMemory?.title else { return }
                    
                    if title.isEmpty {
                        dogWalkingMemoryViewModel.selectedMemory?.title = defaultTitle
                    }
                    
                    Task {
                        await dogWalkingMemoryViewModel.updateMemory()
                    }
                }
                // 키보드 done 버튼 누르면 TextField focus 해제
                .submitLabel(.done)
                .onChange(of: dogWalkingMemoryViewModel.selectedMemory?.title) { _, newValue in
                    guard isFocused else { return }
                    guard let title = newValue, title.contains("\n") else { return }
                    
                    isFocused = false
                    dogWalkingMemoryViewModel.selectedMemory?.title = title.replacing("\n", with: "")
                }
                
                if isFocused {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(ColorConstant.fgSecondary)
                        .contentShape(.rect)
                        .onTapGesture {
                            dogWalkingMemoryViewModel.selectedMemory?.title = ""
                        }
                } else {
                    Image(systemName: "pencil")
                        .font(.title)
                        .foregroundStyle(ColorConstant.fgPrimary)
                        .contentShape(.rect)
                        .onTapGesture {
                            isFocused = true
                        }
                }
            }
        }
        
        RoundedRectangle(cornerRadius: 8)
            .fill(ColorConstant.fgSecondary.opacity(0.5))
            .frame(height: 2)
    }
    
    @ViewBuilder
    private func MapView() -> some View {
        // TODO: 시작 위치와 끝난 위치 보여주기 coordinates.first, last
        Map(initialPosition: getCameraPosition()) {
            
            // 산책 이동 위치
            let coordinates = dogWalkingMemoryViewModel.selectedMemory?.coordinates.compactMap({ $0.toCLLocationCoordinate2D() })
            if let coordinates, !coordinates.isEmpty {
                MapPolyline(coordinates: coordinates, contourStyle: .geodesic)
                    .stroke(ColorConstant.fgPrimary, lineWidth: 4)
            }
            
            // 산책 메모 마커
            if let markers = dogWalkingMemoryViewModel.selectedMemory?.markers {
                ForEach(markers) { marker in
                    Annotation("", coordinate: marker.coordinate.toCLLocationCoordinate2D()) {
                        MarkerView(marker)
                    }
                }
            }
            
            // 산책 시작위치와 종료 위치
            Annotation("", coordinate: coordinates?.first ?? .init()) {
                AnnotationView(.start)
            }
            
            Annotation("", coordinate: coordinates?.last ?? .init()) {
                AnnotationView(.end)
            }
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
            .padding(.bottom, 20)
            
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
                .padding(.bottom, 50)
        }
        .contentShape(Rectangle())
    }
    
    @ViewBuilder
    private func AnnotationView(_ annotation: AnnotationType) -> some View {
        ZStack(alignment: .bottom) {
            Path { path in
                path.move(to: CGPoint(x: 16, y: 15))
                path.addLine(to: CGPoint(x: 0, y: -15))
                path.addLine(to: CGPoint(x: 32, y: -15))
                path.closeSubpath()
            }
            .fill(annotation.color)
            .frame(width: 32, height: 32)
            .contentShape(Rectangle())
            .padding(.bottom, 20)
            
            Circle()
                .fill(annotation.color)
                .frame(width: 32, height: 32)
                .overlay {
                    Text(annotation.stringValue)
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundStyle(.white)
                }
                .padding(.bottom, 50)
        }
        .contentShape(Rectangle())
    }
    
    private func getCameraPosition() -> MapCameraPosition {
        guard let coordinates = dogWalkingMemoryViewModel.selectedMemory?.coordinates else {
            return .automatic
        }
        
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
    
    private func getDogWalkingTime(start: Date, for time: String) -> String {
        var timeSeconds: TimeInterval = 0
        var timeMultiplier = 1.0
        
        for timeString in time.split(separator: ":").reversed() {
            if let timeValue = Double(String(timeString)) {
                timeSeconds += timeValue * timeMultiplier
            }
            timeMultiplier *= 60
        }
        
        let end = start.addingTimeInterval(timeSeconds)
        
        let startString = start.formatting("aa h:mm")
        let endString = end.formatting("aa h:mm")
        
        return "\(startString) ~ \(endString)"
    }
    
    private var defaultTitle: String {
        let date = dogWalkingMemoryViewModel.selectedMemory?.date ?? Date()
        let hour = Calendar.current.component(.hour, from: date)
        
        return switch hour {
        case 0...6:
            "집 앞 새벽 산책"
        case 7...10:
            "집 앞 아침 산책"
        case 11...14:
            "집 앞 점심 산책"
        case 15...18:
            "집 앞 오후 산책"
        case 19...23:
            "집 앞 저녁 산책"
        default:
            "집 앞 오후 산책"
        }
    }
}

#Preview {
    let vm = DogWalkingMemoryViewModel()
    let _ = vm.selectedMemory = DogWalkingMemory.defaultMemory()
    
    DogWalkingDetailView()
        .environmentObject(vm)
}
