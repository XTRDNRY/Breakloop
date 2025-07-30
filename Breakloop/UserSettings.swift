import Foundation

class UserSettings {
    static let shared = UserSettings()
    
    private let userDefaults = UserDefaults.standard
    private let blockedAppsKey = "blockedApps"
    
    private init() {}
    
    func isAppBlocked(bundleID: String) -> Bool {
        let blockedApps = getBlockedApps()
        return blockedApps.contains(bundleID)
    }
    
    func blockApp(bundleID: String) {
        var blockedApps = getBlockedApps()
        blockedApps.insert(bundleID)
        setBlockedApps(blockedApps)
    }
    
    func unblockApp(bundleID: String) {
        var blockedApps = getBlockedApps()
        blockedApps.remove(bundleID)
        setBlockedApps(blockedApps)
    }
    
    func getBlockedApps() -> Set<String> {
        return Set(userDefaults.stringArray(forKey: blockedAppsKey) ?? [])
    }
    
    private func setBlockedApps(_ apps: Set<String>) {
        userDefaults.set(Array(apps), forKey: blockedAppsKey)
    }
} 