//
//  Array+Extension.swift
//  Gyundle
//
//  Created by 임채윤 on 1/31/25.
//

import Foundation

extension Array {
    mutating func update<T: Equatable>(
        keyPath: WritableKeyPath<Element, T>,
        matching value: T,
        with newValue: Element
    ) {
        indices.forEach { index in
            if self[index][keyPath: keyPath] == value {
                self[index] = newValue
            }
        }
    }
}
