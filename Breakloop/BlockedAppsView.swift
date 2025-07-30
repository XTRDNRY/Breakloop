import SwiftUI

struct BlockedAppsView: View {
    @EnvironmentObject var gatingManager: AppGatingManager
    @State private var showingAppPicker = false
    
    var body: some View {
        NavigationView {
            VStack {
                if gatingManager.blockedApps.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "lock.shield")
                            .font(.system(size: 60))
                            .foregroundColor(.orange)
                        
                        Text("No Apps Blocked")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("Add apps to block them from being accessed until you complete an affirmation.")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                        
                        Button("Add App to Block") {
                            showingAppPicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        
                        // Test button for development
                        Button("Add Test App (Instagram)") {
                            addTestApp()
                        }
                        .buttonStyle(.bordered)
                        .foregroundColor(.blue)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(gatingManager.blockedApps, id: \.bundleIdentifier) { blockedApp in
                            BlockedAppRow(blockedApp: blockedApp)
                        }
                        .onDelete(perform: deleteBlockedApps)
                    }
                    .navigationTitle("Blocked Apps")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Add") {
                                showingAppPicker = true
                            }
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showingAppPicker) {
            AppPickerView { tokens in
                handleAppSelection(tokens)
            }
        }
    }
    
    // Test function to add a blocked app for testing
    private func addTestApp() {
        // Create a test app for simulator/development
        #if canImport(FamilyControls)
        // In simulator, we can't create real ApplicationTokens, so we'll skip this
        print("Cannot create test app in simulator - FamilyControls not available")
        #else
        let testApp = BlockedApp(
            token: "mock_token" as Any,
            displayName: "Instagram",
            bundleIdentifier: "com.instagram.ios"
        )
        gatingManager.addBlockedApp(testApp)
        print("Added test app: Instagram")
        #endif
    }
    
    // Handle app selection from FamilyActivityPicker
    private func handleAppSelection(_ tokens: Any) {
        // For now, just add a test app since FamilyControls is complex
        addTestApp()
    }
    
    private func deleteBlockedApps(offsets: IndexSet) {
        for index in offsets {
            let blockedApp = gatingManager.blockedApps[index]
            gatingManager.removeBlockedApp(blockedApp)
        }
    }
}

struct BlockedAppRow: View {
    let blockedApp: BlockedApp
    
    var body: some View {
        HStack {
            Image(systemName: "app.badge")
                .foregroundColor(.red)
                .font(.title2)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(blockedApp.displayName)
                    .font(.headline)
                
                Text(blockedApp.bundleIdentifier)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: "lock.fill")
                .foregroundColor(.orange)
        }
        .padding(.vertical, 4)
    }
}

struct AppPickerView: View {
    @Environment(\.dismiss) private var dismiss
    let onSelection: (Any) -> Void
    
    var body: some View {
        NavigationView {
            VStack {
                Text("Select Apps to Block")
                    .font(.title2)
                    .padding()
                
                VStack {
                    Text("FamilyControls not available in simulator")
                        .foregroundColor(.secondary)
                    Button("Add Test App") {
                        onSelection([])
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding()
            }
            .navigationTitle("Select Apps")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    BlockedAppsView()
        .environmentObject(AppGatingManager.shared)
} 