import Foundation
import Firebase
import FirebaseFirestore

class FirebaseManager {
    static let shared = FirebaseManager()
    
    private init() { }
    
    func uploadUserInfo(user: User, completion: @escaping (Error?) -> Void) {
        let db = Firestore.firestore()
        
        let collectionRef = db.collection("users")
        do {
            try collectionRef.document(user.id).setData(from: user) { error in
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
    
    func hasUserInfo(id: String, completion: @escaping(Bool) -> Void) {
        let db = Firestore.firestore()
        let docRef = db.collection("users").document(id)

        docRef.getDocument { (document, error) in
           if let document = document, document.exists {
               completion(true)
           } else {
               completion(false)
           }
        }
    }
    
    
}
