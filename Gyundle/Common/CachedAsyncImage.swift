//
//  CachedAsyncImage.swift
//  Gyundle
//
//  Created by 임채윤 on 12/30/24.
//

import SwiftUI

struct CachedAsyncImage<Content>: View where Content: View {
    private let url: URL
    private let content: (AsyncImagePhase) -> Content
    
    init(url: URL?, @ViewBuilder content: @escaping (AsyncImagePhase) -> Content) {
        self.url = url ?? URL(string: "")!
        self.content = content
    }
    
    var body: some View {
        
        if let cachedImage = ImageCacheManager.shared.getImage(forKey: url.absoluteString) {
            content(.success(cachedImage))
        } else {
            AsyncImage(url: url) { phase in
                if case .success(let image) = phase {
                    let _ = ImageCacheManager.shared.setImage(image, forKey: url.absoluteString)
                }
                content(phase)
            }
        }
    }
}
