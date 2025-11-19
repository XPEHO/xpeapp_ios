//
//  NewsletterRepositoryImpl.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 23/08/2024.
//

import Foundation

class NewsletterRepositoryImpl: NewsletterRepository {
    // An instance for app and a mock for tests
    static let instance = NewsletterRepositoryImpl()
    static let mock = NewsletterRepositoryImpl(
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
    
    func getNewsletters() async -> [NewsletterEntity]? {
        // Telemetry
        CrashlyticsUtils.setCurrentFeature("newsletter")
        CrashlyticsUtils.logEvent("Newsletter attempt: getNewsletters")

        // Fetch data
        guard let newsletters = await dataSource.fetchAllNewsletters() else {
            CrashlyticsUtils.logEvent("Newsletter error: fetchAllNewsletters returned nil in getNewsletters")
            CrashlyticsUtils.setCustomKey("last_newsletter_error", value: "fetchAllNewsletters_nil")
            CrashlyticsUtils.setCustomKey("last_newsletter_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to fetchAllNewsletters in getNewsletters")
            return nil
        }

        return newsletters.sorted(by: { $0.date > $1.date }).map { model in
            model.toEntity()
        }
    }
    
    func getLastNewsletter() async -> NewsletterEntity? {
        // Telemetry
        CrashlyticsUtils.setCurrentFeature("newsletter")
        CrashlyticsUtils.logEvent("Newsletter attempt: getLastNewsletter")

        // Fetch data
        guard let newsletters = await dataSource.fetchAllNewsletters() else {
            CrashlyticsUtils.logEvent("Newsletter error: fetchAllNewsletters returned nil in getLastNewsletter")
            CrashlyticsUtils.setCustomKey("last_newsletter_error", value: "fetchAllNewsletters_nil")
            CrashlyticsUtils.setCustomKey("last_newsletter_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to fetchAllNewsletters in getLastNewsletter")
            return nil
        }

        let sortedNewsletters = newsletters.sorted(by: { $0.date < $1.date })
        
        return sortedNewsletters.last?.toEntity()
    }
    
    func getNewsletterPreviewUrl(newsletter: NewsletterEntity?, completion: @escaping (String?) -> Void) {
        CrashlyticsUtils.setCurrentFeature("newsletter")
        CrashlyticsUtils.logEvent("Newsletter attempt: getNewsletterPreviewUrl")

        guard let newsletter = newsletter else {
            CrashlyticsUtils.logEvent("Newsletter error: no newsletter in getNewsletterPreviewUrl")
            CrashlyticsUtils.setCustomKey("last_newsletter_error", value: "no_newsletter")
            CrashlyticsUtils.setCustomKey("last_newsletter_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("No newsletter")
            return
        }
        dataSource.getNewsletterPreviewUrl(previewPath: newsletter.previewPath) { url in
            completion(url)
        }
    }

    // Classify newsletters by year
    func classifyNewsletters(newsletters: [NewsletterEntity]) -> [Int: [NewsletterEntity]] {
        return newsletters.reduce(into: [Int: [NewsletterEntity]]()) { classifiedNewsletters, newsletter in
            let year = Calendar.current.component(.year, from: newsletter.date)
            classifiedNewsletters[year, default: []].append(newsletter)
        }
    }
}
