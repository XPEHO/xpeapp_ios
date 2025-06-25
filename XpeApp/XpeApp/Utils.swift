//
//  Utils.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 23/08/2024.
//

import Foundation
import SwiftUI
import FirebaseAnalytics

// ConfigReader class for reading values from XPEHOSecrets.plist confidential informations
class ConfigReader {
    static let shared = ConfigReader()
    
    private let configDict: [String: Any]?
    
    private init() {
        if let path = Bundle.main.path(forResource: "XPEHOSecrets", ofType: "plist"),
           let dict = NSDictionary(contentsOfFile: path) as? [String: Any] {
            self.configDict = dict
        } else {
            self.configDict = nil
            debugPrint("Failed to load XPEHOSecrets.plist")
        }
    }
    
    func string(forKey key: String) -> String? {
        return configDict?[key] as? String
    }
    
    func getString(forKey key: String) -> String {
        return string(forKey: key) ?? ""
    }
}

// Util function to count days between two dates
func countDaysBetween(_ from: Date, and to: Date) -> Int? {
    let calendar = Calendar.current
    let startOfDayFrom = calendar.startOfDay(for: from)
    let startOfDayTo = calendar.startOfDay(for: to)
    let components = calendar.dateComponents([.day], from: startOfDayFrom, to: startOfDayTo)
    return components.day
}


// Formatter for full date and time ("2025-03-26 00:00:00")
let fullDateTimeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr_FR")
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()
let dateFormatterForBirthday: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr_FR")
    formatter.dateFormat = "yyyy-MM-dd" // Format correspondant à "2025-03-25"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()

// Time Formatters for display the hours
let timeFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr_FR")
    formatter.dateFormat = "HH:mm"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()

// Date formatters for display in views
let dateDayAndMonthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr_FR")
    formatter.dateFormat = "dd/MM"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()

// Date formatters for display in views
let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr_FR")
    formatter.dateFormat = "dd/MM/yyyy"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()
let dateMonthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.locale = Locale(identifier: "fr_FR")
    formatter.dateFormat = "MMMM"
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    return formatter
}()

// Util function to valid the email format
func isValidEmail(_ email: String) -> Bool {
    let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

    let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
    return emailPred.evaluate(with: email)
}

func sendAnalyticsEvent(page: String) {
    Analytics.logEvent(
        AnalyticsEventViewItem,
        parameters: [
            AnalyticsParameterItemID: page,
        ]
    )
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
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
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
