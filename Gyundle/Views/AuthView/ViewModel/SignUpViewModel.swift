//
//  SignUpViewModel.swift
//  Gyundle
//
//  Created by 임채윤 on 12/21/24.
//

import Foundation

class SignUpViewModel: ObservableObject {
    @Published var page: SignUpViewPage = .nameView
    @Published var signUpData: UserInfoData = .init()
    
}

enum SignUpViewPage {
    case nameView
    case birthdayView
    case profileView
}
