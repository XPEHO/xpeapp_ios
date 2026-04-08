//
//  IdeaBoxPageView.swift
//  XpeApp
//
//  Created by Théo Lebègue on 28/10/2025.
//

import SwiftUI
import xpeho_ui

struct IdeaBoxPage: View {
    @State private var ideaBoxViewModel = IdeaBoxPageViewModel.instance
    private var toastManager = ToastManager.instance
    private var routerManager = RouterManager.instance
    @EnvironmentObject var analytics: AnalyticsModel
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                Title(text: "Partage ton idée :")
                Spacer(minLength: 60)
                
                Text("Contexte : ")
                    .font(.raleway(.semiBold, size: 16))
                    .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)
                    .frame(maxWidth: .infinity, alignment: .leading)
            
                InputText(
                    label: "Thématique (ex : Agence, en mission etc...)",
                    onInput: { input in
                        ideaBoxViewModel.context = input
                    }
                )
                
                Text("Description : ")
                    .font(.raleway(.semiBold, size: 16))
                    .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                InputText(
                    label: "Mon idée/Ma suggestion",
                    multiline: true,
                    onInput: { input in
                        ideaBoxViewModel.description = input
                    }
                )
                
                HStack {
                    Spacer()
                    if ideaBoxViewModel.isSending {
                        ProgressView("Envoi en cours...")
                            .progressViewStyle(CircularProgressViewStyle())
                            .padding(.vertical, 18)
                            .frame(minWidth: 70)
                    } else {
                        ClickyButton(
                            label: "SOUMETTRE",
                            size: 18,
                            horizontalPadding: 70,
                            verticalPadding: 18,
                            enabled: true,
                            onPress: {
                                Task {
                                    let success = await ideaBoxViewModel.submitIdea()
                                    DispatchQueue.main.async {
                                        if success {
                                            analytics.trackEvent(AnalyticsEventName.ideaSubmitted.rawValue, parameters: [AnalyticsParamKey.context: ideaBoxViewModel.context])
                                            toastManager.setParams(
                                                message: "Idée soumise avec succès !",
                                                action: {
                                                    ideaBoxViewModel.resetForm()
                                                    routerManager.goTo(item: .home)
                                                }
                                            )
                                            toastManager.play()
                                        } else {
                                            toastManager.setParams(
                                                message: "Impossible d'envoyer votre idée",
                                                error: true
                                            )
                                            toastManager.play()
                                        }
                                    }
                                }
                            }
                        )
                    }
                    Spacer()
                }
                .padding(.top, 32)
                
            }
        }
        .trackScreen("idea_box_page")
        .accessibility(identifier: "IdeaBoxView")
    }
}
