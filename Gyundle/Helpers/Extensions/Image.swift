//
//  Image.swift
//  Gyundle
//
//  Created by 임채윤 on 3/4/24.
//

import Foundation
import SwiftUI

extension Image: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self)
    }
}
