//
//  DogWalkingViewModel.swift
//  Gyundle
//
//  Created by 임채윤 on 1/4/25.
//

import Foundation
import SwiftUI

class DogWalkingMemoryViewModel: ObservableObject, ErrorPresentable {
    @Published var dogWalkingMemories: [MemoryKey: [DogWalkingMemory]] = [:]
    
    @Published var isUploading: Bool = false
    
    // View Present Properties
    @Published var showMemorizeView: Bool = false
    
    // Error Handling
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    
    // MARK: Memory
    
    func uploadMemory(_ memory: DogWalkingMemory, onSuccess: @escaping () -> () = {}) async {
        await changeUploadState(to: true)

        do {
            try await FirebaseManager.shared.uploadMemory(memory)
            
            print("Dog Walking Memory Upload 성공:", memory.uid)
            
            await MainActor.run {
                let key = MemoryKey.convertToKey(from: memory.date)
                dogWalkingMemories[key, default: []].append(memory)
                
                onSuccess()
            }
        } catch let error as LocalizedError {
            print("Dog Walking Memory Upload 실패:", error.localizedDescription)
            presentError(message: error.recoverySuggestion)
        } catch {
            print("Dog Walking Memory Upload 실패:", error.localizedDescription)
            presentError()
        }
        
        await changeUploadState(to: false)
    }
    
    func updateMemory(_ memory: DogWalkingMemory, onSuccess: @escaping () -> () = {}) async {
        do {
            try await FirebaseManager.shared.updateMemory(memory)
            print("Dog Walking Memory Update 성공:", memory.uid)
            
            await MainActor.run { onSuccess() }
        } catch let error as LocalizedError {
            print("Dog Walking Memory Update 실패:", error.localizedDescription)
            presentError(message: error.recoverySuggestion)
        } catch {
            print("Dog Walking Memory Update 실패:", error.localizedDescription)
            presentError()
        }
    }
    
    func deleteMemory(_ memory: DogWalkingMemory, onSuccess: @escaping () -> () = {}) async {
        do {
            try await FirebaseManager.shared.deleteMemory(memory)
            print("dog walking Memory 삭제 성공:", memory.uid)
            
            await MainActor.run {
                let key = MemoryKey.convertToKey(from: memory.date)
                dogWalkingMemories[key]?.removeAll(where: { $0.uid == memory.uid })
                
                onSuccess()
            }
        } catch {
            print("dog walking Memory 삭제 실패:", error.localizedDescription)
        }
    }
    
    func fetchMemories(from date: Date) async {
        let key = MemoryKey.convertToKey(from: date)
        
        // 캘린더 달 변경 시 처음 한번만 데이터 fetch 하기
        guard dogWalkingMemories[key] == nil else { return }
        
        do {
            let fetchedMemories = try await FirebaseManager.shared.fetchMemories(from: key)
            
            await MainActor.run {
                if let dogWalkingMemories = fetchedMemories.dogWalkingMemories {
                    self.dogWalkingMemories[key] = dogWalkingMemories
                }
            }
            
            print("Dog Walking Memories fetch 성공")
        } catch let error as AuthError {
            print("Dog Walking Memories Fetch 실패:", error.localizedDescription)
        } catch {
            print("\(key.toString()) Dog Walking Memories가 존재하지않음:", error.localizedDescription)
            await MainActor.run {
                self.dogWalkingMemories[key] = []
            }
        }
    }
    
    func getMemories(from date: Date) -> Binding<[DogWalkingMemory]> {
        let key = MemoryKey.convertToKey(from: date)
        
        return Binding(
            get: {
                self.dogWalkingMemories[key]?
                    .filter { $0.day == date.toDay() } ?? []
            }, set: { newValue in
                let memories = self.dogWalkingMemories[key] ?? []
                
                let updatedValue = memories.filter { $0.day != date.toDay() } + newValue
                
                self.dogWalkingMemories[key] = updatedValue
            }
        )
    }
    
    @MainActor
    private func changeUploadState(to state: Bool) {
        isUploading = state
    }
    
    func presentError(message: String? = "잠시 후 다시 시도해주세요.") {
        DispatchQueue.main.async {
            self.showError = true
            self.errorMessage = message
        }
    }
}
