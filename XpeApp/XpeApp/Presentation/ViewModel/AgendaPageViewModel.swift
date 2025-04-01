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
    
    // Make private constructor to prevent use without shared instance
    private init() {
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
            if let Events = await AgendaRepositoryImpl.instance.getAllEvents() {
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
            if let obtainedAllBirthdaysFetched = await AgendaRepositoryImpl.instance.getAllBirthdays() {
                DispatchQueue.main.async {
                    self.birthdays = obtainedAllBirthdaysFetched
                }
            }
        }
    }
}
