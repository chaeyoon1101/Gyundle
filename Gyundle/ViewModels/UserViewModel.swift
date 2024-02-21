import SwiftUI
import Firebase
import FirebaseFirestore

class UserViewModel: ObservableObject {
    @Published var user: User?
    
    func createUserInfo(id: String) {
        let db = Firestore.firestore()
        let collectionRef = db.collection("users")
        
        do {
            try collectionRef.document("testId").setData(from: user) { error in
                if let error = error {
                    print("User Info 업로드 실패", error.localizedDescription)
                } else {
                    print("업로드 성공")
                }
            }
        } catch let error {
            print("\(error)")
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
