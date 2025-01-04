//
//  FirebaseError.swift
//  Gyundle
//
//  Created by 임채윤 on 12/25/24.
//

import Foundation

enum FirebaseError: LocalizedError {
    case uploadFailed
    case fetchFailed
    case documentNotFound
    case unknownError
    
    var errorDescription: String? {
        switch self {
        case .uploadFailed:
            return "데이터를 업로드하지 못했습니다."
        case .fetchFailed:
            return "데이터를 불러오지 못했습니다."
        case .documentNotFound:
            return "데이터를 찾을 수 없습니다"
        case .unknownError:
            return "알 수 없는 에러가 발생했습니다. 다시 시도해주세요."
        }
    }
}
