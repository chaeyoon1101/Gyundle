import Foundation
import SwiftUI

class MemoryViewModel: ObservableObject {
    @Published var dogWalkingMemories: [String: [String: Any]] = [:]
    @Published var dailyMemories: [String: [String: DailyMemory]] = [:]
    
    func uploadDogWalkingMemory() {
        
    }
    
    func uploadDailyMemory(memory: DailyMemory) {
        FirebaseManager.shared.uploadDailyMemory(memory: memory) { error in
            if let error = error {
                print(error)
                return
            }
            
            self.fetchDailyMemories(date: memory.date)
        }
    }
    
    func fetchDogWalkingMemories() {
        
    }
    
    func fetchDailyMemories(date: Date) {
        FirebaseManager.shared.fetchDailyMemory(date: date) { result in
            switch result {
            case .success(let memories):
                var dailyMemories: [String: DailyMemory] = [:]
                for dailyMemory in memories.dailyMemories {
                    dailyMemories[dailyMemory.id] = dailyMemory
                }
                self.dailyMemories[date.toMonth()] = dailyMemories
            case .failure(let error):
                print(error)
            }
        }
    }
}

