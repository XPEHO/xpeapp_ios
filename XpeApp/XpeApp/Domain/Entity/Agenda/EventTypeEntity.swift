//
//  EventTypeEntity.swift
//  XpeApp
//
//  Created by Théo Lebègue on 25/03/2025.
//

import Foundation

struct EventTypeEntity: Codable, Equatable {
    let id: String?
    let label: String
    let colorCode: String

    init(id: String, label: String, colorCode: String) {
        self.id = id
        self.label = label
        self.colorCode = colorCode
    }
    
    static func == (lhs: EventTypeEntity, rhs: EventTypeEntity) -> Bool {
        return lhs.id == rhs.id
    }

}
