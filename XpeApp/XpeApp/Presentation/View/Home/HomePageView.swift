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
    @Bindable private var homeInfoBannerManager = HomeInfoBannerManager.instance
    @StateObject private var agendaViewModel = AgendaPageViewModel.instance
    private var routerManager = RouterManager.instance
    private var featureManager = FeatureManager.instance
    private var userInfosViewModel = UserInfosPageViewModel.instance
    
    var body: some View {
        ScrollView {
            VStack {
                if let bannerMessage = homeInfoBannerManager.message {
                    HomeInfoBanner(
                        message: bannerMessage,
                        onTap: {
                            var parameters: [String: Any] = ["ideaBoxSubpage": "mySuggestions"]
                            if let targetIdeaId = homeInfoBannerManager.targetIdeaId,
                               !targetIdeaId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                parameters["ideaId"] = targetIdeaId
                            }
                            routerManager.goTo(item: .ideaBox, parameters: parameters)
                        }
                    )
                    Spacer().frame(height: 16)
                }

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
                        if let allWeeklyEvents = Binding($agendaViewModel.weeklyEvents),
                           let allWeeklyBirthdays = Binding($agendaViewModel.weeklyBirthdays),
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
            homeInfoBannerManager.refresh()
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
            homeInfoBannerManager.refresh()
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
        let hasWeeklyEvents = !(agendaViewModel.weeklyEvents?.isEmpty ?? true)
        let hasWeeklyBirthdays = !(agendaViewModel.weeklyBirthdays?.isEmpty ?? true)
        return hasActiveCampaigns || hasWeeklyEvents || hasWeeklyBirthdays
    }
}

private struct HomeInfoBanner: View {
    let message: String
    let onTap: () -> Void

    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image("MegaPhone")
                .renderingMode(.template)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                .frame(height: 30)
                .padding(.top, 2)

            Text(message)
                .font(.raleway(.regular, size: 18))
                .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)
                .multilineTextAlignment(.leading)

            Spacer(minLength: 0)
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(XPEHO_THEME.XPEHO_COLOR.opacity(0.30), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }
}
