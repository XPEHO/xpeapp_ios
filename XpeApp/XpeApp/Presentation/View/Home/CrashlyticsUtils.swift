import Foundation
import FirebaseCrashlytics

public enum CrashlyticsUtils {
    
    public static func logEvent(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }
    
    public static func recordException(_ error: Error) {
        let nsError = error as NSError
        Crashlytics.crashlytics().record(error: nsError)
    }
    
    public static func setUserId(_ userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    public static func setCustomKey(_ key: String, value: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    public static func setCurrentScreen(_ screenName: String) {
        setCustomKey("screen", value: screenName)
        logEvent("Navigation to: \(screenName)")
    }
    
    public static func setCurrentFeature(_ featureName: String) {
        setCustomKey("feature", value: featureName)
    }
    
    public static func setUserContext(isLoggedIn: Bool, userRole: String = "") {
        setCustomKey("user_logged_in", value: String(isLoggedIn))
        if !userRole.isEmpty {
            setCustomKey("user_role", value: userRole)
        }
    }
}
