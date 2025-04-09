//
//  EventsListView.swift
//  XpeApp
//
//  Created by Théo Lebègue on 25/03/2025.
//

import SwiftUI

struct EventsList: View {
    @Binding var events: [EventEntity]
    @Binding var eventTypes: [EventTypeEntity]
    @Binding var birthdays: [BirthdayEntity]
    var collapsable: Bool = false

    var body: some View {
        // Combine and sort events and birthdays by date
        let eventCombined = (events.map { EventCombinedItemEnum.event($0) } +
                             birthdays.map { EventCombinedItemEnum.birthday($0) })
            .sorted { $0.date < $1.date }

        VStack(spacing: 10) {
            ForEach(eventCombined, id: \.id) { item in
                switch item {
                case .event(let event):
                    EventCard(
                        event: .constant(event),
                        eventTypes: $eventTypes,
                        collapsable: collapsable
                    )
                case .birthday(let birthday):
                    BirthdayCard(
                        birthday: .constant(birthday),
                        collapsable: collapsable
                    )
                }
            }
        }
    }
}


