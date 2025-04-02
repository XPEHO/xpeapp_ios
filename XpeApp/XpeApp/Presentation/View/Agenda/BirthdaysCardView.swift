//
//  BirthdaysCardView.swift
//  XpeApp
//
//  Created by Théo Lebègue on 25/03/2025.
//

import SwiftUI
import xpeho_ui

struct BirthdayCard: View {
    @Binding var birthday: BirthdayEntity
    
    var collapsable: Bool = false

    var body: some View {
        let baseColor = Color(hex: "FF7EEA") // Default birthday color
        let overlayColor = Color(hex: "7C4000").opacity(0.2) // Marron at 20% opacity
        let tagColor = baseColor.blended(with: overlayColor)

        CollapsableCard(
            label: "Anniversaire de \(birthday.firstName)",
            tags: [
                TagPill(label: dateDayAndMonthFormatter.string(from: birthday.birthdate), backgroundColor: tagColor)
            ],
            icon: AnyView(
                Assets.loadImage(named: "Birthday")
                    .renderingMode(.template)
                    .foregroundStyle(baseColor)
            ),
            collapsable: collapsable
        )
    }
}
