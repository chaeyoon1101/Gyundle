//
//  ImageCacheManager.swift
//  Gyundle
//
//  Created by 임채윤 on 12/30/24.
//

import SwiftUI

final class ImageCacheManager {
    static let shared = ImageCacheManager()
    
    private init() { }
    
    private var cache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        
        cache.totalCostLimit = 10 * 1024 * 1024
        
        return cache
    }()
    
    func getImage(forKey key: String) -> Image? {
        guard let uiImage = cache.object(forKey: key as NSString) else {
            return nil
        }
        
        return Image(uiImage: uiImage)
    }
    
    @MainActor
    func setImage(_ image: Image, forKey key: String) {
        cache.setObject(image.asUIImage(), forKey: key as NSString)
    }
}
