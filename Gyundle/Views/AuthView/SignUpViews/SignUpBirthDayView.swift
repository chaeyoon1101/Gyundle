import SwiftUI

struct SignUpBirthDayView: View {
    @ObservedObject var signUpData: UserInfoData
    
    @Binding var pageId: SignUpViewPageId
    
    @State private var dateTexts = [String](repeating: "", count: DateTextType.allCases.count)
    @State private var isVaildDates = [Bool](repeating: true, count: DateTextType.allCases.count)
    
    @FocusState private var foucsedField: DateTextType?
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                backButton
                    .position(x: 30, y: 30)
                
                VStack {
                    VStack {
                        Text("\(signUpData.name)의 생일은 언제인가요?")
                        
                        HStack(spacing: 12) {
                            ForEach(DateTextType.allCases, id: \.self) { type in
                                DateText(
                                    type: type,
                                    text: $dateTexts[type.rawValue],
                                    isVaildDate: $isVaildDates[type.rawValue],
                                    focusedField: _foucsedField
                                )
                            }
                        }.font(.title)
                    }
                    .position(x: geometry.size.width / 2, y: geometry.size.height / 4)
                    
                    Spacer()
                    
                    VStack {
                        let isVaildDate = !isVaildDates.contains(false)
                        
                        if !isVaildDate {
                            Text("정확한 날짜를 입력해주세요")
                                .foregroundStyle(.red)
                        }
                        Button("다음") {
                            if let birthDate = convertToDate() {
                                signUpData.dateOfBirth = birthDate
                                pageId = .profileView
                            } else {
                                isVaildDates = [Bool](repeating: false, count: DateTextType.allCases.count)
                            }
                        }
                        .disabled(!isVaildDate)
                        .opacity(!isVaildDate ? 0.5 : 1)
                        .frame(width: geometry.size.width * 0.9)
                        .buttonStyle(CustomButtonStyle())
                    }
                }
            }
        }
    }
    
    private func convertToDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let date = dateTexts.joined(separator: "-")

        if let date = dateFormatter.date(from: date){
            return date
        } else {
            return nil
        }
    }
    
    var backButton: some View {
        Button {
            pageId = .nameView
        } label: {
            Image(systemName: "chevron.left")
        }
        .frame(width: 48, height: 48)
        .background(Color.secondary)
        .opacity(0.3)
        .foregroundStyle(.fg)
        .font(.title)
        .cornerRadius(5)
    }
}

#Preview {
    SignUpBirthDayView(signUpData: UserInfoData(), pageId: .constant(.birthdayView))
}
