import SwiftUI

enum SignUpViewPageId {
    case nameView
    case birthdayView
    case profileView
}

struct SignUpView: View {
    @StateObject private var signUpData = UserInfoData()
    @State var pageId: SignUpViewPageId = .nameView
    
    var body: some View {
        GeometryReader { geometry in
            ScrollViewReader { scrollViewProxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 0) {
                        SignUpNameView(signUpData: signUpData, pageId: $pageId)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .id(SignUpViewPageId.nameView)
                    
                        SignUpBirthDayView(signUpData: signUpData, pageId: $pageId)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .id(SignUpViewPageId.birthdayView)
                    
                        SignUpProfileView(signUpData: signUpData, pageId: $pageId)
                            .frame(width: geometry.size.width, height: geometry.size.height)
                            .id(SignUpViewPageId.profileView)
                    }
                    .bold()
                }
                .scrollDisabled(true)
                
                .onChange(of: pageId) { newValue in
                    UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                    withAnimation {
                        scrollViewProxy.scrollTo(pageId, anchor: .center)
                    }
                }
            }
        }
    }
}

#Preview {
    SignUpView()
}
