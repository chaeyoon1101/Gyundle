//
//  DogWalkingMemorizeViewModel.swift
//  Gyundle
//
//  Created by 임채윤 on 1/14/25.
//

import Foundation

final class DogWalkingMemorizeViewModel: ObservableObject {
    // MARK: View Properties
    @Published var dogWalkingTime: String = "00:00"
    @Published var dogWalkingDistance: String = "0.00km"
    @Published var dogWalkingSpeed: String = "0km/h"
    @Published var dogWalkingCalories: String = "0.0kcal"
    
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
    

    private func calculateCalories(totalDistance: Double) -> String {
        let weight = UserManager.shared.user?.weight ?? 5
        let dogWalkingTime = Double(timeSeconds) / 3600
        let dogWalkingMets = 3.0

        print(weight)
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
