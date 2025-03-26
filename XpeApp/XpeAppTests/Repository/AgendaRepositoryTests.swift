//
//  AgendaRepositoryTests.swift
//  XpeApp
//
//  Created by Théo Lebègue on 26/03/2025.
//

import XCTest
@testable import XpeApp

final class AgendaRepositoryTests: XCTestCase {
    // We take the mocked repository
    let agendaRepo = AgendaRepositoryImpl.mock
    let agendaSource = MockWordpressAPI.instance
    
    override func setUp() {
        super.setUp()
    }
    
    override func tearDownWithError() throws {
        super.tearDown()
    }
    
    
        func test_getAllEvents_fetchError() throws {
        Task {
            // GIVEN
            agendaSource.fetchAllEventsReturnData = nil
            
            // WHEN
            let events = await agendaRepo.getAllEvents(page: nil)
            
            // THEN
            XCTAssertNil(events)
        }
    }
    
    func test_getAllEvents_Success() throws {
        Task {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            // GIVEN
            agendaSource.fetchAllEventsReturnData = [
                EventModel(
                    id: "1",
                    date: dateFormatter.date(from: "2025-03-26 00:00:00")!,
                    startTime: dateFormatter.date(from: "2025-03-26 12:00:00"),
                    endTime: dateFormatter.date(from: "2025-03-26 13:00:00"),
                    title: "test",
                    location: "test",
                    typeId: "test",
                    topic: "test"
                )
            ]
            
            // WHEN
            let events = await agendaRepo.getAllEvents(page: nil)
            
            // THEN
            XCTAssertNotNil(events)
            XCTAssertEqual(events?.count, 1)
            
            let event = events?.first
            XCTAssertEqual(event?.id, "1")
            XCTAssertEqual(event?.title, "test")
            XCTAssertEqual(event?.location, "test")
            XCTAssertEqual(event?.typeId, "test")
            XCTAssertEqual(event?.topic, "test")
            XCTAssertEqual(event?.date, dateFormatter.date(from: "2025-03-26 00:00:00"))
            XCTAssertEqual(event?.startTime, dateFormatter.date(from: "2025-03-26 12:00:00"))
            XCTAssertEqual(event?.endTime, dateFormatter.date(from: "2025-03-26 13:00:00"))
        }
    }
    
    func test_getAllEventsTypes_fetchError() throws {
        Task {
            // GIVEN
            agendaSource.fetchAllEventsTypesReturnData = nil
            
            // WHEN
            let eventTypes = await agendaRepo.getAllEventsTypes()
            
            // THEN
            XCTAssertNil(eventTypes)
        }
    }
    
    func test_getAllEventsTypes_Success() throws {
        Task {
            // GIVEN
            agendaSource.fetchAllEventsTypesReturnData = [
                EventTypeModel(id: "1", label: "label1", colorCode: "#FFFFF"),
                EventTypeModel(id: "2", label: "label2", colorCode: "#FFFFF")
            ]
            
            // WHEN
            let eventTypes = await agendaRepo.getAllEventsTypes()
            
            // THEN
            XCTAssertNotNil(eventTypes)
            XCTAssertEqual(eventTypes?.count, 2)
            
            let firstType = eventTypes?.first
            XCTAssertEqual(firstType?.id, "1")
            XCTAssertEqual(firstType?.label, "Type 1")
            XCTAssertEqual(firstType?.colorCode, "#FFFFF")
        }
    }
    
    func test_getAllBirthdays_fetchError() throws {
        Task {
            // GIVEN
            agendaSource.fetchAllBirthdayReturnData = nil

            // WHEN
            let birthdays = await agendaRepo.getAllBirthdays(page: "")
            
            // THEN
            XCTAssertNil(birthdays)
        }
    }
    
        func test_getAllBirthdays_Success() throws {
        Task {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            
            // Safely unwrap the dates
            guard let birthdate1 = dateFormatter.date(from: "2000-01-01"),
                  let birthdate2 = dateFormatter.date(from: "1995-05-15") else {
                XCTFail("Failed to parse birthdates")
                return
            }
            
            // GIVEN
            agendaSource.fetchAllBirthdayReturnData = [
                BirthdayModel(id: "1", firstName: "John Doe", birthdate: birthdate1, email: "johndoe@example.com"),
                BirthdayModel(id: "2", firstName: "Jane Doe", birthdate: birthdate2, email: "janedoe@example.com")
            ] as [BirthdayModel]
            
            // WHEN
            let birthdays: [BirthdayEntity]? = await agendaRepo.getAllBirthdays(page: nil)
            
            // THEN
            XCTAssertNotNil(birthdays)
            XCTAssertEqual(birthdays?.count, 2)
            
            let firstBirthday = birthdays?.first
            XCTAssertEqual(firstBirthday?.id, "1")
            XCTAssertEqual(firstBirthday?.firstName, "John Doe")
            XCTAssertEqual(firstBirthday?.birthdate, birthdate1)
        }
    }
}
