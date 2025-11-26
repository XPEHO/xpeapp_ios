import Foundation
import FirebaseCrashlytics

struct CrashlyticsManager {
    static func configureCollection(isEnabled: Bool) {
        Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(isEnabled)
    }

    static func setUser(id: String?, name: String?, email: String?) {
        let crashlytics = Crashlytics.crashlytics()
        if let id = id {
            crashlytics.setUserID(id)
        }
        if let name = name {
            crashlytics.setCustomValue(name, forKey: "userName")
        }
        if let email = email {
            crashlytics.setCustomValue(email, forKey: "userEmail")
        }
    }

    static func log(_ message: String) {
        Crashlytics.crashlytics().log(message)
    }

    static func record(error: Error, userInfo: [String: Any]? = nil) {
        if let userInfo = userInfo {
            Crashlytics.crashlytics().record(error: error, userInfo: userInfo)
        } else {
            Crashlytics.crashlytics().record(error: error)
        }
    }
}
