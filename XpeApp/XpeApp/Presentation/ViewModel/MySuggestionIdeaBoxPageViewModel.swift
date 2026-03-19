//
//  MySuggestionIdeaBoxPageViewModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 19/03/2026.
//

import Foundation

@Observable class MySuggestionIdeaBoxPageViewModel {
    static let instance = MySuggestionIdeaBoxPageViewModel()

    private init() {
        // This initializer is intentionally left empty to make private
        // to prevent use without shared instance
    }

    var ideas: [IdeaStatusModel]? = nil

    func update() {
        Task {
            let fetchedIdeas = await WordpressAPI.instance.fetchMyIdeas() ?? []
            let sortedIdeas = fetchedIdeas.sorted {
                ($0.submittedAtDate ?? .distantPast) > ($1.submittedAtDate ?? .distantPast)
            }

            DispatchQueue.main.async {
                self.ideas = sortedIdeas
            }
        }
    }
}
