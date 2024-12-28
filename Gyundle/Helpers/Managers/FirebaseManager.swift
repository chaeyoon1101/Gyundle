import Foundation
import FirebaseStorage
import FirebaseFirestore
import FirebaseAuth

class FirebaseManager {
    static let shared = FirebaseManager()
    
    let db = Firestore.firestore()
    
    private init() { }
    
    // MARK: Firebase Auth
    
    // Apple Auth
    func signIn(with credential: AuthCredential) async throws {
        try await Auth.auth().signIn(with: credential)
    }
    
    
    // Kakao Auth
    func signIn(withEmail email: String, password: String) async throws {
        try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func createUser(withEmail email: String, password: String) async throws {
        try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    
    // MARK: Firestore DB
    func uploadMemory<T: Codable & Memorable>(memory: T) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            throw AuthError.userNotFound
        }
        
        let memoryType = memory is DailyMemory ? "dailyMemories" : "WalkingMemories"
        let userRef = db.collection("users").document(userID)
        
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(memory)
        
        let memoriesRef = userRef
                            .collection("memories")
                            .document(memory.date.toYearMonth())
        
        try await memoriesRef.setData(
            [memoryType: FieldValue.arrayUnion([data])],
            merge: true
        )
    }
    
    
    func fetchMemories(from yearMonth: String) async throws -> Memory {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            throw AuthError.userNotFound
        }
        
        let userRef = db.collection("users").document(userID)
        let memoriesRef = userRef
                            .collection("memories")
                            .document(yearMonth)
        
        let document = try await memoriesRef.getDocument()
        let data = try document.data(as: Memory.self)
        
        return data
    }
    
    
    func uploadUserInfo(user: User) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            throw AuthError.userNotFound
        }
        
        let userRef = db.collection("users").document(userID)
        try userRef.setData(from: user)
    }
    
    
    func fetchUserData(id: String) async throws -> User {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            throw AuthError.userNotFound
        }
        
        let userRef = db.collection("users").document(userID)
        
        let document = try await userRef.getDocument()
        let userData = try document.data(as: User.self)
        
        return userData
    }
    
    func hasUserInfo(id: String) async -> Bool {
        let userRef = db.collection("users").document(id)
        
        do {
            let document = try await userRef.getDocument()
            
            return document.exists
        } catch {
            return false
        }
    }
    
    
    // MARK: Firebase Storage 이미지 저장
    func uploadPhoto(with datas: [Data], to folderName: String) async throws -> [String] {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        var downloadUrls: [String] = []
        
        for data in datas {
            let photoRef = storageRef.child("\(folderName)/\(UUID().uuidString).jpg")
            
            _ = try await photoRef.putDataAsync(data)
            
            let downloadURL = try await photoRef.downloadURL()
            downloadUrls.append(downloadURL.absoluteString)
        }
        
        return downloadUrls
    }
    

}
