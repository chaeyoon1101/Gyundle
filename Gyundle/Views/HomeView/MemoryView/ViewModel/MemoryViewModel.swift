import Foundation
import SwiftUI

class MemoryViewModel: ObservableObject {
    @Published var dogWalkingMemories: [String: [DogWalkingMemory]] = [:]
    @Published var dailyMemories: [String: [DailyMemory]] = [:]
    
    // 현재 관리중인 memory 데이터를 관리하기 위함
    // 데이터 추가, 변경, 삭제를 하려는 데이터를 이 변수에 담아서 선택된 데이터의 값으로 DB에 요청
    @Published var selectedMemory: Memorable?
    
    
    // 선택된 데이터를 추가, 변경, 삭제를 한 뒤에 nil로 초기화하기
    // 잘못된 데이터를 요청하는 것을 막기 위함
    @MainActor
    func resetSelectedMemory() {
        selectedMemory = nil
    }
    
    
    // MARK: Memory 데이터 DB 통신
    func uploadMemory() async {
        guard let memory = selectedMemory else {
            print("Selected Memory가 존재하지 않음")
            return
        }
        
        do {
            try await FirebaseManager.shared.uploadMemory(memory: memory)
            
            print("Memory 업로드 성공")
        } catch {
            print("Memory 업로드 실패:", error.localizedDescription)
        }
        
        await fetchMemories(date: memory.date)
        await resetSelectedMemory()
    }
    
    func deleteMemory() async {
        guard let memory = selectedMemory else {
            print("Selected Memory가 존재하지 않음")
            return
        }
        
        do {
            try await FirebaseManager.shared.deleteMemory(memory: memory)
            
            await MainActor.run {
                let key = memory.date.toYearMonth()
                dailyMemories[key]?.removeAll(where: { $0.uid == memory.uid } )
            }
            print("Memory 삭제 성공")
        } catch {
            print("Memory 삭제 실패:", error.localizedDescription)
        }
        
        await fetchMemories(date: memory.date)
        await resetSelectedMemory()
    }
    
    
    // 선택한 날짜의 데이터를 가져오기
    func getMemory<T: Memorable>(of type: MemoryType, from date: Date) -> T? {
        let yearMonth = date.toYearMonth()
        let day = date.toDay()
        
        switch type {
        case .daily:
            let dailyMemory = dailyMemories[yearMonth]?.first { memory in
                memory.day == day
            }
                
            return dailyMemory as? T
        case .dogWalking:
            let dogWalkingMemory = dogWalkingMemories[yearMonth]?.first { memory in
                memory.day == day
            }
            
            return dogWalkingMemory as? T
        }
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
}

