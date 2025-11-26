//
//  QvstRepositoryImpl.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 23/08/2024.
//

import Foundation

class QvstRepositoryImpl: QvstRepository {
    // An instance for app and a mock for tests
    static let instance = QvstRepositoryImpl()
    static let mock = QvstRepositoryImpl(
        dataSource: MockWordpressAPI.instance,
        userRepo: UserRepositoryImpl.mock
    )
    
    // Data source and user repo to use (so we can mock them)
    private let dataSource: WordpressAPIProtocol
    private let userRepo: UserRepositoryImpl
    // Analytics client
    private let analytics: AnalyticsModel

    // Make private constructor to prevent use without shared instances
    private init(
        dataSource: WordpressAPIProtocol = WordpressAPI.instance,
        userRepo: UserRepositoryImpl = UserRepositoryImpl.instance,
        analytics: AnalyticsModel = AnalyticsModel.shared
    ) {
        self.dataSource = dataSource
        self.userRepo = userRepo
        self.analytics = analytics
    }
    
    private func convertCampaignsToEntities(
        campaignsModels: [QvstCampaignModel],
        progressesModels: [QvstProgressModel]
    ) -> [QvstCampaignEntity]{
        
        var campaignsEntities: [QvstCampaignEntity] = []

        // Filter out campaigns with status "DRAFT"
        let filteredCampaignsModels = campaignsModels.filter { $0.status != "DRAFT" }
        
        for campaign in filteredCampaignsModels {
        
            var remainingDays = 0
            if let remainingDaysTry = countDaysBetween(Date(), and: campaign.endDate) {
                remainingDays = remainingDaysTry
            }
            
            var completed = false
            // Try to find if there is an existing progress
            if let campaignProgress = (progressesModels.filter{$0.campaignId == campaign.id}.first) {
                completed = campaignProgress.answeredQuestionsCount >= campaignProgress.totalQuestionsCount ?? ""
            }
            
            campaignsEntities.append(
                QvstCampaignEntity(
                    id: campaign.id,
                    name: campaign.name,
                    themeNames: campaign.themes.map { $0.name },
                    status: campaign.status,
                    outdated: remainingDays <= 0,
                    completed: completed,
                    remainingDays: remainingDays,
                    endDate: campaign.endDate,
                    resultLink: campaign.action
                )
            )
        }
        
        return campaignsEntities.sorted { $0.endDate > $1.endDate }
    }
    
    // Classify campaigns by year and status
    func classifyCampaigns(campaigns: [QvstCampaignEntity]) -> [Int: [QvstCampaignEntity]] {
        return campaigns.reduce(into: [Int: [QvstCampaignEntity]]()) { classifiedCampaigns, campaign in
            let year = Calendar.current.component(.year, from: campaign.endDate)
            classifiedCampaigns[year, default: []].append(campaign)
        }
    }
    
    func getCampaigns() async -> [QvstCampaignEntity]? {
        // Telemetry
        CrashlyticsUtils.setCurrentFeature("qvst")
        CrashlyticsUtils.logEvent("Qvst attempt: getCampaigns")

        // Fetch data
        guard let user = userRepo.user else {
            CrashlyticsUtils.logEvent("Qvst error: no user in getCampaigns")
            CrashlyticsUtils.setCustomKey("last_qvst_error", value: "no_user")
            CrashlyticsUtils.setCustomKey("last_qvst_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("No user to use in getCampaigns")
            return nil
        }
        guard let campaignsModels = await dataSource.fetchAllCampaigns() else {
            CrashlyticsUtils.logEvent("Qvst error: fetchAllCampaigns returned nil in getCampaigns")
            CrashlyticsUtils.setCustomKey("last_qvst_error", value: "fetchAllCampaigns_nil")
            CrashlyticsUtils.setCustomKey("last_qvst_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to fetchAllCampaigns in getCampaigns")
            return nil
        }
        guard let campaignsProgressModels = await dataSource.fetchCampaignsProgress(
            userId: user.id
        ) else {
            CrashlyticsUtils.logEvent("Qvst error: fetchCampaignsProgress returned nil in getCampaigns")
            CrashlyticsUtils.setCustomKey("last_qvst_error", value: "fetchCampaignsProgress_nil")
            CrashlyticsUtils.setCustomKey("last_qvst_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to fetchCampaignsProgress in getCampaigns")
            return nil
        }
        
        // Return data
        return convertCampaignsToEntities(
            campaignsModels: campaignsModels,
            progressesModels: campaignsProgressModels
        )
    }
    
    func getActiveCampaigns() async -> [QvstCampaignEntity]? {
        // Telemetry
        CrashlyticsUtils.setCurrentFeature("qvst")
        CrashlyticsUtils.logEvent("Qvst attempt: getActiveCampaigns")

        // Fetch data
        guard let user = userRepo.user else {
            CrashlyticsUtils.logEvent("Qvst error: no user in getActiveCampaigns")
            CrashlyticsUtils.setCustomKey("last_qvst_error", value: "no_user")
            CrashlyticsUtils.setCustomKey("last_qvst_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("No user to use in getCampaigns")
            return nil
        }
        guard let activeCampaignsModels = await dataSource.fetchActiveCampaigns() else {
            CrashlyticsUtils.logEvent("Qvst error: fetchActiveCampaigns returned nil in getActiveCampaigns")
            CrashlyticsUtils.setCustomKey("last_qvst_error", value: "fetchActiveCampaigns_nil")
            CrashlyticsUtils.setCustomKey("last_qvst_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to fetchActiveCampaigns in getActiveCampaigns")
            return nil
        }
        guard let campaignsProgressModels = await dataSource.fetchCampaignsProgress(userId: user.id) else {
            CrashlyticsUtils.logEvent("Qvst error: fetchCampaignsProgress returned nil in getActiveCampaigns")
            CrashlyticsUtils.setCustomKey("last_qvst_error", value: "fetchCampaignsProgress_nil")
            CrashlyticsUtils.setCustomKey("last_qvst_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to fetchCampaignsProgress in getCampaigns")
            return nil
        }
        
        // Return data
        return convertCampaignsToEntities(
            campaignsModels: activeCampaignsModels,
            progressesModels: campaignsProgressModels
        )
    }
}

