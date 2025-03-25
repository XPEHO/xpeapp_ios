//
//  AgendaRepository.swift
//  XpeApp
//
//  Created by Théo Lebègue on 24/03/2025.
//

import Foundation

protocol AgendaRepository {
    func getAllEvents(page: String?) async -> [EventEntity]?
    func getAllEventsTypes() async -> [EventTypeEntity]?
    func getAllBirthdays(page: String?) async -> [BirthdayEntity]?
}
