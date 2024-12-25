import Foundation
import SwiftUI

class MemoryViewModel: ObservableObject {
    @Published var dogWalkingMemories: [String: [DogWalkingMemory]] = [:]
    @Published var dailyMemories: [String: [DailyMemory]] = [:]
    
    func uploadMemory<T: Codable & Memorable>(memory: T) {
        FirebaseManager.shared.uploadMemory(memory: memory) { error in
            if let error = error {
                print(error)
                return
            }
            
            self.fetchMemories(date: memory.date)
        }
    }
    
    func fetchMemories(date: Date) {
        let yearMonth = date.toYearMonth()
        
        FirebaseManager.shared.fetchMemories(from: yearMonth) { result in
            switch result {
            case .success(let memories):
                if let dailyMemories = memories.dailyMemories {
                    self.dailyMemories[yearMonth] = dailyMemories
                }
                
                if let walkingMemories = memories.walkingMemories {
                    self.dogWalkingMemories[yearMonth] = walkingMemories
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    func getMemory<T: Memorable>(of type: MemoryType, from date: Date) -> T? {
        let yearMonth = date.toYearMonth()
        let day = date.toDay()
        
        switch type {
        case .daily:
            let dailyMemory = dailyMemories[yearMonth]?.first { memory in
                memory.id == day
            }
                
            return dailyMemory as? T
        case .dogWalking:
            let dogWalkingMemory = dogWalkingMemories[yearMonth]?.first { memory in
                memory.id == day
            }
            
            return dogWalkingMemory as? T
        }
    }
}

