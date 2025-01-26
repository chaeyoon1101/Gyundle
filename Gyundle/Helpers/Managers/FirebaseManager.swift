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
    
    
    // MARK: Memory Data
    func uploadMemory<T: Memorable>(_ memory: T) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            throw AuthError.userNotFound
        }
        
        let memoryType = memory is DailyMemory ? "dailyMemories" : "dogWalkingMemories"
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
    
    func deleteMemory<T: Memorable>(_ memory: T) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            throw AuthError.userNotFound
        }
        
        let userRef = db.collection("users").document(userID)
        let memoriesRef = userRef
                            .collection("memories")
                            .document(memory.date.toYearMonth())
        
        let memoriesDocument = try await memoriesRef.getDocument()
        
        let memories = try memoriesDocument.data(as: Memory.self)
        
        
        // 삭제하려는 데이터를 제외하고 다시 업데이트
        let filteredMemory: Memory = switch memory.self {
        case is DailyMemory:
             Memory(
                dailyMemories: memories.dailyMemories?.filter( { $0.uid != memory.uid } ),
                dogWalkingMemories: memories.dogWalkingMemories
            )
        case is DogWalkingMemory:
            Memory(
                dailyMemories: memories.dailyMemories,
                dogWalkingMemories: memories.dogWalkingMemories?.filter( { $0.uid != memory.uid } )
            )
        default:
            throw FirebaseError.unknownError
        }
        
        let encoder = Firestore.Encoder()
        let encodedData = try encoder.encode(filteredMemory)
        
        try await memoriesRef.updateData(encodedData)
    }
    
    func updateMemory<T: Memorable>(_ memory: T) async throws {
        guard let userID = Auth.auth().currentUser?.uid else {
            print("로그인 된 유저 정보가 없음")
            throw AuthError.userNotFound
        }
        
        let userRef = db.collection("users").document(userID)
        let memoriesRef = userRef
                            .collection("memories")
                            .document(memory.date.toYearMonth())
        
        
        let memoriesDocument = try await memoriesRef.getDocument()
        
        let memories = try memoriesDocument.data(as: Memory.self)
        
        // 기존 데이터에서 업데이트할 데이터를 찾아서 값을 변경한 후 DB에 업데이트
        let updatedMemory: Memory = switch memory.self {
        case is DailyMemory:
            Memory(
                dailyMemories: memories.dailyMemories?.map( { $0.uid == memory.uid ? memory as! DailyMemory : $0 } ),
                dogWalkingMemories: memories.dogWalkingMemories
            )
        case is DogWalkingMemory:
            Memory(
                dailyMemories: memories.dailyMemories,
                dogWalkingMemories: memories.dogWalkingMemories?.map( { $0.uid == memory.uid ? memory as! DogWalkingMemory : $0 } )
            )
        default:
            throw FirebaseError.unknownError
        }
        
        let encoder = Firestore.Encoder()
        let encodedData = try encoder.encode(updatedMemory)
        
        print(updatedMemory)
        try await memoriesRef.updateData(encodedData)
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
    
    
    
    // MARK: User Data
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
    
    // MARK: Firebase Storage 이미지 저장
    func uploadPhoto(with data: Data, to folderName: String) async throws -> String {
        let storage = Storage.storage()
        let storageRef = storage.reference()
        
        let photoRef = storageRef.child("\(folderName)/\(UUID().uuidString).jpg")
        
        _ = try await photoRef.putDataAsync(data)
        
        let downloadURL = try await photoRef.downloadURL()
        return downloadURL.absoluteString
    }
}

struct Test: Codable {
    var id:  String
    var value: String
}
