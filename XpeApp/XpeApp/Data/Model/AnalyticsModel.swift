//
//  AnalyticsModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 28/10/2025.
//

import Foundation
import FirebaseAnalytics
import Combine

class AnalyticsModel: ObservableObject {
    static var shared: AnalyticsModel = AnalyticsModel()

    // Toggle for enabling/disabling analytics
    var enabled: Bool = true

    init() {}

    func trackEvent(_ name: String, parameters: [String: Any]?) {
        guard enabled else { return }
        #if DEBUG
        debugPrint("[Analytics] event=\(name) params=\(String(describing: parameters))")
        #endif
        Analytics.logEvent(name, parameters: parameters)
    }

    func trackScreen(_ name: String, screenClass: String? = nil, parameters: [String: Any]?) {
        guard enabled else { return }
        let resolvedClass = screenClass ?? name
        #if DEBUG
        debugPrint("[Analytics] screen=\(name) class=\(resolvedClass) params=\(String(describing: parameters))")
        #endif
        var params = parameters ?? [:]
        params[AnalyticsParameterScreenName] = name
        params[AnalyticsParameterScreenClass] = resolvedClass
        Analytics.logEvent(AnalyticsEventScreenView, parameters: params)
    }

    func setUserId(_ id: String?) {
        #if DEBUG
        debugPrint("[Analytics] setUserId=\(String(describing: id))")
        #endif
        Analytics.setUserID(id)
    }

    func setUserProperty(_ value: String?, forName name: String) {
        #if DEBUG
        debugPrint("[Analytics] setUserProperty=\(String(describing: value)) name=\(name)")
        #endif
        Analytics.setUserProperty(value, forName: name)
    }

    func reset() {
        setUserId(nil)
    }
}

