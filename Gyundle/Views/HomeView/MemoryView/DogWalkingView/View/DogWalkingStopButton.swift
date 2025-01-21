//
//  DogWalkingStopButton.swift
//  Gyundle
//
//  Created by 임채윤 on 1/19/25.
//

import SwiftUI

struct DogWalkingStopButton: View {
    var onStopped: () -> ()
    
    @State private var isPressing: Bool = false
    @State private var pressingTime: Double = 0
    @State private var scale: CGFloat = 1.0
    
    let activeTime = 1.5
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        Image(systemName: "stop.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundStyle(ColorConstant.bgPrimary)
            .frame(width: 32, height: 32)
            .frame(width: 96, height: 96)
            .background(ColorConstant.fgPrimary, in: .circle)
            .scaleEffect(scale)
            .onLongPressGesture(minimumDuration: activeTime) {
                onStopped()
                Haptic.notification(type: .success)
            } onPressingChanged: { isPressing in
                self.isPressing = isPressing
                
                if !isPressing {
                    guard pressingTime < activeTime else { return }
                    
                    pressingTime = 0
                    withAnimation {
                        scale = 1.0
                    }
                } else {
                    Haptic.impact(style: .soft)
                }
            }
            .onReceive(timer) { _ in
                if isPressing {
                    
                    // Long Pressing 중에 손가락을 버튼 바깥으로 벗어나는 경우
                    guard activeTime >= pressingTime else {
                        isPressing = false
                        pressingTime = 0
                        return
                    }
                    
                    pressingTime += 0.1
                    withAnimation {
                        scale += 0.05
                    }
                }
            }
    }
}

#Preview {
    DogWalkingMemorizeView(date: .init())
        .environmentObject(DogWalkingMemoryViewModel())
}
