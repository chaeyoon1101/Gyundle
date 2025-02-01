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
    @State private var isMapExpanded: Bool = false
    
    @State private var selectedMarker: DogWalkingMarker? = nil
    
    @Binding var memory: DogWalkingMemory
    
    var body: some View {
        ZStack {
            Self.background(color: ColorConstant.bgPrimary)
            
            VStack {
                if !isMapExpanded {
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
                    }
                    .padding()
                }
                
                MapView()
                    .clipShape(.rect(cornerRadius: 15))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea(.all)
                    .padding(isMapExpanded ? 0 : 4)
                    .onTapGesture {
                        withAnimation(.snappy(duration: 0.35, extraBounce: 0)) {
                            isMapExpanded = true
                        }
                    }
                    .overlay(alignment: .topTrailing) {
                        if isMapExpanded {
                            Button {
                                withAnimation(.snappy(duration: 0.35, extraBounce: 0)) {
                                    isMapExpanded = false
                                }
                            } label: {
                                Image(systemName: "xmark")
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: 18, height: 18)
                                    .frame(width: 48, height: 48)
                                    .background(.black.opacity(0.7), in: .circle)
                            }
                            .foregroundStyle(.white)
                            .safeAreaPadding(.top, 15)
                            .safeAreaPadding(.trailing, 15)
                        }
                    }
            }
            .navigationTitle(memory.date.formatting("M월 d일 산책"))
            .navigationBarTitleDisplayMode(.inline)
        }
        .toolbarRole(.editor)
        .toolbar(.hidden, for: .tabBar)
        .sheet(item: $selectedMarker, content: { marker in
            DogWalkingMarkingView(marker: marker) { action in
                switch action {
                case .upsert(let marker):
                    memory.markers.update(keyPath: \.id, matching: marker.id, with: marker)
                case .delete(let marker):
                    memory.markers.removeAll(where: { $0.id == marker.id } )
                }
                
                Task {
                    await dogWalkingMemoryViewModel.updateMemory(memory)
                }
            }
            .presentationDetents([.medium, .large])
            .presentationBackgroundInteraction(.enabled(upThrough: .medium))
            .presentationBackground(ColorConstant.bgSecondary)
        })
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
                    text: $memory.title,
                    axis: .vertical
                )
                .font(.system(size: 24))
                .lineLimit(2)
                .focused($isFocused)
                .onChange(of: isFocused) { _, newValue in
                    // 제목이 빈칸일 시 기본 제목으로 설정
                    guard !newValue else { return }
                    
                    if memory.title.isEmpty {
                        memory.title = defaultTitle
                    }
                    
                    Task {
                        await dogWalkingMemoryViewModel.updateMemory(memory)
                    }
                }
                // 키보드 done 버튼 누르면 TextField focus 해제
                .submitLabel(.done)
                .onChange(of: memory.title) { _, newValue in
                    guard isFocused, newValue.contains("\n") else { return }
                    
                    isFocused = false
                    memory.title = newValue.replacing("\n", with: "")
                }
                
                if isFocused {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title)
                        .foregroundStyle(ColorConstant.fgSecondary)
                        .contentShape(.rect)
                        .onTapGesture {
                            memory.title.removeAll()
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
            let coordinates = memory.coordinates.map({ $0.toCLLocationCoordinate2D() })
            if !coordinates.isEmpty {
                MapPolyline(coordinates: coordinates, contourStyle: .geodesic)
                    .stroke(ColorConstant.fgPrimary, lineWidth: 4)
            }
            
            // 산책 메모 마커
            if !memory.markers.isEmpty {
                ForEach(memory.markers) { marker in
                    Annotation("", coordinate: marker.coordinate.toCLLocationCoordinate2D()) {
                        DogWalkingMarkerView(marker: marker)
                            .allowsHitTesting(isMapExpanded)
                            .highPriorityGesture(
                                // iOS 18에서부터 Annotation에 .onTapGesture가 항상
                                // 작동하지 않는 버그 때문에 .highPriorityGesture 사용
                                TapGesture().onEnded({ _ in
                                    selectedMarker = marker
                                })
                            )
                    }
                }
            }
            
            // 산책 시작위치와 종료 위치
            Annotation("", coordinate: coordinates.first ?? .init()) {
                AnnotationView(.start)
            }
            
            Annotation("", coordinate: coordinates.last ?? .init()) {
                AnnotationView(.end)
            }
        }
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
        let latitudes = memory.coordinates.compactMap { Double($0.latitude) }
        let longitudes = memory.coordinates.compactMap { Double($0.longitude) }
        
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
        let hour = Calendar.current.component(.hour, from: memory.date)
        
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
    DogWalkingDetailView(memory: .constant(.defaultMemory()))
        .environmentObject(DogWalkingMemoryViewModel())
}
