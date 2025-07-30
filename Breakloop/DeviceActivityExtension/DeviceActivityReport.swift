import DeviceActivity
import SwiftUI

struct DeviceActivityReport: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: DeviceActivityReportAttributes.self) { context in
            // This is the widget that appears on the lock screen
            VStack {
                Text("Break the Loop")
                    .font(.headline)
                Text("Complete your affirmation to unlock apps")
                    .font(.caption)
            }
            .padding()
        } dynamicIsland: { context in
            // This is the Dynamic Island content
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Text("Break the Loop")
                        .font(.headline)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Complete affirmation")
                        .font(.caption)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Tap to open and complete your affirmation")
                        .font(.caption)
                }
            } compactLeading: {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.red)
            } compactTrailing: {
                Text("BreakLoop")
                    .font(.caption2)
            } minimal: {
                Image(systemName: "lock.shield.fill")
                    .foregroundColor(.red)
            }
        }
    }
}

struct DeviceActivityReportAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var isActive: Bool
    }
} 