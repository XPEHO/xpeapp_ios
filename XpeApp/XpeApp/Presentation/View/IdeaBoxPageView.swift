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
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Title(text: "Partage ton idée")
                .padding(.bottom, 10)
            
            Text("Contexte")
                .font(.raleway(.medium, size: 16))
                .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)
                .multilineTextAlignment(.leading)
            
                InputText(
                    label: "Thématique",
                    onInput: { input in
                        ideaBoxViewModel.context = input
                    }
                )
            
                Text("Description")
                    .font(.raleway(.medium, size: 16))
                    .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)
                    .multilineTextAlignment(.leading)
                
                InputText(
                    label: "Mon idée/Ma suggestion",
                    multiline: true,
                    onInput: { input in
                        ideaBoxViewModel.description = input
                    }
                )
            
            Spacer()
            
            ClickyButton(
                label: ideaBoxViewModel.isSending ? "Envoi en cours..." : "Soumettre",
                verticalPadding: 12,
                onPress: {
                    Task {
                        let success = await ideaBoxViewModel.submitIdea()
                        
                        DispatchQueue.main.async {
                            if success {
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
            .disabled(!ideaBoxViewModel.isFormValid() || ideaBoxViewModel.isSending)
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
        .onAppear {
            sendAnalyticsEvent(page: "idea_box_page")
        }
        .accessibility(identifier: "IdeaBoxView")
    }
}

#Preview {
    IdeaBoxPage()
}
