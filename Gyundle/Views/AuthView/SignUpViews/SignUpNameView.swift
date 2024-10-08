import SwiftUI



struct SignUpNameView: View {
    @ObservedObject var signUpData: UserInfoData
    
    @Binding var pageId: SignUpViewPageId
    
    @State var isVaildName: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            VStack {
                VStack {
                    Text("강아지의 이름을 알려주세요!")
                    
                    textField
                        .onChange(of: signUpData.name) { newValue in
                            checkNameValidity(newValue)
                        }
                }
                .position(x: geometry.size.width / 2, y: geometry.size.height / 4)
                
                Spacer()
                
                VStack {
                    if !isVaildName {
                        if signUpData.name.count >= 12 {
                            Text("12글자 이내로 입력해주세요")
                                .foregroundStyle(.red)
                        }
                    }
                    Button("다음") {
                        pageId = .birthdayView
                    }
                    .disabled(!isVaildName)
                    .opacity(!isVaildName ? 0.5 : 1)
                    .frame(width: geometry.size.width * 0.9)
                    .buttonStyle(SignUpViewButtonStyle())
                }
            }
        }
    }
    
    private func checkNameValidity(_ name: String) {
        let maxLength = 12
        let minLength = 1
        
        isVaildName = (minLength...maxLength).contains(name.count)
    }
    
    var textField: some View {
        TextField("봉구", text: $signUpData.name)
            .multilineTextAlignment(.center)
            .font(.title)
            .background(Color.clear)
            .textFieldStyle(PlainTextFieldStyle())
    }
}

#Preview {
    SignUpNameView(signUpData: UserInfoData(), pageId: .constant(.nameView))
}
