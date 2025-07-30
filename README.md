# 🚫 BreakLoop – Reclaim Your Mind Before You Scroll

**BreakLoop** is a mindful iOS app that blocks distracting apps (like Instagram or TikTok) until the user completes a meaningful affirmation. It gives you a pause before the scroll — to help you build habits of presence, intention, and self-control.

> 🧘 Break the loop. One affirmation at a time.

---

## 📱 Core Features

- Gate any app with Apple's Screen Time API
- Affirmation screen must be completed to continue
- Multiple themes like Motivation, Trust in God, Relationships
- Custom affirmations supported
- Built with a dark, minimalist UI

---

## 🛠️ Developer Documentation

⬇️ _The section below explains the full implementation for developers, contributors, and testers._

👇👇👇

# BreakLoop - App Gating Implementation

## Overview

BreakLoop is an iOS app that implements app gating functionality using FamilyControls, ManagedSettings, and DeviceActivity. When a gated app is launched, BreakLoop opens with an affirmation typing screen that the user must complete to proceed.

## Key Features

- **App Gating**: Blocks access to selected apps until affirmation is completed
- **Affirmation System**: Users must type affirmations exactly to unlock apps
- **DeviceActivity Integration**: System-level monitoring of app launches
- **ManagedSettings**: Actual app blocking using iOS system APIs
- **FamilyControls**: Authorization and app selection

## Implementation Details

### 1. App Gating Flow

1. **App Selection**: Users select apps to gate using FamilyActivityPicker
2. **App Blocking**: Selected apps are blocked using ManagedSettingsStore
3. **Launch Detection**: DeviceActivity monitors when gated apps are launched
4. **Affirmation Screen**: BreakLoop opens with affirmation typing screen
5. **Completion**: User must type affirmation exactly to unlock the app

### 2. Core Components

#### AppGatingManager.swift
- Manages app gating state and configuration
- Handles DeviceActivity monitoring setup
- Coordinates between FamilyControls and ManagedSettings
- Processes app launch attempts and triggers affirmation screen

#### BreakTheLoopView.swift
- Displays affirmation typing interface
- Validates user input against required affirmation
- Prevents dismissal until affirmation is completed
- Provides skip option (configurable)

#### DeviceActivityExtension.swift
- System-level extension for monitoring app usage
- Detects when gated apps are launched
- Triggers notification to main app

### 3. Setup Instructions

#### Step 1: Add DeviceActivity Extension Target

1. Open the project in Xcode
2. Go to File > New > Target
3. Select "Device Activity Report Extension"
4. Name it "DeviceActivityExtension"
5. Add the following files to the extension:
   - `DeviceActivityExtension.swift`
   - `Info.plist` (with proper extension configuration)

#### Step 2: Configure Info.plist

The main app's Info.plist should include:

```xml
<key>NSFamilyControlsUsageDescription</key>
<string>BreakLoop uses Family Controls to help you manage your app usage and build healthy digital habits.</string>
<key>NSUserActivityTypes</key>
<array>
    <string>DeviceActivityEvent</string>
</array>
```

#### Step 3: Extension Info.plist

The DeviceActivity extension's Info.plist should include:

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.deviceactivity.report</string>
    <key>NSExtensionPrincipalClass</key>
    <string>$(PRODUCT_MODULE_NAME).DeviceActivityExtension</string>
</dict>
```

#### Step 4: Build and Test

1. Build the project
2. Run on a physical device (DeviceActivity doesn't work in simulator)
3. Grant FamilyControls authorization when prompted
4. Select apps to gate
5. Try launching a gated app from the home screen

### 4. How It Works

#### App Launch Flow

1. **User launches gated app**: From home screen or other apps
2. **System blocks app**: ManagedSettingsStore prevents app from opening
3. **DeviceActivity detects**: Extension monitors app launch attempts
4. **BreakLoop opens**: Main app receives notification and shows affirmation screen
5. **User types affirmation**: Must match exactly to proceed
6. **App unlocks**: After successful affirmation, app opens normally

#### Affirmation Flow

1. **Random affirmation**: Selected from app's assigned themes
2. **Exact typing required**: Case-insensitive but must match exactly
3. **Error handling**: Shows error message for incorrect input
4. **Success feedback**: Visual confirmation before unlocking
5. **Skip option**: Available but can be disabled

### 5. Configuration Options

#### Disable Skip Button

In `BreakTheLoopView.swift`, modify the skip button visibility:

```swift
// Remove or comment out the skip button section
// if !hasCompletedAffirmation {
//     // Skip button code
// }
```

#### Custom Affirmations

Add custom affirmations in `AffirmationStore.swift`:

```swift
func getRandomAffirmationForApp(_ appName: String) -> String? {
    // Add app-specific affirmations here
    let appAffirmations = [
        "Instagram": [
            "I choose meaningful connections over endless scrolling.",
            "I am present in my real relationships."
        ],
        "TikTok": [
            "I value my time and attention.",
            "I choose content that enriches my life."
        ]
    ]
    
    return appAffirmations[appName]?.randomElement()
}
```

#### App URL Schemes

Add more apps to the URL schemes dictionary in `AppGatingManager.swift`:

```swift
let urlSchemes: [String: String] = [
    // Add more apps here
    "your-app": "your-app-scheme://"
]
```

### 6. Troubleshooting

#### Common Issues

1. **App not blocking**: Ensure FamilyControls authorization is granted
2. **Extension not working**: Check that DeviceActivity extension is properly configured
3. **Affirmation not showing**: Verify DeviceActivity monitoring is set up correctly
4. **App crashes**: Check for proper error handling in DeviceActivity callbacks

#### Debug Steps

1. Check console logs for DeviceActivity events
2. Verify ManagedSettingsStore shield configuration
3. Test on physical device (not simulator)
4. Ensure proper authorization flow

### 7. Privacy and Security

- All app gating is done locally on device
- No data is sent to external servers
- FamilyControls authorization is required
- User can remove apps from gating at any time

### 8. Future Enhancements

- **Time-based gating**: Allow apps only during certain hours
- **Usage tracking**: Monitor how long apps are used
- **Custom affirmations**: User-defined affirmations per app
- **Progress tracking**: Track affirmation completion rates
- **Multiple affirmations**: Require multiple affirmations for longer sessions

## Technical Requirements

- iOS 15.0+
- Xcode 14.0+
- Physical device for testing (DeviceActivity doesn't work in simulator)
- FamilyControls authorization
- DeviceActivity extension target

## License

This implementation is provided as-is for educational and development purposes. 
