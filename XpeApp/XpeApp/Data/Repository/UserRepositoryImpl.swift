//
//  UserRepositoryImpl.swift
//  XpeApp
//
//  Created by Ryan Debouvries on 06/09/2024.
//

import FirebaseAuth
import Foundation

@Observable class UserRepositoryImpl: UserRepository {
    // An instance for app and a mock for tests
    static let instance = UserRepositoryImpl()
    static let mock = UserRepositoryImpl(
        dataSource: MockWordpressAPI.instance
    )
    
    // Data source to use
    private let dataSource: WordpressAPIProtocol
    
    // Watched user
    var user: UserEntity? = nil
    
    // Make private constructor to prevent use without shared instances
    private init(
        dataSource: WordpressAPIProtocol = WordpressAPI.instance
    ) {
        self.dataSource = dataSource
    }
    
    func login(
        username: String,
        password: String,
        completion: @escaping (LoginResult) -> Void
    ) async {
        // Generate token
        guard
            let tokenResponse = await dataSource.generateToken(
                userCandidate: UserCandidateModel(
                    username: username,
                    password: password
                )
            )
        else {
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
                AnalyticsModel.shared.setUserId(authResult.user.uid)
                
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
                
                completion(.success)
            } catch {
                debugPrint(
                    "Error connecting to Firebase anonymously to Firebase: \(error.localizedDescription)"
                )
                completion(.error)
            }
        } else if tokenResponse.error != nil {
            completion(.failure)
        } else {
            debugPrint("Unhandled tokenResponse in login")
            completion(.error)
        }
    }
    
    func loginWithCacheIfTokenValid(
        completion: @escaping (LoginResult) -> Void
    ) async {
        // Check local token expiration based on issued_at stored in Keychain
        if let issuedAtString = KeychainManager.instance.getValue(forKey: "user_token_issued_at"),
           let issuedAt = fullDateTimeFormatter.date(from: issuedAtString) {
            let now = Date()
            let totalLifetimeSeconds: TimeInterval = tokenLifetimeSeconds
            let ageSeconds = now.timeIntervalSince(issuedAt)
            if ageSeconds >= totalLifetimeSeconds {
                // Token expired locally -> perform the same logout as profile page
                self.logout()
                completion(.failure)
                return
            }
        } else {
            // No issued_at in cache -> consider invalid and logout
            self.logout()
            completion(.failure)
            return
        }
        
        // Get the user from cache
        guard let id = KeychainManager.instance.getValue(forKey: "user_id")
        else {
            completion(.failure)
            return
        }
        guard
            let token = KeychainManager.instance.getValue(forKey: "user_token")
        else {
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
                AnalyticsModel.shared.setUserId(authResult.user.uid)
                
                // Register the user
                self.user = userFromCache
                
                completion(.success)
            } catch {
                debugPrint(
                    "Error connecting to Firebase anonymously: \(error.localizedDescription)"
                )
                completion(.error)
            }
        } else {
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
        
        // Remove the user from cache
        KeychainManager.instance.deleteValue(forKey: "user_id")
        KeychainManager.instance.deleteValue(forKey: "user_token")
        KeychainManager.instance.deleteValue(forKey: "user_token_issued_at")
        
        // Disconnect from Firebase
        do {
            try Auth.auth().signOut()
            // Reset analytics user information on logout
            AnalyticsModel.shared.reset()
            debugPrint("Successfully signed out from Firebase")
        } catch {
            debugPrint(
                "Error disconnecting from Firebase: \(error.localizedDescription)"
            )
        }
    }
}

