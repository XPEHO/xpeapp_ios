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
        VStack(spacing: 10) {
            
            // List of events
            ForEach(events.indices, id: \.self) { indices in
                EventCard(
                    event: $events[indices],
                    eventTypes: $eventTypes
                )
            }

            // List of birthdays
            ForEach(birthdays.indices, id: \.self) { index in
                BirthdayCard(birthday: .constant(birthdays[index]))
            }
        }
    }
}
