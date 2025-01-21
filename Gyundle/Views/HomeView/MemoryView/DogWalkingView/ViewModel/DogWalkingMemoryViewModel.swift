//
//  DogWalkingViewModel.swift
//  Gyundle
//
//  Created by 임채윤 on 1/4/25.
//

import Foundation

class DogWalkingMemoryViewModel: ObservableObject {
    @Published var dogWalkingMemories: [String: [DogWalkingMemory]] = [:]
    
    @Published var isPresentedMemorizeView: Bool = false
    
    @Published var selectedMemory: DogWalkingMemory?
    @Published var isUploading: Bool = false
    
    func uploadMemory() async {
        guard let selectedMemory else {
            print("Selected Memory가 존재하지 않음")
            return
        }
        await changeUploadState(to: true)

        do {
            try await FirebaseManager.shared.uploadMemory(selectedMemory)
            
            print("Dog Walking Memory Upload 성공:", selectedMemory.uid)
            let key = convertToKey(from: selectedMemory.date)
            dogWalkingMemories[key]?.append(selectedMemory)
        } catch {
            print("Dog Walking Memory Upload 실패:", error.localizedDescription)
        }
        
        await changeUploadState(to: false)
        await resetSelectedMemory()
    }
    
    func fetchMemories(from date: Date) async {
        let key = convertToKey(from: date)
        
        do {
            let fetchedMemories = try await FirebaseManager.shared.fetchMemories(from: key)
            
            await MainActor.run {
                print(fetchedMemories, key)
                if let dogWalkingMemories = fetchedMemories.dogWalkingMemories {
                    self.dogWalkingMemories[key] = dogWalkingMemories
                }
            }
            
            print("Dog Walking Memories fetch 성공")
        } catch {
            print("Dog Walking Memories Fetch 실패:", error.localizedDescription)
        }
    }
    
    func getMemories(from date: Date) -> [DogWalkingMemory]? {
        let key = convertToKey(from: date)
        print(dogWalkingMemories)
        guard let memories = dogWalkingMemories[key] else { return nil }
        
        return memories.filter { $0.day == date.toDay() }
    }
    
    @MainActor
    private func resetSelectedMemory() {
        selectedMemory = nil
    }
    
    @MainActor
    private func changeUploadState(to state: Bool) {
        isUploading = state
    }
    
    private func convertToKey(from date: Date) -> String {
        return date.toYearMonth()
    }
}
