//
//  UtilsUI.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 03/12/2024.
//

import Foundation
import SwiftUI
import AuthenticationServices


// Util function to open a pdf
func openPdf(url: String, toastManager: ToastManager, openMethod: OpenURLAction) {
    if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
        openMethod(url)
    } else {
        toastManager.setParams(
            message: "Impossible d'ouvrir l'URL",
            error: true
        )
        toastManager.play()
    }
}

class SSOManager: NSObject, ASWebAuthenticationPresentationContextProviding {
    static let shared = SSOManager()

    func authenticate(url: URL, callbackURLScheme: String, completion: @escaping (URL?, Error?) -> Void) {
        let session = ASWebAuthenticationSession(url: url, callbackURLScheme: callbackURLScheme) { callbackURL, error in
            completion(callbackURL, error)
        }
        
        session.presentationContextProvider = self
        // Permite to keep session Apple/Google active
        session.prefersEphemeralWebBrowserSession = false
        session.start()
    }

    func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        let window = UIApplication.shared.connectedScenes
            .filter { $0.activationState == .foregroundActive }
            .compactMap { $0 as? UIWindowScene }
            .first?.windows
            .first { $0.isKeyWindow }
        
        return window ?? ASPresentationAnchor()
    }
}
