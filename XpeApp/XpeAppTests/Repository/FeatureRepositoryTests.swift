//
//  FeatureRepositoryTests.swift
//  XpeAppTests
//
//  Created by Ryan Debouvries on 03/09/2024.
//

import XCTest
@testable import XpeApp

final class FeatureRepositoryTests: XCTestCase {
    // We take the mocked repository
    let featureRepo = FeatureRepositoryImpl.mock
    let featureSource = MockFirebaseAPI.instance

    override func setUp() {
        super.setUp()
        // Reset mock data before each test
        featureSource.fetchAllFeaturesReturnData = nil
    }

    override func tearDownWithError() throws {
        // Reset mock data after each test
        featureSource.fetchAllFeaturesReturnData = nil
        super.tearDown()
    }

    func test_getFeatures_fetchAllFeaturesError() async throws {
        // GIVEN
        featureSource.fetchAllFeaturesReturnData = nil
        
        // WHEN
        let features = await featureRepo.getFeatures()
        
        // THEN
        XCTAssertNil(features)
    }
    
    func test_getFeatures_Success() async throws {
        // GIVEN
        featureSource.fetchAllFeaturesReturnData = [
            FeatureModel(
                id: "id",
                description: "description",
                name: "Feature",
                prodEnabled: true,
                uatEnabled: true
            )
        ]
        
        // WHEN
        let features = await featureRepo.getFeatures()
        
        // THEN
        let dataExpected = [
            "id": FeatureEntity(
                name: "Feature",
                enabled: true
            )
        ]
        
        XCTAssertNotNil(features)
        XCTAssertEqual(features!.count, 1)
        XCTAssertEqual(features, dataExpected)
    }
}
