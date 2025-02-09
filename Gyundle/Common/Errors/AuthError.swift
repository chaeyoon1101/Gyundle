//
//  AuthError.swift
//  Gyundle
//
//  Created by 임채윤 on 12/27/24.
//

import Foundation

enum AuthError: LocalizedError {
    case userNotFound
    case kakaoLoginFailed
    case appleLoginFailed
     
    var errorDescription: String? {
        switch self {
        case .userNotFound:
            return "로그인 된 유저 데이터가 존재하지 않습니다."
        case .kakaoLoginFailed:
            return "카카오 로그인 실패했습니다."
        case .appleLoginFailed:
            return "애플 로그인 실패했습니다."
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .userNotFound:
            "문제가 발생했습니다. 다시 시도해주세요."
        case .appleLoginFailed, .kakaoLoginFailed:
            "다시 로그인 시도 해주세요."
        }
    }
}
