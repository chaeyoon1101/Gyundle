//
//  DogWalkingMemorizeViewModel.swift
//  Gyundle
//
//  Created by 임채윤 on 1/14/25.
//

import SwiftUI
import CoreLocation

final class DogWalkingMemorizeViewModel: ObservableObject {
    // MARK: View Properties
    @Published var dogWalkingTime: String = "00:00"
    @Published var dogWalkingDistance: String = "0.00km"
    @Published var dogWalkingSpeed: String = "0km/h"
    @Published var dogWalkingCalories: String = "0.0kcal"
    
    // Marker
    @Published var dogWalkingMarkers: [DogWalkingMarker] = []
    @Published var selectedMarker: DogWalkingMarker?
    
    
    // MARK: Sheet Present Properties
    @Published var showMarkingView: Bool = false
    @Published var showMarkerDetailView: Bool = false
    
    
    // MARK: Timer
    let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var timeSeconds: Int = 0
    
    @MainActor
    func updateDogWalkingData(totalDistance: Double) {
        dogWalkingTime = convertSecondsToTime()
        dogWalkingDistance = String(format: "%.2fkm", totalDistance / 1000)
        dogWalkingSpeed = String(format: "%.1fkm/h", (totalDistance / 1000) / (Double(timeSeconds) / 3600))
        dogWalkingCalories = calculateCalories(totalDistance: totalDistance)
    }
    
    func addMarker(image: UIImage?) {
        guard let selectedMarker else { return }
        
        dogWalkingMarkers.append(selectedMarker)
        
        // 이미지가 있다면 Cache에 저장을 먼저해서 이미지를 다시 받아오지 않게 하기
        // 이후에 비동기로 Firebase에 업로드 후 photoURL 데이터를 새로 저장
        if let image {
            DispatchQueue.main.async {
                ImageCacheManager.shared.setImage(Image(uiImage: image), forKey: selectedMarker.id)
            }
            
            Task {
                if let imageData = image.jpegData(compressionQuality: 0.5) {
                    let downloadURL = try await FirebaseManager.shared.uploadPhoto(with: imageData, to: PhotoStorage.dogWalkingMemory.folderName)
                    
                    await MainActor.run {
                        if let index = dogWalkingMarkers.firstIndex(where: { $0.id == selectedMarker.id }) {
                            dogWalkingMarkers[index].imageURL = downloadURL
                        }
                    }
                }
            }
        }
        
        self.selectedMarker = nil
    }

    func removeMarker(_ marker: DogWalkingMarker) {
        withAnimation(.snappy) {
            dogWalkingMarkers.removeAll(where: { $0.id == marker.id })
        }
    }
    
    private func calculateCalories(totalDistance: Double) -> String {
        let weight = UserManager.shared.user?.weight ?? 5
        let dogWalkingTime = Double(timeSeconds) / 3600
        let dogWalkingMets = 3.0

        let calcories = weight * dogWalkingTime * dogWalkingMets
        return String(format: "%.1fkcal", calcories)
    }
    
    private func convertSecondsToTime() -> String {
        let hours = timeSeconds / 3600
        let minutes = (timeSeconds - hours * 3600) / 60
        let seconds = timeSeconds % 60
        
        if hours > 0 {
            return String(format: "%02i:%02i:%02i", hours, minutes, seconds)
        } else {
            return String(format: "%02i:%02i", minutes, seconds)
        }
    }
}
