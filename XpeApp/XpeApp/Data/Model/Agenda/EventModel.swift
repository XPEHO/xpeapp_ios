//
//  EventModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 24/03/2025.
//

import Foundation
import SwiftUI

public struct EventModel: Codable {
    var id: String
    let date: Date
    let startTime: String?
    let endTime: String?
    let title: String
    let location: String?
    let typeId: String
    let topic: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case date
        case startTime = "start_time"
        case endTime = "end_time"
        case title
        case location
        case typeId = "type_id"
        case topic
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        
       // Decode `date` as a String and convert it to a Date
        let dateString = try container.decode(String.self, forKey: .date)
        guard let parsedDate = fullDateTimeFormatter.date(from: dateString) else {
            throw DecodingError.dataCorruptedError(forKey: .date, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
        date = parsedDate

        startTime = try container.decodeIfPresent(String.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(String.self, forKey: .endTime)
        title = try container.decode(String.self, forKey: .title)
        location = try container.decodeIfPresent(String.self, forKey: .location)
        typeId = try container.decode(String.self, forKey: .typeId)
        topic = try container.decodeIfPresent(String.self, forKey: .topic)
    }
    
    init(id: String,
         date: Date,
         startTime: String?,
         endTime: String?,
         title: String,
         location: String?,
         typeId: String,
         topic: String?
    ) {
        self.id = id
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.title = title
        self.location = location
        self.typeId = typeId
        self.topic = topic
    }
    
    func toEntity() -> EventEntity {
        EventEntity(
            id: id,
            date: date,
            startTime: startTime,
            endTime: endTime,
            title: title,
            location: location,
            typeId: typeId,
            topic: topic
        )
    }
}
