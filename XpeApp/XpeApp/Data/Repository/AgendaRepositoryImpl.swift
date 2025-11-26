//
//  AgendaRepositoryImpl.swift
//  XpeApp
//
//  Created by Théo Lebègue on 24/03/2025.
//

import Foundation

@Observable class AgendaRepositoryImpl: AgendaRepository {
    // An instance for app and a mock for tests
    static let instance = AgendaRepositoryImpl()
    static let mock = AgendaRepositoryImpl(
        dataSource: MockWordpressAPI.instance
    )
    
    // Data source to use
    private let dataSource: WordpressAPIProtocol
    // Analytics client
    private let analytics: AnalyticsModel
    
    // Make private constructor to prevent use without shared instances
    private init(
        dataSource: WordpressAPIProtocol = WordpressAPI.instance,
        analytics: AnalyticsModel = AnalyticsModel.shared
    ) {
        self.dataSource = dataSource
        self.analytics = analytics
    }
    
    
    // getAllEvents
    func getAllEvents(page: String? = nil) async -> [EventEntity]? {
        // Telemetry
        CrashlyticsUtils.setCurrentFeature("agenda")
        CrashlyticsUtils.logEvent("Agenda attempt: getAllEvents")

        // Fetch data
        guard let events = await dataSource.fetchAllEvents(page: page) else {
            CrashlyticsUtils.logEvent("Agenda error: fetchAllEvents returned nil in getAllEvents")
            CrashlyticsUtils.setCustomKey("last_agenda_error", value: "fetchAllEvents_nil")
            CrashlyticsUtils.setCustomKey("last_agenda_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to fetchAllEvents in getAllEvents")
            return nil
        }

        return events.sorted(by: { $0.date > $1.date }).map { model in
            model.toEntity()
        }
    }
    
    // getAllEventsTypes
    func getAllEventsTypes() async -> [EventTypeEntity]? {
        // Telemetry
        CrashlyticsUtils.setCurrentFeature("agenda")
        CrashlyticsUtils.logEvent("Agenda attempt: getAllEventsTypes")

        // Fetch data
        guard let eventsTypes = await dataSource.fetchAllEventsTypes() else {
            CrashlyticsUtils.logEvent("Agenda error: fetchAllEventsTypes returned nil in getAllEventsTypes")
            CrashlyticsUtils.setCustomKey("last_agenda_error", value: "fetchAllEventsTypes_nil")
            CrashlyticsUtils.setCustomKey("last_agenda_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to fetchAllEventsTypes in getAllEventsTypes")
            return nil
        }

        return eventsTypes.map { model in
            model.toEntity()
        }
        
    }
    
    // getAllBirthday
    func getAllBirthdays(page: String? = nil) async -> [BirthdayEntity]? {
        // Telemetry
        CrashlyticsUtils.setCurrentFeature("agenda")
        CrashlyticsUtils.logEvent("Agenda attempt: getAllBirthdays")

        // Fetch data
        guard let birthdays = await dataSource.fetchAllBirthdays(page: page) else {
            CrashlyticsUtils.logEvent("Agenda error: fetchAllBirthdays returned nil in getAllBirthdays")
            CrashlyticsUtils.setCustomKey("last_agenda_error", value: "fetchAllBirthdays_nil")
            CrashlyticsUtils.setCustomKey("last_agenda_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to fetchAllBirthdays in getAllBirthdays")
            return nil
        }

        return birthdays.sorted(by: { $0.birthdate > $1.birthdate }).map { model in
            model.toEntity()
        }
        
    }
    
}
