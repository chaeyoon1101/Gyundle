import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() { }
    
    func uploadDailyMemory(memory: DailyMemory, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            return
        }
            
        let date = memory.date
        let userRef = db.collection("users").document(userID)
        
        do {
            try userRef.collection("memories").document(date.toMonth()).collection(date.toDay()).document("dailyMemories").setData(from: memory) { error in
                if let error = error {
                    print("daily memory 업로드 실패", error.localizedDescription)
                    completion(error)
                } else {
                    print("daily memory 업로드 성공")
                    completion(nil)
                }
            }
        } catch let error {
            print("\(error)")
            completion(error)
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
