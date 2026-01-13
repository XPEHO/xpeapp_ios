//
//  UserRepositoryImpl.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 06/09/2024.
//

import FirebaseAuth
import Foundation
import FirebaseCrashlytics

@Observable class UserRepositoryImpl: UserRepository {
    // An instance for app and a mock for tests
    static let instance = UserRepositoryImpl()
    static let mock = UserRepositoryImpl(
        dataSource: MockWordpressAPI.instance
    )
    
    // Data source to use
    private let dataSource: WordpressAPIProtocol
    // Analytics client
    private let analytics: AnalyticsModel
    
    // Watched user
    var user: UserEntity? = nil
    
    // Make private constructor to prevent use without shared instances
    private init(
        dataSource: WordpressAPIProtocol = WordpressAPI.instance,
        analytics: AnalyticsModel = AnalyticsModel.shared
    ) {
        self.dataSource = dataSource
        self.analytics = analytics
    }
    
    func login(
        username: String,
        password: String,
        completion: @escaping (LoginResult) -> Void
    ) async {
        CrashlyticsUtils.setCurrentFeature("auth")
        CrashlyticsUtils.logEvent("Auth attempt (username provided)")
        // Generate token
        guard
            let tokenResponse = await dataSource.generateToken(
                userCandidate: UserCandidateModel(
                    username: username,
                    password: password
                )
            )
        else {
            CrashlyticsUtils.logEvent("Auth error: generateToken returned nil")
            CrashlyticsUtils.setCustomKey("last_auth_error", value: "generateToken_nil")
            CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Failed call to generateToken in login")
            completion(.error)
            return
        }
        
        // Check that we succeed to generate the token
        if let successTokenResponse = tokenResponse.success {
            guard
                let userId = await dataSource.fetchUserId(
                    email: successTokenResponse.userEmail)
            else {
                CrashlyticsUtils.logEvent("Auth error: fetchUserId failed")
                CrashlyticsUtils.setCustomKey("last_auth_error", value: "fetchUserId_failed")
                CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
                debugPrint("Failed call to fetchUserId in login")
                completion(.error)
                return
            }
            // Try to connect to firebase
            do {
                let authResult = try await Auth.auth().signInAnonymously()
                // Handle successful sign-in if needed
                debugPrint(
                    "Successfully signed in anonymously: \(authResult.user.uid)"
                )
                // Inform analytics about this user identifier
                analytics.setUserId(authResult.user.uid)
                CrashlyticsUtils.logEvent("Auth success (anonymous)")
                
                // Register the user
                let newUser = UserEntity(
                    token: "Bearer " + successTokenResponse.token,
                    id: userId
                )
                self.user = newUser
                
                // Save it in cache
                KeychainManager.instance.saveValue(newUser.id, forKey: "user_id")
                KeychainManager.instance.saveValue(newUser.token, forKey: "user_token")
                
                // Save token issued at date in cache (format: yyyy-MM-dd HH:mm:ss)
                let issuedAtString = fullDateTimeFormatter.string(from: Date())
                KeychainManager.instance.saveValue(issuedAtString, forKey: "user_token_issued_at")
                
                // Save last used username for prefill on next login
                KeychainManager.instance.saveValue(username, forKey: "last_username")
                
                CrashlyticsUtils.setUserId(successTokenResponse.userEmail)
                CrashlyticsUtils.setCustomKey("user_email", value: successTokenResponse.userEmail)
                CrashlyticsUtils.setUserContext(isLoggedIn: true)
                
                completion(.success)
            } catch {
                CrashlyticsUtils.recordException(error)
                CrashlyticsUtils.logEvent("Auth error: Firebase anonymous sign-in failed")
                CrashlyticsUtils.setCustomKey("last_auth_error", value: error.localizedDescription)
                CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
                debugPrint(
                    "Error connecting to Firebase anonymously to Firebase: \(error.localizedDescription)"
                )
                completion(.error)
            }
        } else if tokenResponse.error != nil {
            CrashlyticsUtils.logEvent("Auth failure: invalid credentials or server response")
            CrashlyticsUtils.setCustomKey("last_auth_error", value: "token_response_error")
            CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            completion(.failure)
        } else {
            CrashlyticsUtils.logEvent("Auth error: unhandled tokenResponse")
            CrashlyticsUtils.setCustomKey("last_auth_error", value: "unhandled_token_response")
            CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint("Unhandled tokenResponse in login")
            completion(.error)
        }
    }
    
