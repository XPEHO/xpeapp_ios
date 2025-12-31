//
//  MockWordpressAPI.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 18/09/2024.
//

import Foundation

class MockWordpressAPI: WordpressAPIProtocol {
    static let instance = MockWordpressAPI()
    
    // Mocked Returns
    var fetchUserIdReturnData: String?
    var postLastConnection: Bool?
    var generateTokenReturnData: TokenResponseModel?
    var checkTokenValidityReturnData: TokenValidityModel?
    var fetchAllCampaignsReturnData: [QvstCampaignModel]?
    var fetchActiveCampaignsReturnData: [QvstCampaignModel]?
    var fetchCampaignQuestionsReturnData: [QvstQuestionModel]?
    var sendCampaignAnswersReturnData: Bool?
    var fetchCampaignsProgressReturnData: [QvstProgressModel]?
    var fetchUserInfosReturnData: UserInfosModel?
    var updatePasswordData: UserPasswordEditReturnEnum?
    var fetchAllEventsReturnData: [EventModel]?
    var fetchAllEventsTypesReturnData: [EventTypeModel]?
    var fetchAllBirthdayReturnData: [BirthdayModel]?
    var submitIdeaReturnData: Bool?
    
    // Mocked Methods
    func fetchUserId(email: String) async -> String? {
        return fetchUserIdReturnData
    }
    
    func generateToken(userCandidate: UserCandidateModel) async -> TokenResponseModel? {
        return generateTokenReturnData
    }
    
    func checkTokenValidity(token: String) async -> TokenValidityModel? {
        return checkTokenValidityReturnData
    }
    
    func fetchAllCampaigns() async -> [QvstCampaignModel]? {
        return fetchAllCampaignsReturnData
    }
    
    func fetchActiveCampaigns() async -> [QvstCampaignModel]? {
        return fetchActiveCampaignsReturnData
    }
    
    func fetchCampaignQuestions(campaignId: String) async -> [QvstQuestionModel]? {
        return fetchCampaignQuestionsReturnData
    }
    
    func sendCampaignAnswers(
        campaignId: String,
        userId: String,
        questions: [QvstQuestionModel],
        answers: [QvstAnswerModel]
    ) async -> Bool? {
        return sendCampaignAnswersReturnData
    }
    
    func fetchCampaignsProgress(userId: String) async -> [QvstProgressModel]? {
        return fetchCampaignsProgressReturnData
    }
    
    func fetchUserInfos() async -> UserInfosModel? {
        return fetchUserInfosReturnData
    }
    
    func postLastConnection() async -> Bool? {
        return postLastConnection
    }
    
    func updatePassword(userPasswordCandidate: UserPasswordEditModel) async -> UserPasswordEditReturnEnum? {
        return updatePasswordData
    }
    
    func fetchAllEvents(page: String?) async -> [EventModel]? {
        return fetchAllEventsReturnData
    }
    
    func fetchAllEventsTypes() async -> [EventTypeModel]? {
        return fetchAllEventsTypesReturnData
    }
    
    func fetchAllBirthdays(page: String?) async -> [BirthdayModel]? {
        return fetchAllBirthdayReturnData
    }
    
    func submitIdea(idea: IdeaSubmissionModel) async -> Bool? {
        return submitIdeaReturnData
    }
}
