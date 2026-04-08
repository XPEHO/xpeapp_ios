//
//  UtilsUI.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 03/12/2024.
//

import Foundation
import SwiftUI
import AuthenticationServices


// Util function to open a pdf url
func openPdf(url: String, toastManager: ToastManager, openMethod: OpenURLAction) {
    guard let urlObj = URL(string: url),
          let scheme = urlObj.scheme?.lowercased(),
          (scheme == "http" || scheme == "https")
    else {
        toastManager.setParams(
            message: "Impossible d'ouvrir l'URL",
            error: true
        )
        toastManager.play()
        return
    }
    openMethod(urlObj)
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

final class IdeaStatusSyncManager {
    static let instance = IdeaStatusSyncManager()

    private let api: WordpressAPIProtocol
    private let bannerManager: HomeInfoBannerManager
    private let userDefaults: UserDefaults

    private let statusesKey = "idea_box_last_known_status_by_id"
    private let initialSyncKey = "idea_box_status_initial_sync_done"
    private let fixedBannerMessage = "Du nouveau sur ta suggestion : Clique pour avoir des infos"

    private init(
        api: WordpressAPIProtocol = WordpressAPI.instance,
        bannerManager: HomeInfoBannerManager = HomeInfoBannerManager.instance,
        userDefaults: UserDefaults = .standard
    ) {
        self.api = api
        self.bannerManager = bannerManager
        self.userDefaults = userDefaults
    }

    func syncAndNotifyIfNeeded() async {
        guard UserRepositoryImpl.instance.user != nil,
              let ideas = await api.fetchMyIdeas() else { return }

        let newStatuses = Dictionary(uniqueKeysWithValues: ideas.map { ($0.id, $0.status) })

        if !userDefaults.bool(forKey: initialSyncKey) {
            persist(newStatuses)
            userDefaults.set(true, forKey: initialSyncKey)
            return
        }

        let oldStatuses = userDefaults.dictionary(forKey: statusesKey) as? [String: String] ?? [:]
        
        let changedIdeas = ideas.filter { idea in
            guard let old = oldStatuses[idea.id] else { return false }
            return old.caseInsensitiveCompare(idea.status) != .orderedSame
        }

        persist(newStatuses)

        if !changedIdeas.isEmpty {
            let targetIdeaId = changedIdeas.first?.id
            await MainActor.run {
                bannerManager.publish(message: fixedBannerMessage, targetIdeaId: targetIdeaId)
            }
        }
    }

    private func persist(_ statuses: [String: String]) {
        userDefaults.set(statuses, forKey: statusesKey)
    }
}

@Observable final class HomeInfoBannerManager {
    static let instance = HomeInfoBannerManager()

    private let userDefaults: UserDefaults
    private let msgKey = "home_info_banner_message_v2"
    private let expKey = "home_info_banner_expiry_v2"
    private let targetIdeaIdKey = "home_info_banner_target_idea_id_v1"

    var message: String?
    var targetIdeaId: String?

    private init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        checkExpiry()
    }

    func publish(message: String, targetIdeaId: String? = nil) {
        let content = message.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !content.isEmpty else { return clear() }

        userDefaults.set(content, forKey: msgKey)
        let expiryDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        userDefaults.set(expiryDate.timeIntervalSince1970, forKey: expKey)
        if let targetIdeaId,
           !targetIdeaId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            userDefaults.set(targetIdeaId, forKey: targetIdeaIdKey)
            self.targetIdeaId = targetIdeaId
        } else {
            userDefaults.removeObject(forKey: targetIdeaIdKey)
            self.targetIdeaId = nil
        }
        self.message = content
    }

    func checkExpiry() {
        let expiry = userDefaults.double(forKey: expKey)
        if expiry > 0 && Date().timeIntervalSince1970 < expiry {
            message = userDefaults.string(forKey: msgKey)
            targetIdeaId = userDefaults.string(forKey: targetIdeaIdKey)
        } else {
            clear()
        }
    }

    func refresh() {
        checkExpiry()
    }

    func clear() {
        userDefaults.removeObject(forKey: msgKey)
        userDefaults.removeObject(forKey: expKey)
        userDefaults.removeObject(forKey: targetIdeaIdKey)
        message = nil
        targetIdeaId = nil
    }
}
