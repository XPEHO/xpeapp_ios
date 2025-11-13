import SwiftUI
import xpeho_ui

struct ProfilePage: View {
    
    @State private var isChangingPassword = false
    
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            if isChangingPassword {
                ProfileEditPasswordView(isChangingPassword:$isChangingPassword)
            } else {
                ProfileUserInfosView(isChangingPassword:$isChangingPassword)
            }
        }
        .trackScreen("profile_page")
        .accessibility(identifier: isChangingPassword ? "ChangePasswordView" : "ProfileView")
    }
    
    
}

struct ProfilePage_Previews: PreviewProvider {
    static var previews: some View {
        ProfilePage()
    }
}
