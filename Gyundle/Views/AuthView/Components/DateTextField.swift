import SwiftUI

struct DateTextField: View {
    let type: DateTextType
    
    @Binding var text: String
    @Binding var isVaildDate: Bool
    
    @FocusState var focusedField: DateTextType?
    
    var body: some View {
        HStack(spacing: 0) {
            NumberTextField()
                .onChange(of: text) { _, newValue in
                    checkDateValidity()
                    
                    // 다 입력하면 오른쪽으로 넘어가기
                    if newValue.count == type.maxLength {
                        focusedField?.moveToNext()
                    } else if newValue.count > type.maxLength {
                        text = String(newValue.prefix(type.maxLength))
                    }
                }
            
            Text(type.label)
                .foregroundStyle(isVaildDate ? Color.primary : Color.red)
        }
        .font(.title)
    }
    
    @ViewBuilder
    private func NumberTextField() -> some View {
        TextField(type.placeholder, text: $text)
            .multilineTextAlignment(.leading)
            .background(Color.clear)
            .textFieldStyle(PlainTextFieldStyle())
            .fixedSize()
            .keyboardType(.numberPad)
            .focused($focusedField, equals: type)
    }
    
    private func checkDateValidity() {
        guard let date = Int(text) else {
            isVaildDate = false
            return
        }
        
        let vaildDateRange = type.dateRange
        
        isVaildDate = vaildDateRange.contains(date)
    }
}
