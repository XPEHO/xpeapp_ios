//
//  HomePageView.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 12/08/2024.
//

import SwiftUI
import xpeho_ui

struct HomePage: View {
    @Bindable private var homePageViewModel = HomePageViewModel.instance
    @Bindable private var agendaViewModel = AgendaPageViewModel.instance
    private var featureManager = FeatureManager.instance
    private var userInfosViewModel = UserInfosPageViewModel.instance
    
    var body: some View {
        ScrollView {
            VStack {
                if lastNewsletterSectionIsEnabled() {
                    PageTitleSection(title: "Changement de tests pour PR")
                    Spacer().frame(height: 16)
                    LastNewsletterPreview(
                        lastNewsletter: homePageViewModel.lastNewsletter
                    )
                    Spacer().frame(height: 32)
                }
                if toNotMissSectionIsEnabled(),
                   let activeCampaigns = Binding($homePageViewModel.activeCampaigns)
                    {
                    PageTitleSection(title: "À ne pas manquer !")
                    Spacer().frame(height: 16)
                    CampaignsList(
                        campaigns: activeCampaigns,
                        collapsable: false,
                        defaultOpen: true
                    )
                }
                if lastWeeklyEventsSectionIsEnabled(),
                    let allWeeklyEvents = Binding($agendaViewModel.events),
                    let allWeeklyBirthdays = Binding($agendaViewModel.birthdays),
                    let allEventsTypes = Binding($agendaViewModel.eventsTypes)
                     {
                     Spacer().frame(height: 16)
                     EventsList(
                         events: allWeeklyEvents,
                         eventTypes: allEventsTypes,
                         birthdays: allWeeklyBirthdays
                     )
                 }
                
                if !lastNewsletterSectionIsEnabled()
                    && !toNotMissSectionIsEnabled() && lastWeeklyEventsSectionIsEnabled() {
                    NoContentPlaceHolder()
                }
            }
        }
        .onAppear {
            homePageViewModel.update()
            agendaViewModel.update()
            sendAnalyticsEvent(page: "home_page")
        }
        .refreshable {
            homePageViewModel.update()
            agendaViewModel.update()
            featureManager.update()
            userInfosViewModel.update()
        }
        .accessibility(identifier: "HomeView")
    }

    private func lastNewsletterSectionIsEnabled() -> Bool {
        // Check that the newsletters are a feature enabled
        return featureManager.isEnabled(item: .newsletters)
    }

    private func toNotMissSectionIsEnabled() -> Bool {
        // Check that the campaigns are a feature enabled
        return featureManager.isEnabled(item: .campaign)
    }

    private func lastWeeklyEventsSectionIsEnabled() -> Bool {
        // Check that the events are a feature enabled
        return featureManager.isEnabled(item: .agenda)
    }


}
