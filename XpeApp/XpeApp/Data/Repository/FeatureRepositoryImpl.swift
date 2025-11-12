//
//  FeatureRepositoryImpl.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 03/09/2024.
//

import Foundation

class FeatureRepositoryImpl: FeatureRepository {
    // An instance for app and a mock for tests
    static let instance = FeatureRepositoryImpl()
    static let mock = FeatureRepositoryImpl(
        dataSource: MockFirebaseAPI.instance
    )
    
    // Data source to use
    private let dataSource: FirebaseAPIProtocol
    // Analytics client
    private let analytics: AnalyticsModel

    // Make private constructor to prevent use without shared instances
    private init(
        dataSource: FirebaseAPIProtocol = FirebaseAPI.instance,
        analytics: AnalyticsModel = AnalyticsModel.shared
    ) {
        self.dataSource = dataSource
        self.analytics = analytics
    }
    
    func getFeatures() async -> [String : FeatureEntity]? {
        // Telemetry
        CrashlyticsUtils.setCurrentFeature("feature")
        CrashlyticsUtils.logEvent("Feature attempt: getFeatures")

        // Fetch data
        guard let features = await dataSource.fetchAllFeatures() else {
            CrashlyticsUtils.logEvent("Feature error: fetchAllFeatures returned nil in getFeatures")
            CrashlyticsUtils.setCustomKey("last_feature_error", value: "fetchAllFeatures_nil")
            CrashlyticsUtils.setCustomKey("last_feature_error_time", value: String(Int(Date().timeIntervalSince1970 * 1000)))
            debugPrint("Failed call to fetchAllFeatures in getFeatures")
            return nil
        }

        return features.reduce(into: [String: FeatureEntity]()) { result, feature in
            if let id = feature.id {
                result[id] = feature.toEntity()
            }
        }
    }
}
