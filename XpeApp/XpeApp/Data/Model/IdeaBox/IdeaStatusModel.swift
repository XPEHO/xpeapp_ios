//
//  IdeaStatusModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 19/03/2026.
//

import Foundation

struct IdeaStatusModel: Codable, Hashable {
    let id: String
    let status: String
    let reason: String?
    let context: String?
    let description: String?
    let submittedAt: String?

    private enum CodingKeys: String, CodingKey {
        case id
        case status
        case reason
        case context
        case title
        case description
        case idea = "idea"
        case createdAt = "created_at"
        case date
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        status = try container.decode(String.self, forKey: .status)
        reason = try container.decodeIfPresent(String.self, forKey: .reason)
        context = try Self.decodeFirstPresentString(from: container, keys: [.context, .title])
        description = try Self.decodeFirstPresentString(from: container, keys: [.description, .idea])
        submittedAt = try Self.decodeFirstPresentString(from: container, keys: [.createdAt, .date])
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(status, forKey: .status)
        try container.encodeIfPresent(reason, forKey: .reason)
        try container.encodeIfPresent(context, forKey: .context)
        try container.encodeIfPresent(description, forKey: .description)
        try container.encodeIfPresent(submittedAt, forKey: .createdAt)
    }

    init(
        id: String,
        status: String,
        reason: String? = nil,
        context: String? = nil,
        description: String? = nil,
        submittedAt: String? = nil
    ) {
        self.id = id
        self.status = status
        self.reason = reason
        self.context = context
        self.description = description
        self.submittedAt = submittedAt
    }

    var submittedAtDate: Date? {
        guard let submittedAt else {
            return nil
        }
        let trimmedDate = submittedAt.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedDate.isEmpty else {
            return nil
        }

        if let date = fullDateTimeFormatter.date(from: trimmedDate) {
            return date
        }

        return dateFormatterForBirthday.date(from: trimmedDate)
    }

    private static func decodeFirstPresentString(
        from container: KeyedDecodingContainer<CodingKeys>,
        keys: [CodingKeys]
    ) throws -> String? {
        for key in keys {
            if let value = try container.decodeIfPresent(String.self, forKey: key) {
                return value
            }
        }
        return nil
    }
}
