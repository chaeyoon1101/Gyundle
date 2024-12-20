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
                    print("dailyMemories가 있음 \(yearMonth)")
                    
                    self.dailyMemories[yearMonth] = dailyMemories
                }
                
                if let walkingMemories = memories.walkingMemories {
                    print("dog walkingMemories가 있음 \(yearMonth)")
                    
                    self.dogWalkingMemories[yearMonth] = walkingMemories
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

