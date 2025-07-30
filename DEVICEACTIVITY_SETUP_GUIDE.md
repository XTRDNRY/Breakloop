# DeviceActivity App Gating Setup Guide

## Overview
This guide will help you set up DeviceActivity-based app gating that shows your custom `AffirmationGateView` instead of Apple's default red screen.

## What's New
- **DeviceActivity Extension**: Intercepts app launches and shows custom UI
- **Custom AffirmationGateView**: Replaces Apple's default "Restricted" screen
- **Real Device Support**: Works on actual devices, not just simulator

## Files Created/Modified

### New Files:
1. `DeviceActivityExtension/DeviceActivityMonitor.swift` - Intercepts app launches
2. `DeviceActivityExtension/DeviceActivityReport.swift` - Widget and Dynamic Island UI
3. `DeviceActivityExtension/DeviceActivityExtensionBundle.swift` - Extension entry point
4. `DeviceActivityExtension/Info.plist` - Extension configuration
5. `TestDeviceActivityView.swift` - Test interface

### Modified Files:
1. `AppGatingManager.swift` - Updated to use DeviceActivity
2. `Breakloop.entitlements` - Added DeviceActivity permission

## Xcode Project Setup

### 1. Add DeviceActivity Extension Target
1. In Xcode, go to **File > New > Target**
2. Select **Device Activity Monitoring Extension**
3. Name it `DeviceActivityExtension`
4. Make sure it's added to your main app target

### 2. Configure Capabilities
1. Select your main app target
2. Go to **Signing & Capabilities**
3. Add **Device Activity Monitoring** capability
4. Add **Family Controls** capability (if not already added)

### 3. Update Bundle Identifiers
1. Main app: `com.yourcompany.Breakloop`
2. Extension: `com.yourcompany.Breakloop.DeviceActivityExtension`

## How It Works

### 1. App Selection
```swift
// User selects apps using FamilyActivityPicker
@State private var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
```

### 2. DeviceActivity Monitoring
```swift
// AppGatingManager starts monitoring
private func startDeviceActivityMonitoring(appTokens: Set<ApplicationToken>) {
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
    
    try deviceActivityCenter.startMonitoring(activity, during: schedule, events: [event.name: event])
}
```

### 3. Intercept App Launches
```swift
// DeviceActivityMonitor.swift
override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
    // This is called when user tries to open blocked app
    showAffirmationGate()
}
```

### 4. Show Custom UI
```swift
// AppGatingManager.swift
private func handleDeviceActivityTrigger() {
    if let firstBlockedApp = blockedApps.first {
        DispatchQueue.main.async {
            self.showAffirmationGateForApp(firstBlockedApp)
        }
    }
}
```

## Testing Steps

### 1. Build and Run
1. Build the project for a real device (not simulator)
2. Run the app and grant Family Controls permission

### 2. Test App Selection
1. Open `TestDeviceActivityView`
2. Tap "Select Apps to Block"
3. Choose apps you want to gate
4. Verify apps appear in blocked list

### 3. Test DeviceActivity Blocking
1. Tap "Apply DeviceActivity Blocking"
2. Check that "DeviceActivity Active" shows "Yes"
3. Try to open a blocked app
4. You should see `AffirmationGateView` instead of Apple's red screen

### 4. Test Affirmation Flow
1. Complete the affirmation or tap "Skip"
2. App should temporarily unlock
3. You can access the blocked app for 5 seconds

## Troubleshooting

### Issue: Still seeing Apple's red screen
**Solution**: 
- Make sure DeviceActivity Extension is properly configured
- Check that `DeviceActivityMonitor.swift` is included in the extension target
- Verify entitlements include `com.apple.developer.device-activity.monitoring`

### Issue: AffirmationGateView not showing
**Solution**:
- Check that `NotificationCenter` is properly set up
- Verify `AppGatingManager` is listening for "ShowAffirmationGate" notification
- Ensure `AffirmationGateView` is properly overlaid in `BreakloopApp.swift`

### Issue: App not blocking on real device
**Solution**:
- Make sure you're testing on a real device (not simulator)
- Verify Family Controls permission is granted
- Check that DeviceActivity Extension is properly signed and deployed

## Key Differences from Previous Implementation

### Before (ManagedSettingsStore only):
```swift
// Shows Apple's default red screen
store.shield.applications = appTokens
```

### After (DeviceActivity):
```swift
// Shows custom AffirmationGateView
startDeviceActivityMonitoring(appTokens: appTokens)
```

## Integration with Existing Code

The new implementation is backward compatible. Your existing `AffirmationGateView` and `AffirmationStore` will work unchanged. The only difference is how the gate is triggered:

- **Before**: Manual triggers and app state monitoring
- **After**: DeviceActivity system triggers

## Next Steps

1. **Test on Real Device**: DeviceActivity only works on physical devices
2. **Customize UI**: Modify `AffirmationGateView` as needed
3. **Add Persistence**: Save DeviceActivity state across app launches
4. **Add Analytics**: Track when users complete affirmations vs skip

## Important Notes

- **Real Device Required**: DeviceActivity doesn't work in simulator
- **Family Controls Permission**: Users must grant permission
- **Background Processing**: DeviceActivity runs in background
- **Battery Impact**: Minimal, but monitor for any issues

## Code Summary

The key files you need to copy/paste:

1. **DeviceActivityExtension/DeviceActivityMonitor.swift** - Intercepts app launches
2. **DeviceActivityExtension/DeviceActivityReport.swift** - Widget UI
3. **DeviceActivityExtension/DeviceActivityExtensionBundle.swift** - Entry point
4. **Updated AppGatingManager.swift** - Uses DeviceActivity instead of direct ManagedSettingsStore
5. **TestDeviceActivityView.swift** - Test interface

This implementation will show your custom `AffirmationGateView` every time a user tries to open a blocked app, replacing Apple's default red screen completely. 