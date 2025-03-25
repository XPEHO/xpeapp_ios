//
//  UtilsUI.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 03/12/2024.
//

import Foundation
import SwiftUI

// Util function to open a pdf
func openPdf(url: String, toastManager: ToastManager, openMethod: OpenURLAction) {
    if let url = URL(string: url), UIApplication.shared.canOpenURL(url) {
        openMethod(url)
    } else {
        toastManager.setParams(
            message: "Impossible d'ouvrir l'URL",
            error: true
        )
        toastManager.play()
    }
}

// A structure containing reusable date formatters
struct DateFormatters {
    // Generic function to create a `DateFormatter`
    private static func makeFormatter(with format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.timeZone = TimeZone(secondsFromGMT: 0) // Sets the timezone to UTC
        return formatter
    }
    
    // Formatter for dates and times in the format "yyyy-MM-dd HH:mm:ss"
    static let dateTimeFormatter = makeFormatter(with: "yyyy-MM-dd HH:mm:ss")
    
    // Formatter for dates in the format "yyyy-MM-dd"
    static let dateFormatter = makeFormatter(with: "yyyy-MM-dd")
    
    // Formatter for times in the format "HH:mm:ss"
    static let timeFormatter = makeFormatter(with: "HH:mm:ss")
}

// Extension of a color to create a color from a hexadecimal string and color blending
extension Color {
    // Initializes a color from a hexadecimal string (e.g., "#FF5733")
    init(hex: String) {
        let sanitizedHex = hex
            .trimmingCharacters(in: .whitespacesAndNewlines) // Remove leading/trailing whitespaces
            .replacingOccurrences(of: "#", with: "") // Delete the "#" character if present

        guard sanitizedHex.count == 6, let rgbValue = UInt64(sanitizedHex, radix: 16) else {
            self.init(red: 0, green: 0, blue: 0) // Black by default
            return
        }

        self.init(
            red: Double((rgbValue >> 16) & 0xFF) / 255.0,
            green: Double((rgbValue >> 8) & 0xFF) / 255.0,
            blue: Double(rgbValue & 0xFF) / 255.0
        )
    }

    // Blends two colors, taking into account the transparency of the overlay color
    func blended(with color: Color) -> Color {
        func getRGBA(from color: UIColor) -> (CGFloat, CGFloat, CGFloat, CGFloat) {
            var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 0
            color.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
            return (red, green, blue, alpha)
        }

        let (baseRed, baseGreen, baseBlue, _) = getRGBA(from: UIColor(self))
        let (overlayRed, overlayGreen, overlayBlue, overlayAlpha) = getRGBA(from: UIColor(color))

        let blendedRed = (1 - overlayAlpha) * baseRed + overlayAlpha * overlayRed
        let blendedGreen = (1 - overlayAlpha) * baseGreen + overlayAlpha * overlayGreen
        let blendedBlue = (1 - overlayAlpha) * baseBlue + overlayAlpha * overlayBlue

        return Color(red: blendedRed, green: blendedGreen, blue: blendedBlue)
    }
}
