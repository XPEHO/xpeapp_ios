//
//  EventTypeModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 25/03/2025.
//

import Foundation

public struct EventTypeModel: Codable {
    var id: String?
    let label: String
    let colorCode: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case label
        case colorCode = "color_code"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decodeIfPresent(String.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        colorCode = try container.decode(String.self, forKey: .colorCode)
    }

    func toEntity() -> EventTypeEntity {
        EventTypeEntity(
            id: id ?? "",
            label: label,
            colorCode: colorCode
        )
    }
}
