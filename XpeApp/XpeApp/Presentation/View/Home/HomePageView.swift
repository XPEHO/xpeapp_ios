//
//  HomePageView.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 12/08/2024.
//

import SwiftUI
import xpeho_ui

struct HomePage: View {
    @EnvironmentObject var analytics: AnalyticsModel
    @Bindable private var homePageViewModel = HomePageViewModel.instance
    @StateObject private var agendaViewModel = AgendaPageViewModel.instance
    private var featureManager = FeatureManager.instance
    private var userInfosViewModel = UserInfosPageViewModel.instance
    
    var body: some View {
        ScrollView {
            VStack {
                if lastNewsletterSectionIsEnabled() {
                    PageTitleSection(title: "Dernière publication")
                    Spacer().frame(height: 16)
                    LastNewsletterPreview(
                        lastNewsletter: homePageViewModel.lastNewsletter
                    )
                    Spacer().frame(height: 32)
                }
                if toNotMissSectionIsEnabled() {
                    PageTitleSection(title: "À ne pas manquer !")
                    if hasContent() {
                        if let activeCampaigns = Binding($homePageViewModel.activeCampaigns) {
                            CampaignsList(
                                campaigns: activeCampaigns,
                                collapsable: false,
                                defaultOpen: true
                            )
                            Spacer().frame(height: 16)
                        }
                        if let allWeeklyEvents = Binding($agendaViewModel.Weeklyevents),
                           let allWeeklyBirthdays = Binding($agendaViewModel.Weeklybirthdays),
                           let allEventsTypes = Binding($agendaViewModel.eventsTypes) {
                            EventsList(
                                events: allWeeklyEvents,
                                eventTypes: allEventsTypes,
                                birthdays: allWeeklyBirthdays
                            )
                        }
                    } else {
                        NoContentPlaceHolder()
                    }
                }
                
                if !lastNewsletterSectionIsEnabled()
                    && !toNotMissSectionIsEnabled() {
                    NoContentPlaceHolder()
                }
            }
        }
        .onAppear {
            homePageViewModel.update()
            agendaViewModel.update()
            analytics.trackEvent(
                AnalyticsEventName.openHome.rawValue,
                parameters: [
                    AnalyticsParamKey.itemId: "home_page",
                    AnalyticsParamKey.itemName: "Home",
                ]
            )
        }
        .refreshable {
            homePageViewModel.update()
            agendaViewModel.update()
            featureManager.update()
            userInfosViewModel.update()
        }
        .trackScreen("home_page")
        .accessibility(identifier: "HomeView")
    }

    private func lastNewsletterSectionIsEnabled() -> Bool {
        // Check that the newsletters are a feature enabled
        return featureManager.isEnabled(item: .newsletters)
    }

    private func toNotMissSectionIsEnabled() -> Bool {
        // Check that the campaigns and agenda are features enabled
        return featureManager.isEnabled(item: .campaign) && featureManager.isEnabled(item: .agenda)
    }

    private func hasContent() -> Bool {
        // Check if there is any content to display in the "À ne pas manquer !" section
        let hasActiveCampaigns = !(homePageViewModel.activeCampaigns?.isEmpty ?? true)
        let hasWeeklyEvents = !(agendaViewModel.Weeklyevents?.isEmpty ?? true)
        let hasWeeklyBirthdays = !(agendaViewModel.Weeklybirthdays?.isEmpty ?? true)
        return hasActiveCampaigns || hasWeeklyEvents || hasWeeklyBirthdays
    }
}
