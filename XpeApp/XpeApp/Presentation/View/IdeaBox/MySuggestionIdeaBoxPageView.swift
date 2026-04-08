//
//  MySuggestionIdeaBoxPageView.swift
//  XpeApp
//
//  Created by Théo Lebègue on 19/03/2026.
//

import SwiftUI

struct MySuggestionIdeaBoxPage: View {
	private var featureManager = FeatureManager.instance
	private var routerManager = RouterManager.instance
	private var detailsModalManager = MySuggestionDetailsModalManager.instance
	@State private var viewModel = MySuggestionIdeaBoxPageViewModel.instance
	@State private var hasAutoOpenedFromRoute: Bool = false

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 16) {
				Title(text: "Mes suggestions :")

				if let ideas = viewModel.ideas {
					if ideas.isEmpty {
						NoContentPlaceHolder()
					} else {
						ForEach(ideas, id: \.id) { idea in
							MySuggestionCard(
								idea: idea,
								onSeeMore: {
									detailsModalManager.present(idea: idea)
								}
							)
						}
					}
				} else {
					ProgressView("Chargement des suggestions...")
						.progressViewStyle(CircularProgressViewStyle())
						.padding()
				}
			}
		}
		.onAppear {
			tryAutoOpenIdeaFromRoute()
			viewModel.update()
		}
		.onChange(of: viewModel.ideas) { _, _ in
			tryAutoOpenIdeaFromRoute()
		}
		.refreshable {
			viewModel.update()
			featureManager.update()
		}
		.trackScreen("idea_box_my_suggestions_page")
		.accessibility(identifier: "MySuggestionIdeaBoxView")
	}

	private func tryAutoOpenIdeaFromRoute() {
		guard !hasAutoOpenedFromRoute else {
			return
		}

		guard let routeIdeaId = routerManager.parameters[RouterParameterKey.ideaId] as? String,
			  !routeIdeaId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
			  let ideas = viewModel.ideas,
			  let targetIdea = ideas.first(where: { $0.id == routeIdeaId }) else {
			return
		}

		detailsModalManager.present(idea: targetIdea)
		hasAutoOpenedFromRoute = true
	}
}

