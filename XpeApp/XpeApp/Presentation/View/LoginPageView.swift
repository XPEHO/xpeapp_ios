//
//  LoginPageView.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 05/09/2024.
//

import SwiftUI
import xpeho_ui
import FirebaseAnalytics


struct LoginPage: View {
    var loginManager = LoginManager.instance
    var toastManager = ToastManager.instance
    
    @State var username: String = KeychainManager.instance.getValue(forKey: "last_username") ?? ""
    @State var password: String = ""
    
    // Allow to lock the button after first click and prevent spamming
    @State var isTryingToLogin = false

    @FocusState private var focusedField: Field?
    enum Field {
        case username
        case password
    }

    var body: some View {
        VStack(spacing: 16) {
            Spacer()
                .frame(width: 332, height: 250)
                .background {
                    Image("AppIconWithoutBg")
                        .resizable()
                        .renderingMode(.template)
                        .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                        .frame(width: 332, height: 332)
                }
            InputText(
                label: "Email",
                defaultInput: username,
                submitLabel: .next,
                onSubmit: {
                    focusedField = .password
                },
                onInput: { input in
                    self.username = input
                }
            )
            .focused($focusedField, equals: .username)
            InputText(
                label: "Mot de passe",
                password: true,
                submitLabel: .done,
                onSubmit: {
                    focusedField = nil
                    onLoginPress()
                },
                onInput: { input in
                    self.password = input
                }
            )
            .focused($focusedField, equals: .password)
            ClickyButton(
                label: isTryingToLogin ? "Connexion..." : "Se Connecter",
                size: 18,
                horizontalPadding: 70,
                verticalPadding: 18,
                enabled: true,//!isTryingToLogin,
                onPress: {
                    onLoginPress()
                }
            )
            .padding(.top, 32)
        }
        .preferredColorScheme(.dark)
        .trackScreen("login_page")
        .onAppear{
            if let last = KeychainManager.instance.getValue(forKey: "last_username") {
                self.username = last
            }
        }
        .padding(.horizontal, 16)
    }

    func onLoginPress() {
        isTryingToLogin = true
        loginManager.login(
            username: username,
            password: password
        ) {
            isTryingToLogin = false
        }
        debugPrint("Login with \(username)") 
    }
}

#Preview {
    LoginPage()
}
