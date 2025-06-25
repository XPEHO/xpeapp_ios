//
//  AgencyPageView.swift
//  XpeApp
//
//  Created by Théo Lebègue on 24/06/2025.
//

import SwiftUI
import xpeho_ui

struct AgencyPage: View {
    var toastManager = ToastManager.instance
    @State private var showDigicode = false
    @State private var showAlarmcode = false
    
    // Config reader
    private let config = ConfigReader.shared
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Title(text: "Informations importantes :")
            
                CollapsableCard(
                    label: "Consignes du soir",
                    tags: [
                        TagPill(label: "BAISSER LES STORES", backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                        TagPill(label: "FERMER LES PORTES À CLEF", backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                        TagPill(label: "FERMER L'IMPRIMANTE", backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR)
                    ],
                    icon: AnyView(
                        Image("Building")
                            .renderingMode(.template)
                            .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                    ),
                    collapsable: false
                )
                
                CollapsableCard(
                    label: "Wifi",
                    tags: [
                        TagPill(label: config.getString(forKey: "WIFI_SSID"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR)
                    ],
                    button: ClickyButton(
                        label: "COPIER MDP",
                        horizontalPadding: 50,
                        verticalPadding: 12,
                        onPress: {
                            UIPasteboard.general.string = config.getString(forKey: "WIFI_PASSWORD")
                            toastManager.setParams(
                                message: "Wifi copié"
                            )
                            toastManager.play()
                        }
                    ),
                    icon: AnyView(
                        Image("Wifi")
                            .renderingMode(.template)
                            .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                            .scaledToFit()
                    ),
                    
                    collapsable: true,
                    defaultOpen: false
                )
                CollapsableCard(
                    label: "Wifi invité",
                    tags: [
                        TagPill(label: config.getString(forKey: "WIFI_GUEST_SSID"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR)
                    ],
                    button: ClickyButton(
                        label: "COPIER MDP",
                        horizontalPadding: 50,
                        verticalPadding: 12,
                        onPress: {
                            UIPasteboard.general.string = config.getString(forKey: "WIFI_GUEST_PASSWORD")
                            toastManager.setParams(
                                message: "Wifi invité copié"
                            )
                            toastManager.play()
                        }
                    ),
                    icon: AnyView(
                        Image("Wifi")
                            .renderingMode(.template)
                            .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                            .scaledToFit()
                    ),
                    collapsable: true,
                    defaultOpen: false
                )
                CollapsableCard(
                    label: "Imprimante de l'agence",
                    tags: [
                        TagPill(label: config.getString(forKey: "PRINTER_NAME"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR)
                    ],
                    icon: AnyView(
                        Image("Print")
                            .renderingMode(.template)
                            .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                            .scaledToFit()
                    ),
                    collapsable: true,
                    defaultOpen: false
                )
                CollapsableCard(
                    label: "Alarme bâtiment",
                    tags: [
                        TagPill(label: showAlarmcode ? config.getString(forKey: "ALARM_CODE") : "*******", backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR)
                    ],
                    button: ClickyButton(
                        label: showAlarmcode ? "MASQUER" : "AFFICHER",
                        onPress: {
                            showAlarmcode.toggle()
                        }
                    ),
                    icon: AnyView(
                        Image("Alarm")
                            .renderingMode(.template)
                            .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                            .scaledToFit()
                    ),
                    collapsable: true,
                    defaultOpen: false
                )
                CollapsableCard(
                    label: "Digicode portail Synergie",
                    tags: [
                        TagPill(label: showDigicode ? config.getString(forKey: "DIGICODE") : "*******", backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR)
                    ],
                    button: ClickyButton(
                        label: showDigicode ? "MASQUER" : "AFFICHER",
                        onPress: {
                            showDigicode.toggle()
                        }
                    ),
                    icon: AnyView(
                        Image("Barrier")
                            .renderingMode(.template)
                            .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                            .scaledToFit()
                    ),
                    collapsable: true,
                    defaultOpen: false
                )
                CollapsableCard(
                    label: "Société fontaine à eau",
                    tags: [
                        TagPill(label: config.getString(forKey: "WATER_FOUNTAIN_COMPANY"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                        TagPill(label: config.getString(forKey: "WATER_FOUNTAIN_CONTACT"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                    ],
                    icon: AnyView(
                        Image("Water-fountain")
                            .renderingMode(.template)
                            .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                            .scaledToFit()
                    ),
                    collapsable: true,
                    defaultOpen: false
                )
                CollapsableCard(
                    label: "Ménage (un vendredi sur deux)",
                    tags: [
                        TagPill(label: config.getString(forKey: "CLEANING_COMPANY"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                        TagPill(label: config.getString(forKey: "CLEANING_CONTACT"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                        TagPill(label: config.getString(forKey: "CLEANING_MANAGER"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                        TagPill(label: config.getString(forKey: "CLEANING_MANAGER_CONTACT"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR)
                    ],
                    icon: AnyView(
                        Image("Cleaning")
                            .renderingMode(.template)
                            .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                            .scaledToFit()
                    ),
                    collapsable: true,
                    defaultOpen: false
                )
                CollapsableCard(
                    label: "Propriétaires",
                    tags: [
                        TagPill(label: config.getString(forKey: "OWNER1_NAME"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                        TagPill(label: config.getString(forKey: "OWNER1_CONTACT"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                        TagPill(label: config.getString(forKey: "OWNER2_NAME"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR),
                        TagPill(label: config.getString(forKey: "OWNER2_CONTACT"), backgroundColor: XPEHO_THEME.GREEN_DARK_COLOR)
                    ],
                    icon: AnyView(
                        Image("Owner")
                            .renderingMode(.template)
                            .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
                            .scaledToFit()
                    ),
                    collapsable: true,
                    defaultOpen: false
                )
            }
        }
        .onAppear {
            sendAnalyticsEvent(page: "agency_page")
        }
        .accessibility(identifier: "AgencyView")
    }
}
