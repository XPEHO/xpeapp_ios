//
//  XpeAppApp.swift
//  XpeApp
//
//  Created by Loucas Cubeddu on 05/06/2024.
//

import SwiftUI
import SwiftData
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore
import FirebaseMessaging
import xpeho_ui

@main
struct XpeAppApp: App {
    @UIApplicationDelegateAdaptor(XpeAppAppDelegate.self) var delegate
    public static var firestore: Firestore = Firestore.firestore()
    
    init() {
        
        // Load XpehoUI fonts
        Fonts.registerFonts()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(AnalyticsModel.shared)
        }
    }
}

// Note(Loucas): This app delegate is used as part
// of the default Firebase SDK setup code
// Note(Loucas): Firebase method swizzling has been disabled. If it becomes necessary in the future,
// we can enable it through setting the FirebaseAppDelegateProxyEnabled boolean to 'NO' in Info.plist
class XpeAppAppDelegate: NSObject, UIApplicationDelegate {
    private var isUpdateRequired = false

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        // Initialize Firebase
        FirebaseApp.configure()
        // Set Firebase Messaging delegate
        Messaging.messaging().delegate = self
        // Request notification permissions
        registerForPushNotifications(application: application)
        // Check for updates
        checkForUpdate()

        // Add observer for willEnterForegroundNotification
        NotificationCenter.default.addObserver(self, selector: #selector(applicationWillEnterForeground), name: UIApplication.willEnterForegroundNotification, object: nil)

        return true
    }

    @objc func applicationWillEnterForeground(_ application: UIApplication) {
        if isUpdateRequired {
            checkForUpdate()
        }
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Disconnect from Firebase
        do {
            try Auth.auth().signOut()
            debugPrint("Successfully signed out from Firebase")
        } catch let signOutError as NSError {
            debugPrint("Error disconnecting from Firebase: \(signOutError)")
        }
    }

    private func checkForUpdate() {
        //guard !isDebug() else { return }
        
        DispatchQueue.global(qos: .background).async {
            let latestVersion = self.getLatestReleaseTag()
            let currentVersion = self.getCurrentAppVersion()
            
            if let latestVersion = latestVersion {debugPrint("Latest: "+latestVersion)}
            debugPrint("Current: "+currentVersion)
            
            if let latestVersion = latestVersion, self.isVersionLessThan(currentVersion, latestVersion) {
                self.isUpdateRequired = true
                DispatchQueue.main.async {
                    self.showUpdateDialog(version: latestVersion)
                }
            } else {
                self.isUpdateRequired = false
            }
        }
    }

    private func showUpdateDialog(version: String) {
        let alert = UIAlertController(
            title: "Mise à jour requise",
            message: "La version \(version) est disponible. Veuillez mettre à jour l'application pour continuer.",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Mettre à jour", style: .default) { _ in
            if let url = URL(string: "itms-apps://apps.apple.com/fr/app/xpeapp/id6503239208") {
                UIApplication.shared.open(url) { success in
                if !success {
                    // If the URL could not be opened, re-present the update dialog
                    DispatchQueue.main.async {
                        self.showUpdateDialog(version: version)
                    }
                }
            }
            }
        })
        alert.isModalInPresentation = true 
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(alert, animated: true, completion: nil)
        }
    }

    private func getCurrentAppVersion() -> String {
        return Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0.0"
    }

    private func getLatestReleaseTag() -> String? {
        let url = URL(string: "https://api.github.com/repos/XPEHO/xpeapp_ios/releases/latest")!
        var latestVersion: String?
        
        let semaphore = DispatchSemaphore(value: 0)
        
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            defer { semaphore.signal() }
            guard let data = data, error == nil else { return }
            
            if let jsonResponse = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
               let tagName = jsonResponse["tag_name"] as? String {
                latestVersion = tagName
            }
        }
        
        task.resume()
        semaphore.wait()
        
        return latestVersion
    }

    private func isVersionLessThan(_ currentVersion: String, _ latestVersion: String) -> Bool {
        let currentParts = currentVersion.split(separator: ".").compactMap { Int($0) }
        let latestParts = latestVersion.split(separator: ".").compactMap { Int($0) }
        
        for i in 0..<max(currentParts.count, latestParts.count) {
            let currentPart = currentParts[i]
            let latestPart = latestParts[i]
            
            if currentPart < latestPart { return true }
            if currentPart > latestPart { return false }
        }
        return false
    }
}

extension XpeAppAppDelegate: UNUserNotificationCenterDelegate {
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print(error)
    }
    
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        //self.sendDeviceTokenToServer(data: deviceToken)
        Messaging.messaging().setAPNSToken(deviceToken, type: .unknown)
    }
    
    private func registerForPushNotifications(application: UIApplication) {
        UNUserNotificationCenter.current().delegate = self
        
        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
            options: authOptions
        ) { (granted, error) in
            guard granted else {return}
            DispatchQueue.main.async{
                application.registerForRemoteNotifications()
            }
        }
    }
}

extension XpeAppAppDelegate: MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //print("Firebase registration token: \(String(describing: fcmToken))")
    }
}

