//
//  DetailImageViewModel.swift
//  Gyundle
//
//  Created by 임채윤 on 1/1/25.
//

import SwiftUI

@MainActor
class DetailImageViewModel: ObservableObject {
    // 모든 뷰 계층에서 최상단에서 보이게하기 위해 SceneDelegate를 사용함
    // SceneDelegate와 View간의 데이터 공유를 위해 싱글톤으로 구현
    static let shared = DetailImageViewModel()
    private init() { }
    
    // MARK: 디테일 뷰에서 어떤 이미지를 보여줄 건지를 담는 프로퍼티
    @Published var isPresented: Bool = false
    @Published var photoSelection: [String] = []
    @Published var selectedPhoto: String? = nil
    
    // MARK: 드래그 제스쳐를 통해서 이미지의 Transition을 보여주기 위한 프로퍼티
    @Published var position: CGSize = .zero
    @Published var scale: CGFloat = 1
    
    func pushView(with selectedPhoto: String?, selection: [String]) {
        withAnimation(.spring(duration: 0.35)) {  [weak self] in
            guard let self else { return }
            
            self.photoSelection = selection
            self.selectedPhoto = selectedPhoto
            isPresented.toggle()
        }
    }
    
    func popView() {
        withAnimation(.easeOut(duration: 0.35)) { [weak self] in
            guard let self else { return }
            
            isPresented.toggle()
            self.photoSelection.removeAll()
            self.selectedPhoto = nil
        } completion: {
            // pop 애니메이션이 끝나면 뷰의 위치 및 크기를 초기화
            self.position = .zero
            self.scale = 1
        }
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
