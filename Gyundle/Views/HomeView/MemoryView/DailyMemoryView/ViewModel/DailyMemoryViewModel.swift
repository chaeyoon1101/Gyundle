import SwiftUI

class DailyMemoryViewModel: ObservableObject {
    // 캘린더에서 한 달 간격으로 보여주기 때문에 한 달씩 데이터를 구분
    // ["2024_12": [DailyMemory(day: "5")]] == 2024년 12월 5일의 데이터
    @Published var dailyMemories: [String: [DailyMemory]] = [:]
    
    @Published var isPresentedMemorizeView: Bool = false
    
    // 현재 관리중인 memory 데이터를 관리하기 위함
    // 데이터 추가, 변경, 삭제를 하려는 데이터를 이 변수에 담아서 선택된 데이터의 값으로 DB에 요청
    @Published var selectedMemory: DailyMemory?
    
    
    // 선택된 데이터를 추가, 변경, 삭제를 한 뒤에 nil로 초기화하기
    // 잘못된 데이터를 요청하는 것을 막기 위함
    @MainActor
    func resetSelectedMemory() {
        selectedMemory = nil
    }
    
    
    // MARK: Memory 데이터 DB 통신s
    func uploadMemory() async {
        guard let memory = selectedMemory else {
            print("Selected Memory가 존재하지 않음")
            return
        }
        
        do {
            try await FirebaseManager.shared.uploadMemory(memory)
            
            print("Memory 업로드 성공")
            await MainActor.run {
                let key = convertToKey(from: memory.date)
                dailyMemories[key]?.append(memory)
                isPresentedMemorizeView = false
            }
        } catch {
            print("Memory 업로드 실패:", error.localizedDescription)
        }
        
        await resetSelectedMemory()
    }
    
    func deleteMemory() async {
        guard let memory = selectedMemory else {
            print("Selected Memory가 존재하지 않음")
            return
        }
        
        do {
            try await FirebaseManager.shared.deleteMemory(memory)
            
            await MainActor.run {
                let key = convertToKey(from: memory.date)
                dailyMemories[key]?.removeAll(where: { $0.uid == memory.uid } )
            }
            print("Memory 삭제 성공")
        } catch {
            print("Memory 삭제 실패:", error.localizedDescription)
        }
        
        await resetSelectedMemory()
    }
    
    func updateMemory() async {
        guard let memory = selectedMemory else {
            print("Selected Memory가 존재하지 않음")
            return
        }
        
        do {
            try await FirebaseManager.shared.updateMemory(memory)
            
            await MainActor.run {
                isPresentedMemorizeView = false
                
                let key = convertToKey(from: memory.date)
                let updatedMemory = dailyMemories[key]?.map { $0.uid != memory.uid ? $0 : memory }
                dailyMemories[key] = updatedMemory
            }
            print("Memory 업데이트 성공")
        } catch {
            print("Memory 업데이트 실패:", error.localizedDescription)
        }
        
        await resetSelectedMemory()
    }
    
    func fetchMemories(from date: Date) async {
        let key = convertToKey(from: date)
        
        do {
            let memories = try await FirebaseManager.shared.fetchMemories(from: key)
            
            await MainActor.run {
                if let dailyMemories = memories.dailyMemories {
                    self.dailyMemories[key] = dailyMemories
                }
            }
        } catch {
            print("memory fetch 실패: ", error)
        }
    }
    
    // 선택한 날짜의 데이터를 가져오기
    func getMemory(from date: Date) -> DailyMemory? {
        let key = convertToKey(from: date)
        
        let dailyMemory = dailyMemories[key]?.first { memory in
            memory.day == date.toDay()
        }
        
        return dailyMemory
    }
    
    private func convertToKey(from date: Date) -> String {
        return date.toYearMonth()
    }
}

