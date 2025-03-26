//
//  AgendaPageViewModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 24/03/2025.
//

import Foundation

@Observable class AgendaPageViewModel {
    
    static let instance = AgendaPageViewModel()
    
    // Make private constructor to prevent use without shared instance
    private init() {
        initFetchWeeklyEvents()
        initGetAllEventsTypes()
        initFetchWeeklyBirthday()
    }

    var events: [EventEntity]? = nil
    var eventsTypes: [EventTypeEntity]? = nil
    var birthdays: [BirthdayEntity]? = nil
    
    func update() {
        initFetchWeeklyEvents()
        initGetAllEventsTypes()
        initFetchWeeklyBirthday()
    }
    
    private func initFetchWeeklyEvents() {
        Task {
            if let weeklyEvents = await AgendaRepositoryImpl.instance.getAllEvents(page: "week") {
                DispatchQueue.main.async {
                    self.events = weeklyEvents
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
                    self.birthdays = obtainedAllWeeklyBirthdaysFetched
                }
            }
        }
    }
}
