//
//  UtilsTests.swift
//  XpeAppTests
//
//  Created by Ryan Debouvries on 20/09/2024.
//

import XCTest

import SwiftUI
@testable import XpeApp

final class UtilsTests: XCTestCase{

    override func setUp() {
        super.setUp()
    }

    override func tearDownWithError() throws {
        super.tearDown()
    }

    func test_countDaysBetween() throws {
        // GIVEN
        let currentDate = Date()
        let currentDatePlusOneDay = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        
        // WHEN
        let daysBetween = countDaysBetween(currentDate, and: currentDatePlusOneDay)
        
        // THEN
        XCTAssertEqual(daysBetween, 1)
    }
    
    func test_dateFormatter() throws {
        // GIVEN
        var dateComponents = DateComponents(year: 2000, month: 1, day: 1)
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        let date = Calendar.current.date(from: dateComponents)!
        
        // WHEN
        let dateFormatted = dateFormatter.string(from: date)
        
        // THEN
        let dateExpected = "01/01/2000"
        XCTAssertEqual(dateFormatted, dateExpected)
    }

    func test_dateMonthFormatter() throws {
        // GIVEN
        var dateComponents = DateComponents(year: 2000, month: 1, day: 1)
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        let date = Calendar.current.date(from: dateComponents)!
        
        // WHEN
        let monthFormatted = dateMonthFormatter.string(from: date)
        
        // THEN
        let monthExpected = "janvier"
        XCTAssertEqual(monthFormatted, monthExpected)
    }
    
    func test_isValidEmail() throws {
        // GIVEN
        let wrongEmail1 = "test"
        let wrongEmail2 = "test.fr"
        let wrongEmail3 = "test@test"
        let goodEmail = "test@test.fr"
        
        // WHEN
        let wrongEmail1Valid = isValidEmail(wrongEmail1)
        let wrongEmail2Valid = isValidEmail(wrongEmail2)
        let wrongEmail3Valid = isValidEmail(wrongEmail3)
        let goodEmailValid = isValidEmail(goodEmail)
        
        // THEN
        XCTAssertEqual(wrongEmail1Valid, false)
        XCTAssertEqual(wrongEmail2Valid, false)
        XCTAssertEqual(wrongEmail3Valid, false)
        XCTAssertEqual(goodEmailValid, true)
    }

    func test_fullDateTimeFormatter() throws {
        // GIVEN
        _ = fullDateTimeFormatter
        var dateComponents = DateComponents(year: 2025, month: 3, day: 26, hour: 0, minute: 0, second: 0)
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        let date = Calendar.current.date(from: dateComponents)!
        
        // WHEN
        let formattedDate = fullDateTimeFormatter.string(from: date)
        
        // THEN
        let expectedDate = "2025-03-26 00:00:00"
        XCTAssertEqual(formattedDate, expectedDate)
    }
    
    func test_dateFormatterForBirthday() throws {
        // GIVEN
        _ = dateFormatterForBirthday
        var dateComponents = DateComponents(year: 2025, month: 3, day: 25)
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        let date = Calendar.current.date(from: dateComponents)!
        
        // WHEN
        let formattedDate = dateFormatterForBirthday.string(from: date)
        
        // THEN
        let expectedDate = "2025-03-25"
        XCTAssertEqual(formattedDate, expectedDate)
    }
    
    func test_timeFormatter() throws {
        // GIVEN
        _ = timeFormatter
        var dateComponents = DateComponents(year: 2025, month: 3, day: 26, hour: 15, minute: 30)
        dateComponents.timeZone = TimeZone(secondsFromGMT: 0)
        let date = Calendar.current.date(from: dateComponents)!
        
        // WHEN
        let formattedTime = timeFormatter.string(from: date)
        
        // THEN
        let expectedTime = "15:30"
        XCTAssertEqual(formattedTime, expectedTime)
    }

    func test_colorInitWithHex() throws {
        // GIVEN
        let hexColor = "#FF5733"
        
        // WHEN
        let color = Color(hex: hexColor)
        
        // THEN
        // Expected RGB values for #FF5733
        let expectedRed = 1.0
        let expectedGreen = 87.0 / 255.0
        let expectedBlue = 51.0 / 255.0
        
        // Extract the color's components
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, expectedRed, accuracy: 0.01)
        XCTAssertEqual(green, expectedGreen, accuracy: 0.01)
        XCTAssertEqual(blue, expectedBlue, accuracy: 0.01)
        XCTAssertEqual(alpha, 1.0, accuracy: 0.01)
    }
    
    func test_colorBlended() throws {
        // GIVEN
        let baseColor = Color(red: 0.5, green: 0.5, blue: 0.5)
        let overlayColor = Color(red: 1.0, green: 0.0, blue: 0.0, opacity: 0.5)
        
        // WHEN
        let blendedColor = baseColor.blended(with: overlayColor)
        
        // THEN
        // Expected blended RGB values
        let expectedRed = 0.75
        let expectedGreen = 0.25
        let expectedBlue = 0.25
        
        // Extract the color's components
        let uiColor = UIColor(blendedColor)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        XCTAssertEqual(red, expectedRed, accuracy: 0.01)
        XCTAssertEqual(green, expectedGreen, accuracy: 0.01)
        XCTAssertEqual(blue, expectedBlue, accuracy: 0.01)
        XCTAssertEqual(alpha, 1.0, accuracy: 0.01)
    }

}
