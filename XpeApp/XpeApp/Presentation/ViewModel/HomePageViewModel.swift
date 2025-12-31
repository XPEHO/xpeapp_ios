//
//  HomePageViewModel.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 12/09/2024.
//

import Foundation
import SwiftUI

@Observable class HomePageViewModel {
    
    static let instance = HomePageViewModel()
    
    // Make private constructor to prevent use without shared instance
    private init() {
        initLastNewsletter()
        initActiveCampaigns()
    }

    var lastNewsletter: NewsletterEntity? = nil
    var activeCampaigns: [QvstCampaignEntity]? = nil
    var lastNewsletterPreview: UIImage? = nil
    var lastConnectionSuccess: Bool = false
    
    func update() {
        initLastNewsletter()
        initActiveCampaigns()
        initLastConnection()
    }

    private func initLastConnection() {
        Task {
            let result = await UserRepositoryImpl.instance.fetchPostLastConnection()
            DispatchQueue.main.async {
                self.lastConnectionSuccess = result
            }
        }
    }
    
    private func initLastNewsletter() {
        Task{
            let obtainedLastNewsletter = await NewsletterRepositoryImpl.instance.getLastNewsletter()
            DispatchQueue.main.async {
                self.lastNewsletter = obtainedLastNewsletter
                self.initLastNewsletterPreview()
            }
        }
    }
    
    
    private func initLastNewsletterPreview() {
        Task {
            guard let previewPath = self.lastNewsletter?.previewPath, !previewPath.isEmpty else {
                debugPrint("No previewPath for last newsletter")
                return
            }
            if let imageData = await WordpressAPI.instance.fetchImage(previewPath: previewPath),
               let image = UIImage(data: imageData) {
                DispatchQueue.main.async {
                    self.lastNewsletterPreview = image
                }
            } else {
                debugPrint("Failed to load image for last newsletter with previewPath: \(self.lastNewsletter?.previewPath ?? "nil")")
            }
        }
    }
    
    private func initActiveCampaigns() {
        Task{
            let obtainedActiveCampaigns = await QvstRepositoryImpl.instance.getActiveCampaigns()
            DispatchQueue.main.async {
                self.activeCampaigns = obtainedActiveCampaigns
            }
        }
    }
}
