//
//  Memorable.swift
//  Gyundle
//
//  Created by 임채윤 on 12/20/24.
//

import Foundation

protocol Memorable: Codable, Hashable, Equatable {
    var uid: String { get }
    var day: String { get }
    var date: Date { get }
    
    static func defaultMemory() -> Self
}

extension Memorable {
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
