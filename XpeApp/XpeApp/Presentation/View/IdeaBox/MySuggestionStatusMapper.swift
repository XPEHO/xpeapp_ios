//
//  MySuggestionStatusMapper.swift
//  XpeApp
//
//  Created by Théo Lebègue on 19/03/2026.
//

import SwiftUI
import xpeho_ui

struct MySuggestionStatusMapper {
    static func label(for status: String) -> String {
        let normalizedStatus = status
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if normalizedStatus.contains("pending") {
            return "En attente"
        }
        if normalizedStatus.contains("approved") {
            return "Approuvée"
        }
        if normalizedStatus.contains("implemented") {
            return "Implémentée"
        }
        if normalizedStatus.contains("rejected") {
            return "Rejetée"
        }

        return status
    }

    static func color(for status: String) -> Color {
        let normalizedStatus = status
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()

        if normalizedStatus.contains("rejected") {
            return XPEHO_THEME.RED_INFO_COLOR
        }
        if normalizedStatus.contains("implemented") {
            return XPEHO_THEME.XPEHO_COLOR
        }

        return XPEHO_THEME.GREEN_DARK_COLOR
    }
}
