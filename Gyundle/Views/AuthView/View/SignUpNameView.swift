import SwiftUI

struct SignUpNameView: View {
    @EnvironmentObject private var signUpViewModel: SignUpViewModel
    @State var isVaildName: Bool = false
    
    var body: some View {
        VStack {
            DogNameTextField()
                .padding(.top, 150)
            
            Spacer()
            
            NextButton()
        }
    }
    
    @ViewBuilder
    private func DogNameTextField() -> some View {
        VStack {
            Text("강아지의 이름을 알려주세요!")
            
            TextField("이름", text: $signUpViewModel.dog.name)
                .multilineTextAlignment(.center)
                .font(.title)
                .background(Color.clear)
                .textFieldStyle(PlainTextFieldStyle())
                .onChange(of: signUpViewModel.dog.name) { _, newValue in
                    checkNameValidity(newValue)
                }
        }
    }
    
    @ViewBuilder
    private func NextButton() -> some View {
        VStack {
            if !isVaildName && !signUpViewModel.dog.name.isEmpty {
                Text("1글자 ~ 12글자 사이로 입력해주세요")
                    .foregroundStyle(.red)
            }
            
            Button("다음") {
                signUpViewModel.viewPage = .birthdayView
            }
            .disabled(!isVaildName)
            .opacity(!isVaildName ? 0.5 : 1)
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 20)
            .buttonStyle(SignUpViewButtonStyle())
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
