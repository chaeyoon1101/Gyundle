import SwiftUI

class DailyMemoryViewModel: ObservableObject, ErrorPresentable {
    // 캘린더에서 한 달 간격으로 보여주기 때문에 한 달씩 데이터를 구분
    @Published var dailyMemories: [MemoryKey: [DailyMemory]] = [:]
    
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    
    // MARK: Memory
    func uploadMemory(_ memory: DailyMemory, onSuccess: @escaping () -> () = {}) async {
        do {
            try await FirebaseManager.shared.uploadMemory(memory)
            
            print("Memory 업로드 성공")
            await MainActor.run {
                let key = MemoryKey.convertToKey(from: memory.date)
                dailyMemories[key]?.append(memory)
                
                onSuccess()
            }
        } catch let error as LocalizedError {
            print("Memory 업로드 실패:", error.localizedDescription)
            presentError(message: error.recoverySuggestion)
        } catch {
            print("Memory 업로드 실패:", error.localizedDescription)
            presentError()
        }
    }
    
    func deleteMemory(_ memory: DailyMemory, onSuccess: @escaping () -> () = {}) async {
        do {
            try await FirebaseManager.shared.deleteMemory(memory)
            
            await MainActor.run {
                let key = MemoryKey.convertToKey(from: memory.date)
                dailyMemories[key]?.removeAll(where: { $0.uid == memory.uid } )
                
                onSuccess()
            }
            print("Memory 삭제 성공")
        } catch let error as LocalizedError {
            print("Memory 업로드 실패:", error.localizedDescription)
            presentError(message: error.recoverySuggestion)
        } catch {
            print("Memory 업로드 실패:", error.localizedDescription)
            presentError()
        }
    }
    
    func updateMemory(_ memory: DailyMemory, onSuccess: @escaping () -> () = {}) async {
        do {
            try await FirebaseManager.shared.updateMemory(memory)
            
            await MainActor.run {
                let key = MemoryKey.convertToKey(from: memory.date)
                dailyMemories[key]?.update(keyPath: \.uid, matching: memory.uid, with: memory)
                
                onSuccess()
            }
            print("Memory 업데이트 성공")
        } catch let error as LocalizedError {
            print("Memory 업로드 실패:", error.localizedDescription)
            presentError(message: error.recoverySuggestion)
        } catch {
            print("Memory 업로드 실패:", error.localizedDescription)
            presentError()
        }
    }
    
    func fetchMemories(from date: Date) async {
        let key = MemoryKey.convertToKey(from: date)
        
        // 캘린더 달 변경 시 처음 한번만 데이터 fetch 하기
        guard dailyMemories[key] == nil else { return }
        
        do {
            let memories = try await FirebaseManager.shared.fetchMemories(from: key)
            
            await MainActor.run {
                if let dailyMemories = memories.dailyMemories {
                    self.dailyMemories[key] = dailyMemories
                }
            }
        } catch let error as AuthError {
            print("memory fetch 실패: ", error.localizedDescription)
        } catch {
            print("\(key.toString()) Daily Memories가 존재하지않음:", error.localizedDescription)
            await MainActor.run {
                self.dailyMemories[key] = []
            }
        }
    }
    
    // 선택한 날짜의 데이터를 가져오기
    func getMemory(from date: Date) -> DailyMemory? {
        let key = MemoryKey.convertToKey(from: date)
        
        return dailyMemories[key]?.first { $0.day == date.toDay() }
    }
    
    func presentError(message: String? = "잠시 후 다시 시도해주세요.") {
        DispatchQueue.main.async {
            self.errorMessage = message
            self.showError = true
        }
    }
}

