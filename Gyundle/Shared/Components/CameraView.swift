//
//  CameraView.swift
//  Gyundle
//
//  Created by 임채윤 on 1/17/25.
//

import SwiftUI
import UIKit

enum CameraFinishedResult {
    case cancelled
    case finished(UIImage)
    case failed
}

struct CameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    
    let onFinished: (CameraFinishedResult) -> ()
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        var parent: CameraView
        
        init(parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.onFinished(.finished(image))
            } else {
                parent.onFinished(.failed)
            }
            
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.onFinished(.cancelled)
            parent.dismiss()
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }
    
    func makeUIViewController(context: Context) -> some UIViewController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.sourceType = .camera
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) {
        
    }
}
