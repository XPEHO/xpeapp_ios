//
//  EventEntity.swift
//  XpeApp
//
//  Created by Théo Lebègue on 24/03/2025.
//

import Foundation

struct EventEntity: Codable, Equatable {
    let id: String
    let date: Date
    let endDate: Date?
    let startTime: String?
    let endTime: String?
    let title: String
    let location: String?
    let typeId: String
    let topic: String?

    init(id: String, date: Date, endDate: Date? = nil, startTime: String?, endTime: String?, title: String, location: String?, typeId: String, topic: String?) {
        self.id = id
        self.date = date
        self.endDate = endDate
        self.startTime = startTime
        self.endTime = endTime
        self.title = title
        self.location = location
        self.typeId = typeId
        self.topic = topic
    }
    
    static func == (lhs: EventEntity, rhs: EventEntity) -> Bool {
        return lhs.id == rhs.id
    }

}
