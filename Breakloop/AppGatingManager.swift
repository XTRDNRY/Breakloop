import FamilyControls
import ManagedSettings
import DeviceActivity
import SwiftUI
import Combine

// MARK: - BlockedApp Struct
#if canImport(FamilyControls)
struct BlockedApp: Identifiable, Hashable {
    let id = UUID()
    let token: ApplicationToken
    let displayName: String
    let bundleIdentifier: String
    
    init(token: ApplicationToken, displayName: String, bundleIdentifier: String) {
        self.token = token
        self.displayName = displayName
        self.bundleIdentifier = bundleIdentifier
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
    }
    
    static func == (lhs: BlockedApp, rhs: BlockedApp) -> Bool {
        return lhs.displayName == rhs.displayName
    }
}
#else
struct BlockedApp: Identifiable, Hashable {
    let id = UUID()
    let token: Any
    let displayName: String
    let bundleIdentifier: String
    
    init(token: Any, displayName: String, bundleIdentifier: String) {
        self.token = token
        self.displayName = displayName
        self.bundleIdentifier = bundleIdentifier
    }
    
    // Hashable conformance
    func hash(into hasher: inout Hasher) {
        hasher.combine(displayName)
    }
    
    static func == (lhs: BlockedApp, rhs: BlockedApp) -> Bool {
        return lhs.displayName == rhs.displayName
    }
}
#endif

// MARK: - AppGatingManager
class AppGatingManager: ObservableObject {
    static let shared = AppGatingManager()
    
    // MARK: - Published Properties
    @Published var showAffirmationGate = false
    @Published var currentAppName = ""
    @Published var currentGatedApp = ""
    @Published var blockedApps: [BlockedApp] = []
    @Published var isShowingFamilyActivityPicker = false
    
    // MARK: - Private Properties
    private let center = AuthorizationCenter.shared
    private let store = ManagedSettingsStore()
    private let deviceActivityCenter = DeviceActivityCenter()
    private var subscriptions = Set<AnyCancellable>()
    #if canImport(FamilyControls)
    private var selectedApps = Set<ApplicationToken>()
    #else
    private var selectedApps = Set<String>()
    #endif
    private var lastGateTime = Date()
    private var appCheckTimer: Timer?
    
    // App launch detection
    private var lastActiveTime = Date()
    private var isMonitoringAppLaunches = false
    
    // DeviceActivity monitoring
    var currentActivity: DeviceActivityName?
    private var currentSchedule: DeviceActivitySchedule?
    
    private init() {
        setupAppGating()
        loadBlockedApps()
        startAppLaunchMonitoring()
        setupDeviceActivityMonitoring()
    }
    
