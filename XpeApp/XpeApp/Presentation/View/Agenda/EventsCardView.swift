//
//  EventsCardView.swift
//  XpeApp
//
//  Created par Théo Lebègue on 24/03/2025.
//

import SwiftUI
import xpeho_ui

struct EventCard: View {
    @Binding var event: EventEntity
    @Binding var eventTypes: [EventTypeEntity]

    var body: some View {
            let eventTypeColor = getEventTypeColor(event: event, eventTypes: eventTypes)
            let eventTypeIcon = getEventTypeIcon(event: event, eventTypes: eventTypes)

            CollapsableCard(
                label: event.title,
                tags: getTagsList(event: event, eventTypes: eventTypes, color: eventTypeColor),
                icon: AnyView(
                    Image(eventTypeIcon)
                        .renderingMode(.template)
                        .foregroundStyle(eventTypeColor)
                ),
                collapsable: false
            )
        }
    }

    // Get the tag pills for an event
    private func getTagsList(event: EventEntity, eventTypes: [EventTypeEntity], color: Color) -> [TagPill] {
        let overlayColor = Color(hex: "7C4000").opacity(0.2)
        let tagColor = color.blended(with: overlayColor)

        var result: [TagPill] = []

        result.append(TagPill(label: event.date.formatted(date: .numeric, time: .omitted), backgroundColor: tagColor))

        if let startTime = event.startTime {
            result.append(TagPill(label: startTime.formatted(date: .omitted, time: .shortened), backgroundColor: tagColor))
        }

        if let endTime = event.endTime {
            result.append(TagPill(label: endTime.formatted(date: .omitted, time: .shortened), backgroundColor: tagColor))
        }

        if let eventType = eventTypes.first(where: { $0.id == event.typeId }) {
            result.append(TagPill(label: eventType.label, backgroundColor: tagColor))
        }

        if let location = event.location {
            result.append(TagPill(label: location, backgroundColor: tagColor))
        }

        if let topic = event.topic {
            result.append(TagPill(label: topic, backgroundColor: tagColor))
        }

        return result
    }

    // Get the color of the event type
    private func getEventTypeColor(event: EventEntity, eventTypes: [EventTypeEntity]) -> Color {
        if let eventType = eventTypes.first(where: { $0.id == event.typeId }) {
            return Color(hex: eventType.colorCode)
        }
        return XPEHO_THEME.XPEHO_COLOR
    }

    // Get the icon of the event type
    private func getEventTypeIcon(event: EventEntity, eventTypes: [EventTypeEntity]) -> String {
        if let eventType = eventTypes.first(where: { $0.id == event.typeId }) {
            switch eventType.label {
            case "XpeUp":
                return "Learn"
            case "Event interne":
                return "Building"
            case "Formation":
                return "Study"
            case "RSE":
                return "Leaf"
            case "Activité":
                return "Gamepad"
            case "Event externe":
                return "Outside"
            default:
                return "Building"
            }
        }
        return "Building"
    }
