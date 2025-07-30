import DeviceActivity
import ManagedSettings
import SwiftUI

class DeviceActivityMonitor: DeviceActivityMonitor {
    let store = ManagedSettingsStore()
    let center = DeviceActivityCenter()
    
    override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // When the monitoring interval starts, apply restrictions
        let selection = FamilyActivitySelection()
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = selection.categoryTokens
    }
    
    override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // When the monitoring interval ends, remove restrictions
        store.shield.applications = nil
        store.shield.applicationCategories = nil
    }
    
    override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // This is called when the user tries to access a blocked app
        // We'll show our custom AffirmationGateView here
        showAffirmationGate()
    }
    
    private func showAffirmationGate() {
        // Post notification to show AffirmationGateView
        NotificationCenter.default.post(
            name: NSNotification.Name("ShowAffirmationGate"),
            object: nil
        )
    }
} 