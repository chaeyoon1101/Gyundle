//
//  AnnotationType.swift
//  Gyundle
//
//  Created by 임채윤 on 1/27/25.
//

import SwiftUI

enum AnnotationType {
    case start, end
    
    var color: Color {
        switch self {
        case .start:
            Color.blue
        case .end:
            Color.red
        }
    }
    
    var stringValue: String {
        switch self {
        case .start:
            "시작"
        case .end:
            "종료"
        }
    }
}
