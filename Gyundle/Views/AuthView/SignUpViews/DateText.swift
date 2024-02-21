import SwiftUI

struct DateText: View {
    let type: DateTextType
    
    @Binding var text: String
    @Binding var isVaildDate: Bool
    
    @FocusState var focusedField: DateTextType?
    
    var body: some View {
        HStack(spacing: 0) {
            textField
                .focused($focusedField, equals: type)
                .onChange(of: text) { newValue in
                    checkDateValidity()
                    if newValue.count == type.maxLength {
                        focusedField?.moveToNext()
                    } else if newValue.count > type.maxLength {
                        text = String(newValue.prefix(type.maxLength))
                    }
                }
            
            Text(type.label)
                .foregroundStyle(isVaildDate ? Color.primary : Color.red)
        }
    }
    
    private func checkDateValidity() {
        guard let date = Int(text) else {
            isVaildDate = false
            return
        }
        
        let vaildDateRange = type.dateRange
        
        isVaildDate = vaildDateRange.contains(date)
    }
    
    var textField: some View {
        TextField(type.placeholder, text: $text)
            .multilineTextAlignment(.leading)
            .background(Color.clear)
            .textFieldStyle(PlainTextFieldStyle())
            .fixedSize()
            .keyboardType(.numberPad)
    }
}
