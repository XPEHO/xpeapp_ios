//
//  BirthdayEntity.swift
//  XpeApp
//
//  Created by Théo Lebègue on 25/03/2025.
//

import Foundation

struct BirthdayEntity: Codable, Equatable {
    let id: String
    let firstName: String
    let birthdate: Date
    let email: String?

    init(id: String, firstName: String, birthdate: Date,  email: String?) {
        self.id = id
        self.firstName = firstName
        self.birthdate = birthdate
        self.email = email
    }
    
    static func == (lhs: BirthdayEntity, rhs: BirthdayEntity) -> Bool {
        return lhs.id == rhs.id
    }

}
