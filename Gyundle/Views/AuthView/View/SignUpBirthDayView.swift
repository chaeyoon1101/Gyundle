import SwiftUI

struct SignUpBirthDayView: View {
    @EnvironmentObject private var signUpViewModel: SignUpViewModel
    
    // MARK: 년, 월, 일 각각의 데이터를 위한 프로퍼티들
    @State private var dateTexts: [DateTextType: String] = [.year: "", .month: "", .day: ""]
    @State private var isVaildDates: [DateTextType: Bool] = [.year: true, .month: true, .day: true]
    @FocusState private var foucsedField: DateTextType?
    
    var body: some View {
        VStack {
            
            VStack(spacing: 15) {
                Text("\(signUpViewModel.dog.name)의 생일을 알려주세요!")
                
                BirthdayTextField()
            }
            .padding(.top, 150)
            
            Spacer()
            
            VStack {
                let isVaildDate = !isVaildDates.contains(where: { $0.value == false })
                
                if !isVaildDate {
                    Text("정확한 날짜를 입력해주세요")
                        .foregroundStyle(.red)
                }
                
                Button("다음") {
                    if let birthDate = convertToDate(from: dateTexts) {
                        signUpViewModel.dog.dateOfBirth = birthDate
                        signUpViewModel.viewPage = .profileView
                    } else {
                        isVaildDates = Dictionary(
                            uniqueKeysWithValues: isVaildDates.keys.map { ($0, false) }
                        )
                    }
                }
                .disabled(!isVaildDate)
                .opacity(!isVaildDate ? 0.5 : 1)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 20)
                .buttonStyle(SignUpViewButtonStyle())
            }
        }
        .overlay(alignment: .topLeading) {
            SignUpBackButton {
                signUpViewModel.viewPage = .nameView
            }
        }
    }
    
    @ViewBuilder
    private func BirthdayTextField() -> some View {
        HStack(spacing: 12) {
            ForEach(DateTextType.allCases, id: \.self) { type in
                DateTextField(
                    type: type,
                    text: dateTextBinding(type: type),
                    isVaildDate: vaildDateBinding(type: type),
                    focusedField: _foucsedField
                )
            }
        }
    }
    
    // MARK: DateTextField에 바인딩 하기 위한 함수
    private func dateTextBinding(type: DateTextType) -> Binding<String> {
        return Binding(
            get: { dateTexts[type] ?? "" },
            set: { dateTexts[type] = $0 }
        )
    }
    
    private func vaildDateBinding(type: DateTextType) -> Binding<Bool> {
        return Binding(
            get: { isVaildDates[type] ?? false },
            set: { isVaildDates[type] = $0 }
        )
    }
    
    // MARK: 입력받은 날짜들을 DB에 저장하기 위해 Date 타입으로 변경
    private func convertToDate(from dates: [DateTextType: String]) -> Date? {
        guard !dates.contains(where: { $0.value.isEmpty } ) else {
            return nil
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyyMMdd"
        
        // 포멧에 맞춰서 년, 월, 일 순서로 정렬
        let sortedDates = dates.sorted(by: { $0.key.rawValue < $1.key.rawValue } )
        
        
        // "yyyyMMdd" 형태로 변경
        let dateString = sortedDates
            .map(\.value)
            .joined()
        
        
        if let date = dateFormatter.date(from: dateString){
            return date
        } else {
            return nil
        }
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}