    // MARK: - Setup
    private func setupAppGating() {
        #if canImport(FamilyControls)
        #if targetEnvironment(simulator)
        print("FamilyControls not available in simulator - cannot apply app blocking")
        return
        #else
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                print("FamilyControls authorization confirmed")
            } catch {
                print("Failed to get FamilyControls authorization: \(error)")
            }
        }
        #endif
        #else
        print("FamilyControls not available - cannot apply app blocking")
        #endif
    }
    
    // MARK: - App Launch Monitoring
    private func startAppLaunchMonitoring() {
        // Monitor when app becomes active (user returns to our app)
        NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppBecameActive()
            }
            .store(in: &subscriptions)
        
        // Monitor when app enters foreground
        NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)
            .sink { [weak self] _ in
                self?.handleAppBecameActive()
            }
            .store(in: &subscriptions)
        
        // Monitor when app goes to background (user might be trying to open blocked app)
        NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)
            .sink { [weak self] _ in
                self?.handleAppWillResignActive()
            }
            .store(in: &subscriptions)
        
        print("App launch monitoring started")
    }
    
    // MARK: - App State Handlers
    private func handleAppBecameActive() {
        let now = Date()
        let timeSinceLastActive = now.timeIntervalSince(lastActiveTime)
        
        // If user was away for more than 1 second, they might have tried to open a blocked app
        if timeSinceLastActive > 1.0 && !blockedApps.isEmpty {
            print("App became active after \(timeSinceLastActive) seconds - checking for blocked app launch")
            checkForBlockedAppLaunch()
        }
        
        lastActiveTime = now
    }
    
    private func handleAppWillResignActive() {
        // User is leaving our app - they might be trying to open a blocked app
        print("App will resign active - user might be trying to open blocked app")
        lastActiveTime = Date()
    }
    
    private func checkForBlockedAppLaunch() {
        guard !blockedApps.isEmpty else { return }
        
        let timeSinceLastGate = Date().timeIntervalSince(lastGateTime)
        if timeSinceLastGate > 2 { // 2 second cooldown to prevent spam
            if let firstBlockedApp = blockedApps.first {
                print("Detected potential blocked app launch: \(firstBlockedApp.displayName)")
                showAffirmationGateForApp(firstBlockedApp)
                lastGateTime = Date()
            }
        }
    }
    
    // MARK: - DeviceActivity Monitoring Setup
    private func setupDeviceActivityMonitoring() {
        // Listen for notifications from DeviceActivityMonitor
        NotificationCenter.default.publisher(for: NSNotification.Name("ShowAffirmationGate"))
            .sink { [weak self] _ in
                self?.handleDeviceActivityTrigger()
            }
            .store(in: &subscriptions)
    }
    
    private func handleDeviceActivityTrigger() {
        // When DeviceActivityMonitor triggers, show the affirmation gate
        if let firstBlockedApp = blockedApps.first {
            DispatchQueue.main.async {
                self.showAffirmationGateForApp(firstBlockedApp)
            }
        }
    }
    
    // MARK: - ManagedSettingsStore Shield Applications
    func applyAppBlocking() {
        #if canImport(FamilyControls)
        #if targetEnvironment(simulator)
        print("FamilyControls not available in simulator - cannot apply app blocking")
        return
        #else
        Task {
            do {
                try await center.requestAuthorization(for: .individual)
                print("FamilyControls authorization confirmed")
                
                // Convert blocked apps to ApplicationTokens
                let appTokens = Set(blockedApps.compactMap { blockedApp in
                    return blockedApp.token as? ApplicationToken
                })
                
                // Use DeviceActivity instead of direct ManagedSettingsStore.shield.applications
                // This allows us to intercept app launches and show custom UI
                startDeviceActivityMonitoring(appTokens: appTokens)
                
                // Store in UserSettings for persistence
                for blockedApp in blockedApps {
                    UserSettings.shared.blockApp(bundleID: blockedApp.bundleIdentifier)
                }
                
                print("App blocking is now active using DeviceActivity - will show custom AffirmationGateView")
            } catch {
                print("Failed to apply app blocking: \(error)")
            }
        }
        #endif
        #else
        print("FamilyControls not available - cannot apply app blocking")
        #endif
    }
    
    private func startDeviceActivityMonitoring(appTokens: Set<ApplicationToken>) {
        // Create a DeviceActivity schedule that runs continuously
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        let activity = DeviceActivityName("AppGating")
        let event = DeviceActivityEvent(
            applications: appTokens,
            threshold: DateComponents(minute: 0)
        )
        
        do {
            try deviceActivityCenter.startMonitoring(
                activity,
                during: schedule,
                events: [
                    event.name: event
                ]
            )
            
            currentActivity = activity
            currentSchedule = schedule
            
            print("Started DeviceActivity monitoring for \(appTokens.count) apps")
        } catch {
            print("Failed to start DeviceActivity monitoring: \(error)")
            // Fallback to direct ManagedSettingsStore
            store.shield.applications = appTokens
        }
    }
    
    func removeAppBlocking() {
        #if canImport(FamilyControls)
        // Stop DeviceActivity monitoring
        if let activity = currentActivity {
            deviceActivityCenter.stopMonitoring([activity])
            currentActivity = nil
            currentSchedule = nil
        }
        
        // Remove all app restrictions
        store.shield.applications = nil
        print("Removed app blocking - all apps are now accessible")
        #endif
    }
    
    func temporarilyUnlockApps() {
        #if canImport(FamilyControls)
        // Temporarily stop DeviceActivity monitoring
        if let activity = currentActivity {
            deviceActivityCenter.stopMonitoring([activity])
        }
        
        // Temporarily remove restrictions to allow app access
        store.shield.applications = nil
        print("Temporarily unlocked all apps")
        
        // Re-apply blocking after a delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            self.applyAppBlocking()
            print("Re-applied app blocking after temporary unlock")
        }
        #endif
    }
    
    // MARK: - Affirmation Gate Management
    func showAffirmationGateForApp(_ blockedApp: BlockedApp) {
        DispatchQueue.main.async {
            self.currentAppName = blockedApp.displayName
            self.currentGatedApp = blockedApp.displayName
            self.showAffirmationGate = true
            
            print("Showing AffirmationGateView for: \(blockedApp.displayName)")
        }
    }
    
    func hideAffirmationGate() {
        DispatchQueue.main.async {
            self.showAffirmationGate = false
            self.currentAppName = ""
            self.currentGatedApp = ""
            
            print("Hidden AffirmationGateView")
        }
    }
    
    func completeAffirmation() {
        // Temporarily unlock apps so user can access the blocked app
        temporarilyUnlockApps()
        
        // Hide the affirmation gate
        hideAffirmationGate()
        
        print("Affirmation completed - apps temporarily unlocked")
    }
    
    // MARK: - App Management
    func addBlockedApp(_ blockedApp: BlockedApp) {
        #if canImport(FamilyControls)
        if let token = blockedApp.token as? ApplicationToken {
            selectedApps.insert(token)
        }
        #else
        selectedApps.insert(blockedApp.token)
        #endif
        blockedApps.append(blockedApp)
        applyAppBlocking()
        saveBlockedApps()
        print("Added blocked app: \(blockedApp.displayName)")
        
        // Show gate immediately after adding app
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.showAffirmationGateForApp(blockedApp)
        }
    }
    
    func removeBlockedApp(_ blockedApp: BlockedApp) {
        #if canImport(FamilyControls)
        if let token = blockedApp.token as? ApplicationToken {
            selectedApps.remove(token)
        }
        #else
        selectedApps.remove(blockedApp.token)
        #endif
        blockedApps.removeAll { $0.id == blockedApp.id }
        applyAppBlocking()
        saveBlockedApps()
        print("Removed blocked app: \(blockedApp.displayName)")
    }
    
    // MARK: - Persistence
    private func saveBlockedApps() {
        let blockedAppsData = blockedApps.map { blockedApp in
            [
                "displayName": blockedApp.displayName,
                "bundleIdentifier": blockedApp.bundleIdentifier
            ]
        }
        UserDefaults.standard.set(blockedAppsData, forKey: "BlockedApps")
    }
    
    private func loadBlockedApps() {
        guard let blockedAppsData = UserDefaults.standard.array(forKey: "BlockedApps") as? [[String: Any]] else {
            return
        }
        
        for appData in blockedAppsData {
            if let displayName = appData["displayName"] as? String,
               let bundleIdentifier = appData["bundleIdentifier"] as? String {
                #if canImport(FamilyControls)
                // In a real implementation, you'd need to recreate the ApplicationToken
                // For now, we'll skip loading in simulator
                print("Cannot load blocked apps in simulator - FamilyControls not available")
                #else
                let blockedApp = BlockedApp(
                    token: bundleIdentifier as Any,
                    displayName: displayName,
                    bundleIdentifier: bundleIdentifier
                )
                blockedApps.append(blockedApp)
                #endif
            }
        }
    }
    
    // MARK: - Testing Methods
    func testAppBlocking() {
        print("Testing app blocking...")
        applyAppBlocking()
    }
    
    func testAffirmationGate() {
        print("Testing affirmation gate...")
        
        if let firstBlockedApp = blockedApps.first {
            print("Testing affirmation gate for: \(firstBlockedApp.displayName)")
            showAffirmationGateForApp(firstBlockedApp)
        } else {
            print("No blocked apps found - add some apps first")
        }
    }
    
    func forceTriggerGating() {
        print("Force triggering app gating...")
        
        if let firstBlockedApp = blockedApps.first {
            print("Force triggering for: \(firstBlockedApp.displayName)")
            showAffirmationGateForApp(firstBlockedApp)
        } else {
            print("No blocked apps available")
        }
    }
    
    // MARK: - Direct Gate Control (for testing)
    func showGateImmediately() {
        print("Showing gate immediately...")
        
        if let firstBlockedApp = blockedApps.first {
            print("Showing gate for: \(firstBlockedApp.displayName)")
            DispatchQueue.main.async {
                self.currentAppName = firstBlockedApp.displayName
                self.currentGatedApp = firstBlockedApp.displayName
                self.showAffirmationGate = true
                print("Gate should be visible now!")
            }
        } else {
            print("No blocked apps available")
        }
    }
    
    func showGateWithDelay() {
        print("Showing gate with delay...")
        
        if let firstBlockedApp = blockedApps.first {
            print("Showing gate for: \(firstBlockedApp.displayName)")
            showAffirmationGateForApp(firstBlockedApp)
        } else {
            print("No blocked apps available")
        }
    }
    
    // MARK: - Family Activity Picker
    func showFamilyActivityPicker() {
        isShowingFamilyActivityPicker = true
    }
    
    func hideFamilyActivityPicker() {
        isShowingFamilyActivityPicker = false
    }
}



 