import Foundation
import SwiftUI

class MemoryViewModel: ObservableObject {
    @Published var dogWalkingMemories: [String: [String: Any]] = [:]
    @Published var dailyMemories: [String: [String: Any]] = [:]
    
    func uploadDogWalkingMemory() {
        
    }
    
    func uploadDailyMemory(memory: DailyMemory) {
        FirebaseManager.shared.uploadDailyMemory(memory: memory) { error in
            
        }
    }
    
    func fetchDogWalkingMemories() {
        
    }
    
    func fetchDailyWalkingMemories() {
        
    }
}

