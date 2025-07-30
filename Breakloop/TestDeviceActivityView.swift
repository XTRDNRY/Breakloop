import SwiftUI
import FamilyControls
import DeviceActivity

struct TestDeviceActivityView: View {
    @EnvironmentObject var gatingManager: AppGatingManager
    @State private var showingFamilyActivityPicker = false
    @State private var selectedApps: FamilyActivitySelection = FamilyActivitySelection()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 10) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.purple)
                    
                    Text("DeviceActivity Test")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Test the new DeviceActivity-based app gating")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding()
                
                // Status Section
                VStack(spacing: 15) {
                    Text("Current Status")
                        .font(.headline)
                    
                    VStack(spacing: 8) {
                        HStack {
                            Text("Blocked Apps:")
                            Spacer()
                            Text("\(gatingManager.blockedApps.count)")
                                .fontWeight(.semibold)
                        }
                        
                        HStack {
                            Text("DeviceActivity Active:")
                            Spacer()
                            Text(gatingManager.currentActivity != nil ? "Yes" : "No")
                                .fontWeight(.semibold)
                                .foregroundColor(gatingManager.currentActivity != nil ? .green : .red)
                        }
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                
                // Action Buttons
                VStack(spacing: 15) {
                    Button("Select Apps to Block") {
                        showingFamilyActivityPicker = true
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    
                    Button("Apply DeviceActivity Blocking") {
                        gatingManager.applyAppBlocking()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(gatingManager.blockedApps.isEmpty)
                    
                    Button("Remove All Blocking") {
                        gatingManager.removeAppBlocking()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .foregroundColor(.red)
                    
                    Button("Test Affirmation Gate") {
                        gatingManager.testAffirmationGate()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .disabled(gatingManager.blockedApps.isEmpty)
                }
                
                // Instructions
                VStack(alignment: .leading, spacing: 10) {
                    Text("How to Test:")
                        .font(.headline)
                    
                    VStack(alignment: .leading, spacing: 5) {
                        Text("1. Select apps using FamilyActivityPicker")
                        Text("2. Apply DeviceActivity blocking")
                        Text("3. Try to open a blocked app")
                        Text("4. You should see AffirmationGateView instead of Apple's red screen")
                    }
                    .font(.caption)
                    .foregroundColor(.secondary)
                }
                .padding()
                .background(Color.blue.opacity(0.1))
                .cornerRadius(10)
                
                Spacer()
            }
            .padding()
            .navigationTitle("DeviceActivity Test")
            .navigationBarTitleDisplayMode(.inline)
        }
        .familyActivityPicker(isPresented: $showingFamilyActivityPicker, selection: $selectedApps)
        .onChange(of: selectedApps) { newSelection in
            // Convert selected apps to BlockedApp objects
            for token in newSelection.applicationTokens {
                let blockedApp = BlockedApp(
                    token: token,
                    displayName: "Selected App", // You'll need to get the actual name
                    bundleIdentifier: "com.example.app" // You'll need to get the actual bundle ID
                )
                gatingManager.addBlockedApp(blockedApp)
            }
        }
    }
}

#Preview {
    TestDeviceActivityView()
        .environmentObject(AppGatingManager.shared)
} 