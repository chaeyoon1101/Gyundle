//
//  ToastView.swift
//  Gyundle
//
//  Created by 임채윤 on 2/3/25.
//

import SwiftUI

struct ToastView: View {
    @Environment(\.colorScheme) private var colorScheme
    
    @Binding var isShowing: Bool
    let message: String?
    
    // 위에서 아래로 나타났다가 사라지는 Animation을 위한 프로퍼티
    @State private var privateIsShowing: Bool = false
    
    // 드래그 프로퍼티
    @State private var offsetY: CGFloat = 0
    @State private var isDragging: Bool = false
    
    var body: some View {
        VStack {
            if privateIsShowing {
                ToastContent()
                    .offset(y: offsetY)
                    .transition(.asymmetric(
                        insertion: .move(edge: .top),
                        // SafeArea top height + ToastView Height
                        removal: .offset(y: -(getSafeAreaTop() + 60))
                    ))
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                isDragging = true
                                
                                let offsetY = value.translation.height < 0 ? value.translation.height : 0
                                
                                self.offsetY = offsetY
                            }
                            .onEnded { value in
                                isDragging = false
                                
                                let offsetY = value.translation.height < 0 ? value.translation.height : 0
                                
                                if -offsetY > 15 {
                                    dismiss()
                                } else {
                                    withAnimation(.spring) {
                                        self.offsetY = 0
                                    }
                                }
                            }
                    )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onFirstAppear {
            withAnimation(.spring) {
                privateIsShowing = true
            }
            setupAutoDismiss()
        }
    }
    
    @ViewBuilder
    private func ToastContent() -> some View {
        HStack {
            Image(systemName: "exclamationmark")
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(colorScheme == .light ? .primary : ColorConstant.bgPrimary)
                .frame(width: 24, height: 24)
                .background(.yellow, in: .circle)
                .padding(.leading)
            
            Spacer()
            
            Text(message ?? "문제가 발생했습니다.")
                .font(.system(size: 14))
                .foregroundStyle(ColorConstant.fgPrimary)
            
            Spacer()
            
            Color.clear
                .frame(width: 24, height: 24)
                .padding(.trailing)
        }
        .frame(height: 60)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 15)
                .fill(ColorConstant.bgContent)
                .shadow(color: .black.opacity(0.08), radius: 3, x: -1, y: -3)
                .shadow(color: .black.opacity(0.12), radius: 4, x: 1, y: 3)
        )
        .padding(.horizontal, 15)
    }
    
    private func setupAutoDismiss() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            dismiss()
        }
    }
    
    private func dismiss() {
        guard !isDragging else {
            setupAutoDismiss()
            return
        }
        
        withAnimation(.spring) {
            privateIsShowing = false
        } completion: {
            isShowing = false
        }
    }
}




#Preview {
    ToastView(isShowing: .constant(true), message: "에러 메시지입니다.")
}
