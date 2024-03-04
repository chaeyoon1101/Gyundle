import Foundation
import SwiftUI

class ImageManager {
    static let shared = ImageManager()
    
    private init() { }
    
    func uploadImage(image: UIImage, completion: @escaping (Result<URL, Error>) -> Void) {
        
    }
}
