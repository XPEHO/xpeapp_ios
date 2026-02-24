//
//  QvstRepositoryTests.swift
//  XpeAppTests
//
//  Created by Ryan Debouvries on 21/08/2024.
//

import XCTest
@testable import XpeApp

final class QvstRepositoryTests: XCTestCase {
    // We take the mocked repositories and sources
    let qvstRepo = QvstRepositoryImpl.mock
    let qvstSource = MockWordpressAPI.instance
    let userRepo = UserRepositoryImpl.mock

    override func setUp() {
        super.setUp()
        // Reset mock data before each test
        qvstSource.fetchAllCampaignsReturnData = nil
        qvstSource.fetchActiveCampaignsReturnData = nil
        qvstSource.fetchCampaignsProgressReturnData = nil
        userRepo.user = nil
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    // ------------------- getCampaigns TESTS -------------------

    func test_getCampaigns_fetchAllCampaignsError() async throws {
        // GIVEN
        qvstSource.fetchAllCampaignsReturnData = nil
        userRepo.user = UserEntity(
            token: "token",
            id: "user_id"
        )
        qvstSource.fetchCampaignsProgressReturnData = [
            QvstProgressModel(
                userId: "user_id",
                campaignId: "campaign_id",
                answeredQuestionsCount: "0",
                totalQuestionsCount: "0"
            )
        ]

        // WHEN
        let campaigns = await qvstRepo.getCampaigns()

        // THEN
        XCTAssertTrue(campaigns?.isEmpty ?? true)
    }
    
    func test_getCampaigns_NoUserError() async throws {
        let currentDate = Date()
        let currentDatePlusOneDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        // GIVEN
        qvstSource.fetchAllCampaignsReturnData = [
            QvstCampaignModel(
                id: "campaign_id",
                name: "Qvst Campaign",
                themes: [QvstThemeModel(id: "theme_id", name: "Qvst Theme")],
                status: "OPEN",
                startDate: currentDate,
                endDate: currentDatePlusOneDay,
                action: "action",
                participationRate: "rate"
            )
        ]
        userRepo.user = nil
        qvstSource.fetchCampaignsProgressReturnData = [
            QvstProgressModel(
                userId: "user_id",
                campaignId: "campaign_id",
                answeredQuestionsCount: "0",
                totalQuestionsCount: "0"
            )
        ]

        // WHEN
        let campaigns = await qvstRepo.getCampaigns()

        // THEN
        XCTAssertTrue(campaigns?.isEmpty ?? true)
    }
    
    func test_getCampaigns_fetchCampaignsProgressError() async throws {
        let currentDate = Date()
        let currentDatePlusOneDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        // GIVEN
        qvstSource.fetchAllCampaignsReturnData = [
            QvstCampaignModel(
                id: "campaign_id",
                name: "Qvst Campaign",
                themes: [QvstThemeModel(id: "theme_id", name: "Qvst Theme")],
                status: "OPEN",
                startDate: currentDate,
                endDate: currentDatePlusOneDay,
                action: "action",
                participationRate: "rate"
            )
        ]
        userRepo.user = UserEntity(
            token: "token",
            id: "user_id"
        )
        qvstSource.fetchCampaignsProgressReturnData = nil

        // WHEN
        let campaigns = await qvstRepo.getCampaigns()

        // THEN
        XCTAssertTrue(campaigns?.isEmpty ?? true)
    }
    
    func test_getCampaigns_Success() async throws {
        let currentDate = Date()
        let currentDatePlusOneDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        // GIVEN
        qvstSource.fetchAllCampaignsReturnData = [
            QvstCampaignModel(
                id: "campaign_id",
                name: "Qvst Campaign",
                themes: [QvstThemeModel(id: "theme_id", name: "Qvst Theme")],
                status: "OPEN",
                startDate: currentDate,
                endDate: currentDatePlusOneDay,
                action: "action",
                participationRate: "rate"
            )
        ]
        userRepo.user = UserEntity(
            token: "token",
            id: "user_id"
        )
        qvstSource.fetchCampaignsProgressReturnData = [
            QvstProgressModel(
                userId: "user_id",
                campaignId: "campaign_id",
                answeredQuestionsCount: "2",
                totalQuestionsCount: "2"
            ),
            QvstProgressModel(
                userId: "user_id",
                campaignId: "campaign_id_2",
                answeredQuestionsCount: "2",
                totalQuestionsCount: "4"
            )
        ]

        // WHEN
        let campaigns = await qvstRepo.getCampaigns()

        // THEN
        let dataExpected = [
            QvstCampaignEntity(
                id: "campaign_id",
                name: "Qvst Campaign",
                themeNames: ["Qvst Theme"],
                status: "OPEN",
                outdated: false,
                completed: true,
                remainingDays: 1,
                endDate: currentDatePlusOneDay,
                resultLink: "action"
            )
        ]
        XCTAssertNotNil(campaigns)
        XCTAssertEqual(campaigns!.count, 1)
        XCTAssertEqual(campaigns, dataExpected)
    }

    
    // ------------------- getActiveCampaigns TESTS -------------------

    func test_getActiveCampaigns_fetchActiveCampaignsError() async throws {
        // GIVEN
        qvstSource.fetchActiveCampaignsReturnData = nil
        userRepo.user = UserEntity(
            token: "token",
            id: "user_id"
        )
        qvstSource.fetchCampaignsProgressReturnData = [
            QvstProgressModel(
                userId: "user_id",
                campaignId: "campaign_id",
                answeredQuestionsCount: "0",
                totalQuestionsCount: "0"
            )
        ]

        // WHEN
        let activeCampaigns = await qvstRepo.getActiveCampaigns()

        // THEN
        XCTAssertTrue(activeCampaigns?.isEmpty ?? true)
    }
    
    func test_getActiveCampaigns_NoUserError() async throws {
        let currentDate = Date()
        let currentDatePlusOneDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        // GIVEN
        qvstSource.fetchActiveCampaignsReturnData = [
            QvstCampaignModel(
                id: "campaign_id",
                name: "Qvst Campaign",
                themes: [QvstThemeModel(id: "theme_id", name: "Qvst Theme")],
                status: "OPEN",
                startDate: currentDate,
                endDate: currentDatePlusOneDay,
                action: "action",
                participationRate: "rate"
            )
        ]
        userRepo.user = nil
        qvstSource.fetchCampaignsProgressReturnData = [
            QvstProgressModel(
                userId: "user_id",
                campaignId: "campaign_id",
                answeredQuestionsCount: "0",
                totalQuestionsCount: "0"
            )
        ]

        // WHEN
        let activeCampaigns = await qvstRepo.getActiveCampaigns()

        // THEN
        XCTAssertTrue(activeCampaigns?.isEmpty ?? true)
    }

    func test_getActiveCampaigns_fetchCampaignsProgressError() async throws {
        let currentDate = Date()
        let currentDatePlusOneDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        // GIVEN
        qvstSource.fetchActiveCampaignsReturnData = [
            QvstCampaignModel(
                id: "campaign_id",
                name: "Qvst Campaign",
                themes: [QvstThemeModel(id: "theme_id", name: "Qvst Theme")],
                status: "OPEN",
                startDate: currentDate,
                endDate: currentDatePlusOneDay,
                action: "action",
                participationRate: "rate"
            )
        ]
        userRepo.user = UserEntity(
            token: "token",
            id: "user_id"
        )
        qvstSource.fetchCampaignsProgressReturnData = nil

        // WHEN
        let activeCampaigns = await qvstRepo.getActiveCampaigns()

        // THEN
        XCTAssertTrue(activeCampaigns?.isEmpty ?? true)
    }

    func test_getActiveCampaigns_Success() async throws {
        let currentDate = Date()
        let currentDatePlusOneDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!

        // GIVEN
        qvstSource.fetchActiveCampaignsReturnData = [
            QvstCampaignModel(
                id: "campaign_id",
                name: "Qvst Campaign",
                themes: [QvstThemeModel(id: "theme_id", name: "Qvst Theme")],
                status: "OPEN",
                startDate: currentDate,
                endDate: currentDatePlusOneDay,
                action: "action",
                participationRate: "rate"
            )
        ]
        userRepo.user = UserEntity(
            token: "token",
            id: "user_id"
        )
        qvstSource.fetchCampaignsProgressReturnData = [
            QvstProgressModel(
                userId: "user_id",
                campaignId: "campaign_id",
                answeredQuestionsCount: "2",
                totalQuestionsCount: "2"
            ),
            QvstProgressModel(
                userId: "user_id",
                campaignId: "campaign_id_2",
                answeredQuestionsCount: "2",
                totalQuestionsCount: "4"
            )
        ]

        // WHEN
        let activeCampaigns = await qvstRepo.getActiveCampaigns()

        // THEN
        let dataExpected = [
            QvstCampaignEntity(
                id: "campaign_id",
                name: "Qvst Campaign",
                themeNames: ["Qvst Theme"],
                status: "OPEN",
                outdated: false,
                completed: true,
                remainingDays: 1,
                endDate: currentDatePlusOneDay,
                resultLink: "action"
            )
        ]
        XCTAssertNotNil(activeCampaigns)
        XCTAssertEqual(activeCampaigns!.count, 1)
        XCTAssertEqual(activeCampaigns, dataExpected)
    }

    
    // ------------------- classifyCampaigns TESTS -------------------

    func test_classifyCampaigns() throws {
        // GIVEN
        let currentDate = Calendar.current.date(from: DateComponents(year: 2025, month: 1, day: 1))!
        let currentDatePlusOneYear = Calendar.current.date(from: DateComponents(year: 2026, month: 1, day: 1))!
        let campaigns = [
            QvstCampaignEntity(
                id: "campaign_id_1",
                name: "Qvst Campaign 1",
                themeNames: ["Qvst Theme"],
                status: "OPEN",
                outdated: false,
                completed: true,
                remainingDays: 1,
                endDate: currentDatePlusOneYear,
                resultLink: "action 1"
            ),
            QvstCampaignEntity(
                id: "campaign_id_2",
                name: "Qvst Campaign 2",
                themeNames: ["Qvst Theme"],
                status: "CLOSED",
                outdated: true,
                completed: true,
                remainingDays: 0,
                endDate: currentDate,
                resultLink: "action 2"
            )
        ]

        // WHEN
        let classifiedCampaigns = qvstRepo.classifyCampaigns(campaigns: campaigns)

        // THEN
        XCTAssertNotNil(classifiedCampaigns)
        XCTAssertEqual(classifiedCampaigns[2026]?.first?.id, "campaign_id_1")
        XCTAssertEqual(classifiedCampaigns[2025]?.first?.id, "campaign_id_2")
    }
}

