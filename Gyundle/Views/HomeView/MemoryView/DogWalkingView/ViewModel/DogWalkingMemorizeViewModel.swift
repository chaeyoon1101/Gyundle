//
//  DogWalkingMemorizeViewModel.swift
//  Gyundle
//
//  Created by 임채윤 on 1/14/25.
//

import SwiftUI

final class DogWalkingMemorizeViewModel: ObservableObject {
    // MARK: View Properties
    @Published var dogWalkingTime: String = "00:00"
    @Published var dogWalkingDistance: String = "0.00"
    @Published var dogWalkingSpeed: String = "0"
    @Published var dogWalkingCalories: String = "0.0"
    
    // Marker
    @Published var dogWalkingMarkers: [DogWalkingMarker] = []
    @Published var selectedMarker: DogWalkingMarker?
    
    
    // MARK: Timer
    let timerPublisher = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    var timeSeconds: Int = 0
    
    @MainActor
    func updateDogWalkingData(totalDistance: Double) {
        dogWalkingTime = convertSecondsToTime()
        dogWalkingDistance = String(format: "%.2f", totalDistance / 1000)
        dogWalkingSpeed = String(format: "%.1f", (totalDistance / 1000) / (Double(timeSeconds) / 3600))
        dogWalkingCalories = calculateCalories()
    }
    
    func addMarker(image: UIImage?) {
        guard let selectedMarker else { return }
        
        dogWalkingMarkers.append(selectedMarker)
        
        if let image {
            uploadImageAsync(image: image, marker: selectedMarker)
        }
        
        self.selectedMarker = nil
    }

    func updateMarker(image: UIImage?) {
        guard let selectedMarker else { return }
        
        dogWalkingMarkers = dogWalkingMarkers.map {
            $0.id == selectedMarker.id ? selectedMarker : $0
        }
        
        if let image {
            uploadImageAsync(image: image, marker: selectedMarker)
        }
        
        self.selectedMarker = nil
    }
    
    func removeMarker() {
        guard let selectedMarker else {
            print("선택된 Marker가 없음")
            return
        }
        
        withAnimation(.snappy) {
            dogWalkingMarkers.removeAll(where: { $0.id == selectedMarker.id })
        }
        
        self.selectedMarker = nil
    }
    
    // 이미지가 있다면 Cache에 저장을 먼저해서 이미지를 다시 받아오지 않게 하기
    // 이후에 비동기로 Firebase에 업로드 후 photoURL 데이터를 새로 저장
    private func uploadImageAsync(image: UIImage, marker: DogWalkingMarker) {
        Task {
            DispatchQueue.main.async {
                ImageCacheManager.shared.setImage(Image(uiImage: image), forKey: marker.id)
            }
            
            if let imageData = image.jpegData(compressionQuality: 0.5) {
                let downloadURL = try await FirebaseManager.shared.uploadPhoto(with: imageData, to: PhotoStorage.dogWalkingMemory.folderName)
                
                await MainActor.run {
                    if let index = dogWalkingMarkers.firstIndex(where: { $0.id == marker.id }) {
                        dogWalkingMarkers[index].imageURL = downloadURL
                    }
                }
            }
        }
    }
    
    private func calculateCalories() -> String {
        let weight = UserManager.shared.user?.weight ?? 5
        let dogWalkingTime = Double(timeSeconds) / 3600
        let dogWalkingMets = 3.0

        let calcories = weight * dogWalkingTime * dogWalkingMets
        return String(format: "%.1f", calcories)
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
