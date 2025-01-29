//
//  Memorable.swift
//  Gyundle
//
//  Created by 임채윤 on 12/20/24.
//

import Foundation

protocol Memorable: Codable, Hashable {
    var uid: String { get }
    var day: String { get }
    var date: Date { get }
    
    static func defaultMemory() -> Self
}

extension Memorable {
    static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.uid == rhs.uid
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(uid)
    }
}
