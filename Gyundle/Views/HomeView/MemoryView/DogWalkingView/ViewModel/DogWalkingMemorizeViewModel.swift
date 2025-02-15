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
    
    func upsertMarker(_ marker: DogWalkingMarker) {
        let isExistMarker = dogWalkingMarkers.contains(where: { $0.id == marker.id })
        
        if isExistMarker {
            updateMarker(marker)
        } else {
            insertMarker(marker)
        }
    }
    
    func deleteMarker(_ marker: DogWalkingMarker) {
        withAnimation(.snappy) {
            dogWalkingMarkers.removeAll(where: { $0.id == marker.id })
        }
    }
     
    private func insertMarker(_ marker: DogWalkingMarker) {
        dogWalkingMarkers.append(marker)
    }

    private func updateMarker(_ marker: DogWalkingMarker) {
        dogWalkingMarkers.update(keyPath: \.id, matching: marker.id, with: marker)
    }
    
    private func calculateCalories() -> String {
        let weight = UserManager.shared.user?.dogs[0].weight ?? 5.0
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
