//
//  DetailImageViewModel.swift
//  Gyundle
//
//  Created by 임채윤 on 1/1/25.
//

import SwiftUI

@MainActor
class DetailImageViewModel: ObservableObject {
    
    struct IdentifiableImage: Hashable {
        let id: String
        var image: Image?
        
        init(id: String = UUID().uuidString, image: Image? = nil) {
            self.id = id
            self.image = image
        }
        
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
        }
    }
    
    // MARK: 디테일 뷰에서 어떤 이미지를 보여줄 건지를 담는 프로퍼티
    @Published var isShowing: Bool = false
    @Published var selection: [IdentifiableImage] = []
    @Published var selectedImage: IdentifiableImage? = nil
    
    // MARK: 드래그 제스쳐를 통해서 이미지의 Transition을 보여주기 위한 프로퍼티
    @Published var position: CGSize = .zero
    @Published var scale: CGFloat = 1
    
    func presentView(selectedID: String) {
        guard let selectedImage = selection.first(where: { $0.id == selectedID }) else {
            print("Selection 중에 선택한 이미지가 없음")
            print(selectedID, selection)
            return
        }
        
        withAnimation(.snappy(duration: 0.35)) { [weak self] in
            guard let self else { return }
            
            self.selectedImage = selectedImage
            self.isShowing = true
        }
    }
    
    func dismissView() {
        withAnimation(.snappy(duration: 0.35)) { [weak self] in
            guard let self else { return }
            isShowing = false
            self.selectedImage = nil
        }
        
        // pop 애니메이션이 끝나면 뷰의 위치 및 크기를 초기화
        self.position = .zero
        self.scale = 1
    }
    
    func updateTransform(position: CGSize, scale: CGFloat) {
        self.position = position
        self.scale = scale
    }
     
    func resetTransform() {
        withAnimation(.snappy(duration: 0.35)) { [weak self] in
            guard let self else { return }
            
            self.position = .zero
            self.scale = 1
        }
    }
}
