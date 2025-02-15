//
//  SignUpViewModel.swift
//  Gyundle
//
//  Created by 임채윤 on 2/15/25.
//

import Foundation
import FirebaseAuth

final class SignUpViewModel: ObservableObject, ErrorPresentable {
    @Published var viewPage: SignUpViewPage = .nameView
    @Published var dog: Dog = .init(name: "", gender: .unspecified, weight: 0.0, dateOfBirth: .init())
    
    @Published var showError: Bool = false
    @Published var errorMessage: String?
    
    func signUp(onSuccess: @escaping () -> () = {}) async {
        guard let currentUser = Auth.auth().currentUser else {
            presentError(message: "문제가 발생했습니다 다시 시도해주세요.")
            return
        }
        
        let user = User(
            id: currentUser.uid,
            email: currentUser.email ?? "",
            dogs: [dog]
        )
        
        do {
            try await UserManager.shared.uploadUserData(user)
            await MainActor.run {
                onSuccess()
            }
        } catch {
            presentError(message: "잠시 후 다시 시도 해주세요.")
        }
        
    }
    
    func presentError(message: String?) {
        DispatchQueue.main.async {
            self.showError = true
            self.errorMessage = message
        }
    }
}
