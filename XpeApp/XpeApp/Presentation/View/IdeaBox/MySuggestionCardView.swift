//
//  MySuggestionCardView.swift
//  XpeApp
//
//  Created by Théo Lebègue on 19/03/2026.
//

import SwiftUI
import xpeho_ui

struct MySuggestionCard: View {
    let idea: IdeaStatusModel
    let onSeeMore: () -> Void

    var body: some View {
        CollapsableCard(
            label: cardTitle,
            tags: [
                TagPill(
                    label: MySuggestionStatusMapper.label(for: idea.status).uppercased(),
                    backgroundColor: MySuggestionStatusMapper.color(for: idea.status)
                )
            ],
            button: ClickyButton(
                label: "VOIR PLUS",
                horizontalPadding: 50,
                verticalPadding: 12,
                onPress: onSeeMore
            ),
            icon: AnyView(
                Image("IdeaBulb")
                    .renderingMode(.template)
                    .foregroundStyle(XPEHO_THEME.XPEHO_COLOR)
            ),
            collapsable: true,
            defaultOpen: false
        )
    }

    private var cardTitle: String {
        let trimmedContext = idea.context?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        return trimmedContext.isEmpty ? "Suggestion" : trimmedContext
    }
}
