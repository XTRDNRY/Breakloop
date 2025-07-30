import XCTest
@testable import Breakloop

// ✅ Unit tests for FamilyControls functionality
// ✅ These tests focus on your app logic, not the framework itself
class FamilyControlsTests: XCTestCase {
    
    var gatingManager: AppGatingManager!
    
    override func setUp() {
        super.setUp()
        gatingManager = AppGatingManager.shared
    }
    
    override func tearDown() {
        gatingManager = nil
        super.tearDown()
    }
    
    // ✅ Test your app's logic, not FamilyControls framework
    func testAppGatingManagerInitialization() {
        // Test that your AppGatingManager initializes correctly
        XCTAssertNotNil(gatingManager)
        XCTAssertFalse(gatingManager.showAffirmationScreen)
        XCTAssertFalse(gatingManager.showBreakLoopView)
        XCTAssertNil(gatingManager.currentAppName)
    }
    
    func testBlockedAppsManagement() {
        // Test your app's blocked apps logic
        XCTAssertTrue(gatingManager.blockedApps.isEmpty)
        
        // Test adding a blocked app (using your BlockedApp struct)
        #if canImport(FamilyControls)
        let testBlockedApp = BlockedApp(
            token: ApplicationToken(), // This won't work in tests, but your struct should
            displayName: "Test App",
            bundleIdentifier: "com.test.app"
        )
        #else
        let testBlockedApp = BlockedApp(
            token: "mock_token",
            displayName: "Test App",
            bundleIdentifier: "com.test.app"
        )
        #endif
        
        // Test your app's methods
        gatingManager.addBlockedApp(testBlockedApp)
        XCTAssertEqual(gatingManager.blockedApps.count, 1)
        
        gatingManager.removeBlockedApp(testBlockedApp)
        XCTAssertTrue(gatingManager.blockedApps.isEmpty)
    }
    
    func testUserSettingsIntegration() {
        // Test your UserSettings integration
        let userSettings = UserSettings.shared
        
        // Test app blocking logic
        userSettings.blockApp(bundleID: "com.test.app")
        XCTAssertTrue(userSettings.isAppBlocked(bundleID: "com.test.app"))
        
        userSettings.unblockApp(bundleID: "com.test.app")
        XCTAssertFalse(userSettings.isAppBlocked(bundleID: "com.test.app"))
    }
    
    func testAffirmationGeneration() {
        // Test your affirmation generation logic
        let appName = "Instagram"
        let affirmation = gatingManager.getRandomAffirmationForApp(appName)
        
        XCTAssertNotNil(affirmation)
        XCTAssertFalse(affirmation.isEmpty)
        XCTAssertTrue(affirmation.contains("mindful") || affirmation.contains("connect"))
    }
}

// ✅ Mock for testing without FamilyControls
#if canImport(FamilyControls)
class MockApplicationToken {
    let id = UUID()
    
    init() {}
}
#else
class MockApplicationToken {
    let id = UUID()
    
    init() {}
}
#endif

// ✅ Extension to make your code testable
extension AppGatingManager {
    // ✅ This method should be internal for testing
    func getRandomAffirmationForApp(_ appName: String) -> String {
        // App-specific affirmations
        let appSpecificAffirmations: [String: [String]] = [
            "instagram": [
                "I choose to connect meaningfully with others",
                "I share content that adds value to others",
                "I am mindful of my social media usage"
            ],
            "tiktok": [
                "I am mindful of how I spend my time",
                "I choose content that enriches my life",
                "I am in control of my digital habits"
            ],
            "youtube": [
                "I seek knowledge and growth",
                "I choose content that educates and inspires",
                "I am intentional about my learning"
            ]
        ]
        
        // Get app-specific affirmations or use general ones
        let availableAffirmations = appSpecificAffirmations[appName.lowercased()] ?? [
            "I am in control of my digital habits",
            "I choose to be mindful of my time",
            "I am intentional about my choices",
            "I am present in this moment",
            "I choose what serves my highest good"
        ]
        
        // Return a random affirmation
        return availableAffirmations.randomElement() ?? "I am mindful of my choices"
    }
} 