//
//  BirthdayModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 25/03/2025.
//

import Foundation

public struct BirthdayModel: Codable {
    let id: String
    let firstName: String
    let birthdate: Date
    let email: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case firstName = "first_name"
        case birthdate
        case email
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        firstName = try container.decode(String.self, forKey: .firstName)
        
        // Decode `birthdate` as a String and convert it to a Date
        let birthdateString = try container.decode(String.self, forKey: .birthdate)
        guard let parsedDate = dateFormatterForBirthday.date(from: birthdateString) else {
            throw DecodingError.dataCorruptedError(forKey: .birthdate, in: container, debugDescription: "Date string does not match format expected by formatter.")
        }
        birthdate = parsedDate
        
        email = try container.decodeIfPresent(String.self, forKey: .email)
    }

    init(id: String, firstName: String, birthdate: Date, email: String?) {
        self.id = id
        self.firstName = firstName
        self.birthdate = birthdate
        self.email = email
    }

    func toEntity() -> BirthdayEntity {
        BirthdayEntity(
            id: id,
            firstName: firstName,
            birthdate: birthdate,
            email: email
            
        )
    }
}
