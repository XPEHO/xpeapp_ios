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
    
    // Make private constructor to prevent use without shared instances
    private init(
        dataSource: WordpressAPIProtocol = WordpressAPI.instance
    ) {
        self.dataSource = dataSource
    }
    
    
    // getAllEvents
    func getAllEvents(page: String? = nil) async -> [EventEntity]? {
        // Fetch data
        guard let events = await dataSource.fetchAllEvents(page: page) else {
            debugPrint("Failed call to fetchAllEvents in getAllEvents")
            return nil
        }
        
        return events.sorted(by: { $0.date > $1.date }).map { model in
            model.toEntity()
        }
    }
    
    // getAllEventsTypes
    func getAllEventsTypes() async -> [EventTypeEntity]? {
        // Fetch data
        guard let eventsTypes = await dataSource.fetchAllEventsTypes() else {
            debugPrint("Failed call to fetchAllEventsTypes in getAllEventsTypes")
            return nil
        }
        
        return eventsTypes.map { model in
            model.toEntity()
        }
        
    }
    
    // getAllBirthday
    func getAllBirthdays(page: String? = nil) async -> [BirthdayEntity]? {
        // Fetch data
        guard let birthdays = await dataSource.fetchAllBirthdays(page: page) else {
            debugPrint("Failed call to fetchAllBirthdays in getAllBirthdays")
            return nil
        }
        
        return birthdays.sorted(by: { $0.birthdate > $1.birthdate }).map { model in
            model.toEntity()
        }
        
    }
    
}
