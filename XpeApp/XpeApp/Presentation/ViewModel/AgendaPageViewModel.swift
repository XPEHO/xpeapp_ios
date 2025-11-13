//
//  AgendaPageViewModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 24/03/2025.
//

import Foundation
import Combine

class AgendaPageViewModel: ObservableObject {
    static let instance = AgendaPageViewModel()

    // Analytics client injected (default to shared AnalyticsModel)
    private let analytics: AnalyticsModel

    // Allow injection for testability; default uses AnalyticsModel.shared
    init(analytics: AnalyticsModel = AnalyticsModel.shared) {
        self.analytics = analytics
        initFetchWeeklyEvents()
        initFetchEvents()
        initGetAllEventsTypes()
        initFetchWeeklyBirthday()
        initFetchBirthday()
    }

    @Published var Weeklyevents: [EventEntity]? = nil
    @Published var events: [EventEntity]? = nil
    @Published var eventsTypes: [EventTypeEntity]? = nil
    @Published var Weeklybirthdays: [BirthdayEntity]? = nil
    @Published var birthdays: [BirthdayEntity]? = nil
    
    @Published var isLoading: Bool = false
    
    func update() {
        initFetchWeeklyEvents()
        initFetchEvents()
        initGetAllEventsTypes()
        initFetchWeeklyBirthday()
        initFetchBirthday()
    }

    // MARK: - Analytics helpers
    func trackEvent(_ name: String, parameters: [String: Any]? = nil) {
        analytics.trackEvent(name, parameters: parameters)
    }

    func trackScreen(_ name: String, parameters: [String: Any]? = nil) {
        analytics.trackScreen(name, parameters: parameters)
    }
    
    private func initFetchWeeklyEvents() {
        Task {
            if let weeklyEvents = await AgendaRepositoryImpl.instance.getAllEvents(page: "week") {
                DispatchQueue.main.async {
                    self.Weeklyevents = weeklyEvents
                }
            }
        }
    }
    
    private func initFetchEvents() {
        Task {
            if let Events = await AgendaRepositoryImpl.instance.getAllEvents(page:"month") {
                DispatchQueue.main.async {
                    self.events = Events
                }
            }
        }
    }
    
    private func initGetAllEventsTypes() {
        Task {
            if let obtainedAllEventsTypesFetched = await AgendaRepositoryImpl.instance.getAllEventsTypes() {
                DispatchQueue.main.async {
                    self.eventsTypes = obtainedAllEventsTypesFetched
                }
            }
        }
    }
    
    private func initFetchWeeklyBirthday() {
        Task {
            if let obtainedAllWeeklyBirthdaysFetched = await AgendaRepositoryImpl.instance.getAllBirthdays(page: "week") {
                DispatchQueue.main.async {
                    self.Weeklybirthdays = obtainedAllWeeklyBirthdaysFetched
                }
            }
        }
    }
    
    private func initFetchBirthday() {
        Task {
            if let obtainedAllBirthdaysFetched = await AgendaRepositoryImpl.instance.getAllBirthdays(page:"month") {
                DispatchQueue.main.async {
                    self.birthdays = obtainedAllBirthdaysFetched
                }
            }
        }
    }
}
