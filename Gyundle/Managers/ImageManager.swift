//
//  ImageManager.swift
//  Gyundle
//
//  Created by 임채윤 on 3/4/24.
//

import Foundation
import SwiftUI

class ImageManager {
    static let shared = ImageManager()
    
    private init() { }
    
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        
    }
}
