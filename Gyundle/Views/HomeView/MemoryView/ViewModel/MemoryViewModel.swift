import Foundation
import SwiftUI

class MemoryViewModel: ObservableObject {
    @Published var dogWalkingMemories: [String: [DogWalkingMemory]] = [:]
    @Published var dailyMemories: [String: [DailyMemory]] = [:]
    
    func uploadMemory<T: Codable & Memorable>(memory: T) async throws {
        try await FirebaseManager.shared.uploadMemory(memory: memory)
        
        await fetchMemories(date: memory.date)
    }
    
    func fetchMemories(date: Date) async {
        let yearMonth = date.toYearMonth()
        
        do {
            let memories = try await FirebaseManager.shared.fetchMemories(from: yearMonth)
            
            await MainActor.run {
                if let dailyMemories = memories.dailyMemories {
                    self.dailyMemories[yearMonth] = dailyMemories
                }
                
                if let walkingMemories = memories.walkingMemories {
                    self.dogWalkingMemories[yearMonth] = walkingMemories
                }
            }
        } catch {
            print("memory fetch 실패: ", error)
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

