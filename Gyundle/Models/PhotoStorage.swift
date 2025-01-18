//
//  PhotoStorage.swift
//  Gyundle
//
//  Created by 임채윤 on 1/17/25.
//

import Foundation

enum PhotoStorage {
    case profile
    case dailyMemory
    case dogWalkingMemory
    
    var folderName: String {
        switch self {
        case .profile: return "ProfilePhotos"
        case .dailyMemory: return "DailyMemoryPhotos"
        case .dogWalkingMemory: return "DogWalkingMemoryPhotos"
        }
    }
}
