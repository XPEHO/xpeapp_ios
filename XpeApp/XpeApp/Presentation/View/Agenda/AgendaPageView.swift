//
//  AgendaPageView.swift
//  XpeApp
//
//  Created by Théo Lebègue on 31/03/2025.
//

import SwiftUI
import xpeho_ui

struct AgendaPage: View {
    private var featureManager = FeatureManager.instance
    @StateObject private var agendaViewModel = AgendaPageViewModel.instance

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Title(text: "Agenda")
                
                if let allEvents = Binding($agendaViewModel.events),
                   let allBirthdays = Binding($agendaViewModel.birthdays),
                   let allEventsTypes = Binding($agendaViewModel.eventsTypes) {
                    
                    
                    let hasContent = !allEvents.wrappedValue.isEmpty ||
                    !allBirthdays.wrappedValue.isEmpty
                    
                    if hasContent {
                        EventsList(
                            events: allEvents,
                            eventTypes: allEventsTypes,
                            birthdays: allBirthdays,
                            collapsable: true
                        )
                    } else {
                        NoContentPlaceHolder().frame(maxWidth: .infinity)
                    }
                } else {
                    ProgressView("Chargement de l'agenda…")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
                        .frame(maxWidth: .infinity)
                }
            }
        }
        .onAppear {
            agendaViewModel.update()
            sendAnalyticsEvent(page: "agenda_page")
        }
        .refreshable {
            agendaViewModel.update()
            featureManager.update()
        }
        .accessibility(identifier: "AgendaView")
    }
}
