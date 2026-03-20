//
//  MySuggestionDetailsPopupView.swift
//  XpeApp
//
//  Created by Théo Lebègue on 19/03/2026.
//

import SwiftUI
import xpeho_ui

@Observable class MySuggestionDetailsModalManager {
    static let instance = MySuggestionDetailsModalManager()

    private init() {
    }

    var selectedIdea: IdeaStatusModel? = nil

    func present(idea: IdeaStatusModel) {
        selectedIdea = idea
    }

    func dismiss() {
        selectedIdea = nil
    }
}

struct MySuggestionDetailsPopup: View {
    let idea: IdeaStatusModel
    let onClose: () -> Void

    var body: some View {
        VStack(alignment: .leading) {
            Text(idea.context ?? "Suggestion")
                .font(.raleway(.bold, size: 20))
                .foregroundStyle(.black)
                .padding(.leading, 10)
                .padding(.bottom, 4)

            VStack(alignment: .leading, spacing: 10) {
                if let description = idea.description,
                   !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    Text("Idée soumise : \(description)")
                        .font(.raleway(.semiBold, size: 16))
                        .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)
                }

                if let submittedDate = idea.submittedAtDate {
                    Text("Date : \(dateFormatter.string(from: submittedDate))")
                        .font(.raleway(.semiBold, size: 16))
                        .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)
                }

                (Text("État de l'idée : ")
                    .font(.raleway(.semiBold, size: 16)) +
                 Text(MySuggestionStatusMapper.label(for: idea.status).lowercased())
                    .font(.raleway(.bold, size: 16)))
                    .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)

                if let reason = idea.reason,
                   !reason.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    (Text("Message : ").font(.raleway(.semiBold, size: 16))
                     + Text(reason)
                        .font(.raleway(.bold, size: 16)))
                        .foregroundStyle(XPEHO_THEME.CONTENT_COLOR)
                }
            }
            .padding(.horizontal, 8)
            .frame(maxWidth: .infinity, alignment: .leading)

            Spacer().frame(height: 20)

            ClickyButton(
                label: "OK",
                verticalPadding: 12,
                onPress: onClose
            )
            .frame(maxWidth: .infinity)
            .padding(.trailing, 16)
        }
        .padding()
        .frame(maxWidth: 360, alignment: .leading)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(radius: 10)
    }
}
