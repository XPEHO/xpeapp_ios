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
            VStack(alignment: .leading) {
                
                Title(text: "Agenda")
                
                if let allEvents = Binding($agendaViewModel.events),
                let allBirthdays =  Binding($agendaViewModel.birthdays),
                let allEventsTypes =  Binding($agendaViewModel.eventsTypes) {
                    // Display event list
                    EventsList(
                        events: allEvents,
                        eventTypes: allEventsTypes,
                        birthdays: allBirthdays,
                        collapsable: true
                    )
                } else {
                    ProgressView("Chargement de l'agenda...")
                        .progressViewStyle(CircularProgressViewStyle())
                        .padding()
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
