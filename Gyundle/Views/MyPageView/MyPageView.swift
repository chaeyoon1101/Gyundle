import SwiftUI
import Kingfisher

struct MyPageView: View {
    @EnvironmentObject var userViewModel: UserViewModel
    
    var body: some View {
        VStack {
            if let user = userViewModel.user {
                VStack {
                    Text(user.name)
                    Text(user.email)
                    KFImage(URL(string: user.photo))
                        .resizable()
                        .frame(width: 150, height: 150)
                        .aspectRatio(contentMode: .fill)
                }
            } else {
                VStack {
                    Text("11")
                }
            }
        }
        
        
    }
        
}

#Preview {
    MyPageView()
        .environmentObject(UserViewModel())
}
