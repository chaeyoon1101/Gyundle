//
//  DogWalkingSummaryView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/23/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct DogWalkingSummaryView: View {
    @Environment(\.dismiss) var dismiss
    
    @EnvironmentObject private var dogWalkingMemoryViewModel: DogWalkingMemoryViewModel

    @FocusState var isFocused: Bool
    @Binding var memory: DogWalkingMemory
    
    var body: some View {
        ZStack {
            Self.background(color: ColorConstant.bgPrimary)
            
            VStack(alignment: .leading) {
                TitleTextField()
                
                Text(memory.time)
                    .font(.system(size: 64, weight: .bold))
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
            .padding()
        }
        .onTapGesture {
            isFocused = false
        }
        .ignoresSafeArea(.keyboard)
        .toolbarRole(.editor)
        .navigationTitle("추가 정보 입력")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if !dogWalkingMemoryViewModel.isUploading {
                    Button("완료") {
                        Task {
                            await dogWalkingMemoryViewModel.uploadMemory(memory, onSuccess: {
                                dogWalkingMemoryViewModel.showMemorizeView = false
                            })
                        }
                    }
                    .foregroundStyle(ColorConstant.accent)
                    .bold()
                } else {
                    ProgressView()
                }
            }
        }
        .toastView(
            isShowing: $dogWalkingMemoryViewModel.showError,
            message: dogWalkingMemoryViewModel.errorMessage
        )
    }
    
    @ViewBuilder
    private func TitleTextField() -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("제목")
                .font(.subheadline)
                .foregroundStyle(ColorConstant.fgSecondary)
            
            HStack {
                TextField("", text: $memory.title, axis: .vertical)
                    .font(.system(size: 24))
                    .lineLimit(2)
                    .focused($isFocused)
                    .onChange(of: isFocused, initial: true) { _, newValue in
                        // 제목이 빈칸일 시 기본 제목으로 설정
                        guard !newValue else { return }
                        
                        if memory.title.isEmpty {
                            memory.title = defaultTitle
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
                            memory.title = ""
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
        let position = MapCameraPosition.getCameraPosition(for: memory.coordinates)
        
        Map(initialPosition: position) {
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
                    }
                }
            }
            
            // 산책 시작위치와 종료 위치
            Annotation("", coordinate: coordinates.first ?? .init()) {
                DogWalkingAnnotation(annotationType: .start)
            }
            
            Annotation("", coordinate: coordinates.last ?? .init()) {
                DogWalkingAnnotation(annotationType: .end)
            }
        }
    }
    
    private var defaultTitle: String {
        let date = Date()
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
    DogWalkingSummaryView(memory: .constant(.defaultMemory()))
        .environmentObject(DogWalkingMemoryViewModel())
}
