//
//  Image+Extensions.swift
//  Gyundle
//
//  Created by 임채윤 on 12/30/24.
//

import SwiftUI

extension Image {
    @MainActor
    func asUIImage() -> UIImage {
        guard let uiImage = ImageRenderer(content: self).uiImage else {
            return UIImage()
        }
        
        return uiImage
    }
}
