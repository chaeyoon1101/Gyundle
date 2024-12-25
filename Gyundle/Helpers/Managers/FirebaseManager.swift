import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let db = Firestore.firestore()
    
    private init() { }
    
    func uploadMemory<T: Codable & Memorable>(memory: T, completion: @escaping (Error?) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            return
        }
        
        let memoryType = memory is DailyMemory ? "dailyMemories" : "WalkingMemories"
        
        let date = memory.date
        let userRef = db.collection("users").document(userID)
        
        do {
            let encoder = Firestore.Encoder()
            let data = try encoder.encode(memory)
            
            let memoriesRef = userRef.collection("memories").document(date.toYearMonth())
            
            memoriesRef.setData(
                [memoryType: FieldValue.arrayUnion([data])],
                merge: true
            ) { error in
                if let error = error {
                    print("\(memoryType) 메모리 업로드 실패:", error)
                    completion(error)
                }
                
                print("\(memoryType) 메모리 업로드 성공")
                completion(nil)
            }
            
        } catch {
            print("\(T.self) 메모리 데이터 업로드 실패:", error)
        }
    }
    
    func fetchMemories(from yearMonth: String, completion: @escaping (Result<Memory, Error>) -> Void) {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            return
        }
        
        let userRef = db.collection("users").document(userID)
        let memoriesRef = userRef.collection("memories").document(yearMonth)
        
        memoriesRef.getDocument { document, error in
            if let error = error {
                print("Memory 불러오는 데에 실패: ", error)
                completion(.failure(error))
            }
            
            if let document = document, document.exists {
                do {
                    let data = try document.data(as: Memory.self)
                    
                    print("fetch 성공")
                    completion(.success(data))
                } catch {
                    print("fetch 실패: ", error.localizedDescription)
                    completion(.failure(error))
                }
            } else {
                if let error = error {
                    print("\(yearMonth) document가 존재하지 않음", error)
                    completion(.failure(error))
                }
            }
        }
    }
    
    func uploadUserInfo(user: User, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        let collectionRef = db.collection("users")
        let documentRef = user.id
        
        do {
            try collectionRef.document(documentRef).setData(from: user) { error in
                if let error = error {
                    print("User Info 업로드 실패", error.localizedDescription)
                    completion(error)
                } else {
                    print("업로드 성공")
                    completion(nil)
                }
            }
        } catch let error {
            print("\(error)")
            completion(error)
        }
    }
    
    func fetchUserData(id: String, completion: @escaping (Result<User, Error>) -> Void) {
        let db = Firestore.firestore()
        
        let collectionRef = db.collection("users")
        
        collectionRef.document(id).getDocument { document, error in
            if let error = error {
                print("fetchUserData error: ", error)
                completion(.failure(error))
                return
            }
            
            if let document = document, document.exists {
                do {
                    let data = try document.data(as: User.self)
                    
                    print("\(id) document fetch 성공")
                    completion(.success(data))
                } catch {
                    print("decode Error", error)
                    completion(.failure(error))
                }
            } else {
                if let error = error {
                    print("\(id), document가 없음", error)
                    completion(.failure(error))
                }     
            }
        }
        
    }
    
    func hasUserInfo(id: String, completion: @escaping(Bool) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(id)

        docRef.getDocument { (document, error) in
           if let document = document, document.exists {
               print("user info: ", document.exists, document.description)
               completion(true)
           } else {
               completion(false)
           }
        }
    }
}