    func loginWithCacheIfTokenValid(
        completion: @escaping (LoginResult) -> Void
    ) async {
        CrashlyticsUtils.setCurrentFeature("auth")
        CrashlyticsUtils.logEvent("Auth attempt (cache)")
        // Check local token expiration based on issued_at stored in Keychain
        if let issuedAtString = KeychainManager.instance.getValue(forKey: "user_token_issued_at"),
           let issuedAt = fullDateTimeFormatter.date(from: issuedAtString) {
            let now = Date()
            let totalLifetimeSeconds: TimeInterval = tokenLifetimeSeconds
            let ageSeconds = now.timeIntervalSince(issuedAt)
            if ageSeconds >= totalLifetimeSeconds {
                // Token expired locally -> perform the same logout as profile page
                self.logout()
                CrashlyticsUtils.logEvent("Auth cache invalid: token expired")
                CrashlyticsUtils.setCustomKey("last_auth_error", value: "cache_token_expired")
                CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
                completion(.failure)
                return
            }
        } else {
            // No issued_at in cache -> consider invalid and logout
            CrashlyticsUtils.logEvent("Auth cache invalid: missing issued_at")
            CrashlyticsUtils.setCustomKey("last_auth_error", value: "cache_missing_issued_at")
            CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            self.logout()
            completion(.failure)
            return
        }
        
        // Get the user from cache
        guard let id = KeychainManager.instance.getValue(forKey: "user_id")
        else {
            CrashlyticsUtils.logEvent("Auth cache invalid: missing user_id")
            completion(.failure)
            return
        }
        guard
            let token = KeychainManager.instance.getValue(forKey: "user_token")
        else {
            CrashlyticsUtils.logEvent("Auth cache invalid: missing user_token")
            completion(.failure)
            return
        }
        let userFromCache = UserEntity(
            token: token,
            id: id
        )
        
        // Check the validity of its token
        guard let validity = await dataSource.checkTokenValidity(token: token)
        else {
            CrashlyticsUtils.logEvent("Auth cache error: checkTokenValidity nil")
            CrashlyticsUtils.setCustomKey("last_auth_error", value: "checkTokenValidity_nil")
            CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            debugPrint(
                "Failed call to checkTokenValidity in isTokenInCacheValid")
            completion(.error)
            return
        }
        
        if validity.code == "jwt_auth_valid_token" {
            // Try to connect to firebase
            do {
                let authResult = try await Auth.auth().signInAnonymously()
                // Handle successful sign-in if needed
                debugPrint(
                    "Successfully signed in anonymously to Firebase: \(authResult.user.uid)"
                )

                // Inform analytics about this user identifier
                analytics.setUserId(authResult.user.uid)
                CrashlyticsUtils.logEvent("Auth success (cache anonymous)")
                CrashlyticsUtils.setUserId(userFromCache.id)
                CrashlyticsUtils.setUserContext(isLoggedIn: true)
                
                // Register the user
                self.user = userFromCache
                
                completion(.success)
            } catch {
                CrashlyticsUtils.recordException(error)
                CrashlyticsUtils.logEvent("Auth cache error: Firebase anonymous sign-in failed")
                CrashlyticsUtils.setCustomKey("last_auth_error", value: error.localizedDescription)
                CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
                debugPrint(
                    "Error connecting to Firebase anonymously: \(error.localizedDescription)"
                )
                completion(.error)
            }
        } else {
            CrashlyticsUtils.logEvent("Auth cache invalid: token not valid")
            CrashlyticsUtils.setCustomKey("last_auth_error", value: "cache_token_invalid")
            CrashlyticsUtils.setCustomKey("last_auth_error_time", value: String(CrashlyticsUtils.currentTimestampMillis))
            completion(.failure)
        }
    }
    
    func fetchUserInfos() async -> UserInfosEntity? {
        if let userInfos = await dataSource.fetchUserInfos() {
            return userInfos.toEntity()
        } else {
            return nil
        }
    }
    
    func reportConnexion() async -> Bool {
        let result = await dataSource.reportConnexion()
        return result == true
    }
    
    func updatePassword(
        initialPassword: String,
        newPassword: String,
        passwordRepeat: String
    ) async -> UserPasswordEditReturnEnum? {
        return await dataSource.updatePassword(
            userPasswordCandidate: UserPasswordEditModel(
                initialPassword: initialPassword, password: newPassword,
                passwordRepeat: passwordRepeat)
        )
    }
    
    func logout() {
        self.user = nil
        CrashlyticsUtils.logEvent("Logout")
        CrashlyticsUtils.setUserContext(isLoggedIn: false)
        
        // Remove the user from cache
        KeychainManager.instance.deleteValue(forKey: "user_id")
        KeychainManager.instance.deleteValue(forKey: "user_token")
        KeychainManager.instance.deleteValue(forKey: "user_token_issued_at")
        
        // Disconnect from Firebase
        do {
            try Auth.auth().signOut()
            // Reset analytics user information on logout
            analytics.reset()
            debugPrint("Successfully signed out from Firebase")
        } catch {
            debugPrint(
                "Error disconnecting from Firebase: \(error.localizedDescription)"
            )
        }
    }
}

