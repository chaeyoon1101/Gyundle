//
//  MemoryKey.swift
//  Gyundle
//
//  Created by 임채윤 on 1/29/25.
//

import Foundation

struct MemoryKey: Hashable {
    var year: String
    var month: String

    func toString() -> String {
        return "\(year)_\(month)"
    }
    
    static func convertToKey(from date: Date) -> MemoryKey {
        let year = date.formatting("yyyy")
        let month = date.formatting("M")
        
        return MemoryKey(year: year, month: month)
    }
}

extension MemoryKey {
    func hash(into hasher: inout Hasher) {
        hasher.combine(year)
        hasher.combine(month)
    }
    
    static func ==(lhs: MemoryKey, rhs: MemoryKey) -> Bool {
        return lhs.year == rhs.year &&
               lhs.month == rhs.month
    }
}
