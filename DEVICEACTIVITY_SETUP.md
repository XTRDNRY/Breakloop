# DeviceActivity Extension Setup Guide

This guide explains how to properly set up the DeviceActivity extension in Xcode to enable app gating functionality in BreakLoop.

## Overview

The DeviceActivity extension is essential for monitoring app launches at the system level. Without it, the app gating functionality will not work properly in production builds.

## Step 1: Add DeviceActivity Extension Target

1. Open your project in Xcode
2. Go to **File** → **New** → **Target**
3. Select **Device Activity Report Extension** under iOS
4. Name it `DeviceActivityExtension`
5. Make sure it's added to your main app target

## Step 2: Configure the Extension

### 2.1 Update Extension's Info.plist

The extension's Info.plist should include:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.deviceactivity.report</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).DeviceActivityExtension</string>
</dict>
<key>NSDeviceActivityReportExtension</key>
<dict>
    <key>NSDeviceActivityReportExtensionUUID</key>
    <string>$(PRODUCT_MODULE_NAME).DeviceActivityExtension</string>
</dict>
```

### 2.2 Add Required Frameworks

In the extension target, add these frameworks:
- `DeviceActivity.framework`
- `ManagedSettings.framework`
- `FamilyControls.framework`

### 2.3 Configure Capabilities

1. Select the extension target
2. Go to **Signing & Capabilities**
3. Add **Family Controls** capability
4. Ensure the Team ID matches your main app

## Step 3: Update Main App Configuration

### 3.1 Add DeviceActivity Framework

In your main app target, add:
- `DeviceActivity.framework`

### 3.2 Update Entitlements

Ensure your main app's entitlements include:
```xml
<key>com.apple.developer.family-controls</key>
<true/>
```

## Step 4: Build and Test

### 4.1 Build Requirements
- **Physical Device Required**: DeviceActivity doesn't work in simulator
- **iOS 15.0+**: DeviceActivity requires iOS 15 or later
- **Family Controls Authorization**: Users must grant permission

### 4.2 Testing Steps

1. Build and run on a physical device
2. Grant Family Controls permission when prompted
3. Add apps to the blocked list
4. Try launching a blocked app
5. Verify the affirmation gate appears

## Step 5: Troubleshooting

### Common Issues

1. **Extension not working**: 
   - Check that DeviceActivity extension is properly configured
   - Verify the extension target is included in the build

2. **Affirmation not showing**: 
   - Verify DeviceActivity monitoring is set up correctly
   - Check console logs for DeviceActivity events

3. **App crashes**: 
   - Check for proper error handling in DeviceActivity callbacks
   - Verify all required frameworks are linked

4. **Permission denied**: 
   - Ensure Family Controls capability is added
   - Check that user has granted permission

### Debug Tips

1. Check console logs for DeviceActivity events
2. Use Xcode's device console to monitor extension logs
3. Test with a simple app first (like Calculator)
4. Verify the extension is running in Background App Refresh

## Step 6: Production Deployment

### 6.1 App Store Requirements

- Include DeviceActivity extension in your app bundle
- Ensure all capabilities are properly configured
- Test thoroughly on multiple devices

### 6.2 Privacy Considerations

- Clearly explain why Family Controls permission is needed
- Provide clear instructions for users
- Handle permission denial gracefully

## Code Integration

The DeviceActivity extension works with these key components:

1. **AppGatingManager**: Manages the monitoring setup
2. **DeviceActivityExtension**: Handles system-level events
3. **AffirmationGateView**: Shows the affirmation interface
4. **UserSettings**: Stores blocked app preferences

## Testing Checklist

- [ ] Extension builds without errors
- [ ] Family Controls permission granted
- [ ] Apps can be added to blocked list
- [ ] Blocked app launches trigger affirmation gate
- [ ] Affirmation typing works correctly
- [ ] Skip button functions properly
- [ ] App unlocks after successful affirmation
- [ ] Monitoring continues after app restart

## Support

If you encounter issues:

1. Check the console logs for error messages
2. Verify all framework dependencies are linked
3. Ensure the extension target is properly configured
4. Test on a physical device (not simulator)
5. Verify Family Controls permission is granted

## Important Notes

- DeviceActivity only works on physical devices
- Requires iOS 15.0 or later
- Users must explicitly grant Family Controls permission
- The extension runs in the background
- Monitor battery usage as background monitoring can impact performance 