//
//  SignUpData.swift
//  Gyundle
//
//  Created by 임채윤 on 2/18/24.
//

import Foundation

class SignUpData: ObservableObject {
    @Published var id: String = ""
    @Published var email: String = ""
    @Published var name: String = ""
    @Published var photo: String = ""
    @Published var dateOfBirth: Date = Date()
    
    func toUser() -> User {
        var user = User(
                        id: id,
                        email: email,
                        name: name,
                        photo: photo,
                        dateOfBirth: dateOfBirth
                    )
        
        return user
    }
}
