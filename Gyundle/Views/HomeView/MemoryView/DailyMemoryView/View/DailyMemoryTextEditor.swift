//
//  DailyMemoryTextEditor.swift
//  Gyundle
//
//  Created by 임채윤 on 3/4/24.
//

import SwiftUI

struct DailyMemoryTextEditor: View {
    @Binding var enteredText: String
    @Binding var isFocused: FocusState<Bool>.Binding
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            PlaceholderView()
                .padding()
            
            TextEditor(text: $enteredText)
                .opacity(enteredText.isEmpty ? 0.5 : 1)
                .scrollContentBackground(.hidden)
                .padding()
                .focused(isFocused)
            
        }
    }
    
    @ViewBuilder func PlaceholderView() -> some View {
        if enteredText.isEmpty {
            VStack {
                Text("오늘을 기억을 기록해보세요!")
                    .padding(.top, 10)
                    .padding(.leading, 6)
                Spacer()
            }
        }

    }
}

#Preview {
//    DailyMemoryTextEditor(enteredText: .constant(""))
}
