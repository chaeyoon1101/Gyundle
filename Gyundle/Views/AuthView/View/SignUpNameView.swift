import SwiftUI

struct SignUpNameView: View {
    @EnvironmentObject var signUpViewModel: SignUpViewModel
    
    @State var isVaildName: Bool = false
    
    var body: some View {
        GeometryReader { let size = $0.size
            
            VStack {
                
                VStack {
                    Text("강아지의 이름을 알려주세요!")
                    
                    TextField("이름", text: $signUpViewModel.signUpData.name)
                        .multilineTextAlignment(.center)
                        .font(.title)
                        .background(Color.clear)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: signUpViewModel.signUpData.name) { _, newValue in
                            checkNameValidity(newValue)
                        }
                }
                .position(x: size.width / 2, y: size.height / 4)
                
                Spacer()
                
                VStack {
                    if !isVaildName && !signUpViewModel.signUpData.name.isEmpty {
                        Text("1글자 ~ 12글자 사이로 입력해주세요")
                            .foregroundStyle(.red)
                    }
                    Button("다음") {
                        signUpViewModel.page = .birthdayView
                    }
                    .disabled(!isVaildName)
                    .opacity(!isVaildName ? 0.5 : 1)
                    .frame(maxWidth: .infinity)
                    .padding(20)
                    .buttonStyle(SignUpViewButtonStyle())
                }
            }
        }
    }
    
    private func checkNameValidity(_ name: String) {
        let minLength = 1
        let maxLength = 12
        
        isVaildName = (minLength...maxLength).contains(name.count)
    }
}

#Preview {
    SignUpView()
        .environmentObject(AuthViewModel())
}
