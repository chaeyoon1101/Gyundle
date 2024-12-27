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
    
    var errorDescription: String? {
        switch self {
        case .uploadFailed:
            return "데이터를 업로드하지 못했습니다."
        case .fetchFailed:
            return "데이터를 불러오지 못했습니다."
        case .documentNotFound:
            return "데이터를 찾을 수 없습니다"
        }
    }
}
