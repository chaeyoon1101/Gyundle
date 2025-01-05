//
//  Collection+SafeIndex.swift
//  Gyundle
//
//  Created by 임채윤 on 1/5/25.
//

import Foundation

extension Collection {
    subscript(safe index: Index) -> Element? {
        return indices.contains(index) ? self[index] : nil
    }
}
