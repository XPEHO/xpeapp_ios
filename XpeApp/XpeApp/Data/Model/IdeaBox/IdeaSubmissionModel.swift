//
//  IdeaSubmissionModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 29/10/2025.
//

import Foundation

struct IdeaSubmissionModel: Codable {
    let context: String
    let description: String
    
    init(context: String, description: String) {
        self.context = context
        self.description = description
    }
}
