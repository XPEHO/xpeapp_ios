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
    var collapsable: Bool = false

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
                collapsable: collapsable
            )
        }
    }

    // Get the tag pills for an event
    private func getTagsList(event: EventEntity, eventTypes: [EventTypeEntity], color: Color) -> [TagPill] {
        let overlayColor = Color(hex: "7C4000").opacity(0.2)
        let tagColor = color.blended(with: overlayColor)

        var result: [TagPill] = []

        // Add the event date
        result.append(TagPill(label: dateDayAndMonthFormatter.string(from: event.date), backgroundColor: tagColor))

        // Format the time strings by removing the last three characters ("12:00:00" -> "12:00")
        func formatTime(_ time: String) -> String {
            if time.count > 2 {
                return String(time.dropLast(3))
            }
            return time 
        }

        // Add the time range if both startTime and endTime exist
        if let startTime = event.startTime, let endTime = event.endTime {
            let formattedStartTime = formatTime(startTime)
            let formattedEndTime = formatTime(endTime)
            let timeRange = "De: \(formattedStartTime) à: \(formattedEndTime)"
            result.append(TagPill(label: timeRange, backgroundColor: tagColor))
        } else if let startTime = event.startTime {
            // If only startTime exists
            let formattedStartTime = formatTime(startTime)
            result.append(TagPill(label: "De: \(formattedStartTime)", backgroundColor: tagColor))
        } else if let endTime = event.endTime {
            // If only endTime exists
            let formattedEndTime = formatTime(endTime)
            result.append(TagPill(label: "À: \(formattedEndTime)", backgroundColor: tagColor))
        }

        // Add the event type if it exists
        if let eventType = eventTypes.first(where: { $0.id == event.typeId }), !eventType.label.isEmpty {
            result.append(TagPill(label: eventType.label, backgroundColor: tagColor))
        }

        // Add the location if it exists and is not empty
        if let location = event.location, !location.isEmpty {
            result.append(
                TagPill(
                    label: location,
                    backgroundColor: tagColor,
                    icon: AnyView(
                        Image("Location")
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                    )
                )
            )
        }

        // Add the topic if it exists and is not empty
        if let topic = event.topic, !topic.isEmpty {
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
