//
//  IdeaBoxPageViewModel.swift
//  XpeApp
//
//  Created by Théo Lebègue on 28/10/2025.
//

import Foundation

@Observable class IdeaBoxPageViewModel {
    
    static let instance = IdeaBoxPageViewModel()
    
    private init() {
        // This initializer is intentionally left empty to make private
        // to prevent use without shared instance
    }
    
    var context: String = ""
    var description: String = ""
    var isSending: Bool = false
    
    func resetForm() {
        context = ""
        description = ""
        isSending = false
    }
    
    func isFormValid() -> Bool {
        return !context.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
               !description.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func submitIdea() async -> Bool {
        guard isFormValid() && !isSending else {
            return false
        }
        
        isSending = true
        
        let idea = IdeaSubmissionModel(
            context: context.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines)
        )
        
        let result = await WordpressAPI.instance.submitIdea(idea: idea)
        
        DispatchQueue.main.async {
            self.isSending = false
        }
        
        return result ?? false
    }
}
