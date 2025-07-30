import SwiftUI
#if canImport(FamilyControls)
import FamilyControls
#endif
import ManagedSettings

struct AddAppSheet: View {
    @EnvironmentObject var store: AffirmationStore
    @EnvironmentObject var gatingManager: AppGatingManager
    @Environment(\.dismiss) var dismiss
    @State private var searchText = ""
    #if canImport(FamilyControls)
    @State private var selectedApps: Set<ApplicationToken> = []
    @State private var showFamilyActivityPicker = false
    @State private var activitySelection = FamilyActivitySelection()
    
    var filteredApps: [ApplicationToken] {
        let apps = Array(selectedApps)
        if searchText.isEmpty {
            return apps
        } else {
            // For now, return all apps since we can't get display names from ApplicationToken
            // In a real implementation, you would store display names separately
            return apps
        }
    }
    #else
    @State private var selectedApps: Set<Any> = []
    @State private var showFamilyActivityPicker = false
    @State private var activitySelection: Any = []
    
    var filteredApps: [Any] {
        return []
    }
    #endif
    
    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [
                    Color.black,
                    Color.black.opacity(0.95),
                    Color.purple.opacity(0.1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "xmark")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(.darkGray).opacity(0.8),
                                            Color(.darkGray).opacity(0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text("Add Apps")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            #if canImport(FamilyControls)
                            #if targetEnvironment(simulator)
                            print("FamilyControls not available in simulator - cannot add apps")
                            #else
                            for token in selectedApps {
                                // Get the app information from the token
                                // Create blocked app with token and placeholder info
                                // In a real implementation, you'd get the app info from the token
                                let blockedApp = BlockedApp(
                                    token: token,
                                    displayName: "Selected App", // This would be the actual app name
                                    bundleIdentifier: "com.app.selected" // This would be the actual bundle ID
                                )
                                // Add to the gating manager
                                gatingManager.addBlockedApp(blockedApp)
                            }
                            #endif
                            #else
                            print("FamilyControls not available - cannot add apps")
                            #endif
                            dismiss()
                        }) {
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedApps.isEmpty ?
                                    AnyShapeStyle(Color.gray) :
                                    AnyShapeStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.purple, Color.blue]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .disabled(selectedApps.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 16, weight: .medium))
                        TextField("Search apps...", text: $searchText)
                            .foregroundColor(.white)
                            .font(.body)
                            .accentColor(.purple)
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.darkGray).opacity(0.9),
                                Color(.darkGray).opacity(0.7)
                            ]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                }
                // Add Apps Button
                Button(action: {
                    showFamilyActivityPicker = true
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.purple)
                        Text("Add Apps from Device")
                            .font(.headline)
                            .foregroundColor(.white)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                // Apps grid
                if filteredApps.isEmpty {
                    Spacer()
                    Text("No apps selected. Tap 'Add Apps from Device' to choose.")
                        .foregroundColor(.gray)
                        .padding()
                    Spacer()
                } else {
                    ScrollView {
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible())
                        ], spacing: 16) {
                            ForEach(filteredApps, id: \.self) { token in
                                AppCard(
                                    appName: "Selected App", // This would be the actual app name
                                    isSelected: true,
                                    action: {
                                        selectedApps.remove(token)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 100)
                    }
                }
            }
        }
        .navigationBarHidden(true)
        #if canImport(FamilyControls)
        .familyActivityPicker(isPresented: $showFamilyActivityPicker, selection: $activitySelection)
        .onChange(of: activitySelection) { newSelection in
            // Update selectedApps with the apps from the picker
            selectedApps = newSelection.applicationTokens
        }
        #endif
    }
}

// AppCard remains unchanged, using SF Symbols as icons
struct AppCard: View {
    let appName: String
    let isSelected: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: "app")
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(.white)
                    .frame(width: 48, height: 48)
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.purple.opacity(0.3),
                                Color.blue.opacity(0.3)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(Circle())
                Text(appName)
                    .font(.body.weight(.medium))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                }
            }
            .frame(height: 120)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        Color(.darkGray).opacity(isSelected ? 0.9 : 0.7),
                        Color(.darkGray).opacity(isSelected ? 0.8 : 0.6)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(
                        isSelected ?
                        AnyShapeStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        ) :
                        AnyShapeStyle(Color.clear),
                        lineWidth: 2
                    )
            )
            .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    AddAppSheet()
        .environmentObject(AffirmationStore())
} 