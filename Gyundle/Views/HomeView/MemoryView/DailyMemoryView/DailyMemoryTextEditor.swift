//
//  DailyMemoryTextEditor.swift
//  Gyundle
//
//  Created by 임채윤 on 3/4/24.
//

import SwiftUI

struct DailyMemoryTextEditor: View {
    @Binding var enteredText: String
    @FocusState var focused: Bool
    
    var body: some View {
        ZStack(alignment: .leading) {
            if enteredText.isEmpty {
                VStack {
                    Text("오늘을 기억을 기록해보세요!")
                        .padding(.top, 10)
                        .padding(.leading, 6)
                    Spacer()
                }
                .padding()
            }
            
            TextEditor(text: $enteredText)
                .opacity(enteredText.isEmpty ? 0.5 : 1)
                .padding()
                .focused($focused)
        }
        .onAppear {
            focused = true
        }
    }
}

#Preview {
    DailyMemoryTextEditor(enteredText: .constant(""))
}
