//
//  EventCombinedItemEnum.swift
//  XpeApp
//
//  Created by Théo Lebègue on 01/04/2025.
//

// Helper enum to combine events and birthdays

import Foundation

enum EventCombinedItemEnum {
    case event(EventEntity)
    case birthday(BirthdayEntity)

    var date: Date {
        switch self {
        case .event(let event):
            return event.date
        case .birthday(let birthday):
            return birthday.birthdate
        }
    }

    var id: String {
        switch self {
        case .event(let event):
            return event.id
        case .birthday(let birthday):
            return birthday.id
        }
    }
}
