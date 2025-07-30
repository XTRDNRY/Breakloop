import SwiftUI
import FamilyControls
import DeviceActivity
import ManagedSettings

struct HomeView: View {
    @EnvironmentObject var store: AffirmationStore
    @EnvironmentObject var gatingManager: AppGatingManager
    @State private var showFamilyActivityPicker = false
    @State private var activitySelection = FamilyActivitySelection()
    @State private var showThemeSelector = false
    @State private var appForThemeSelection = ""
    @State private var showAffirmationThemes = false
    @State private var showBreakLoopView = false
    @State private var selectedAppForBreakLoop = ""
    @State private var showSettings = false
    @State private var currentAffirmationIndex = 0
    @State private var fadeOpacity: Double = 1.0
    
    let affirmations = [
        "I attract positivity and abundance.",
        "I am capable of achieving great things.",
        "Every day I grow stronger and wiser.",
        "I choose to focus on what matters most.",
        "I am in control of my digital habits.",
        "My potential is limitless.",
        "I create healthy boundaries with technology.",
        "I am present and mindful in all I do.",
        "I am worthy of success and happiness.",
        "I embrace challenges as opportunities for growth."
    ]

    var body: some View {
            ZStack {
            // Background with gradient
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
                // Top Bar
                HStack {
                    Spacer()
                    
                    Button(action: {
                        showSettings = true
                    }) {
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.purple.opacity(0.3), Color.blue.opacity(0.3)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)
                .padding(.bottom, 20)
                
                // Affirmations Button - Made larger and more prominent
                Button(action: {
                    showAffirmationThemes = true
                }) {
                    Text("Affirmations")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 32)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(18)
                        .shadow(color: Color.purple.opacity(0.4), radius: 10, x: 0, y: 5)
                }
                .padding(.bottom, 24)
                
                // Test Button for Development
                Button(action: {
                    // Navigate to test view
                    // For now, just test the affirmation gate
                    gatingManager.testAffirmationGate()
                }) {
                    Text("Test App Gating")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [Color.orange, Color.red]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                }
                .padding(.bottom, 16)
                
                // Daily Affirmation Card
                VStack(spacing: 12) {
                    Text(affirmations[currentAffirmationIndex])
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .italic()
                        .opacity(fadeOpacity)
                        .animation(.easeInOut(duration: 0.5), value: fadeOpacity)
                    
                    Text("Daily Affirmation")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .opacity(fadeOpacity)
                        .animation(.easeInOut(duration: 0.5), value: fadeOpacity)
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 32)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.blue.opacity(0.3),
                            Color.purple.opacity(0.3),
                            Color.blue.opacity(0.2)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(20)
                .shadow(color: Color.purple.opacity(0.4), radius: 12, x: 0, y: 6)
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                
                // Gated Apps Section - Square layout
                VStack(spacing: 0) {
                    // Section Title
        HStack {
                        Text("Gated Apps")
                            .font(.system(size: 24, weight: .bold))
                .foregroundColor(.white)
            Spacer()
        }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                    
                    // Gated Apps Container - Square layout
                    VStack(spacing: 0) {
                        if store.blockedApps.isEmpty {
                            // Empty State with enlarged Add App button
                            VStack(spacing: 30) {
                                Text("No gated apps yet.")
                                    .font(.system(size: 18, weight: .medium))
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                
                                // Enlarged Add App Button with bigger tap area
                                Button(action: {
                                    showFamilyActivityPicker = true
                                }) {
                                    VStack(spacing: 12) {
                                        Image(systemName: "plus")
                                            .font(.system(size: 24, weight: .bold))
                                            .foregroundColor(.white)
                                        
                                        Text("Add App")
                                            .font(.system(size: 18, weight: .bold))
                                            .foregroundColor(.white)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 24)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.purple, Color.blue]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .padding(.horizontal, 40)
                            }
                            .padding(.vertical, 60)
                        } else {
                            // Apps Grid - Square layout with scrollable content
                            ScrollView {
                                LazyVGrid(columns: [
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible()),
                                    GridItem(.flexible())
                                ], spacing: 20) {
                                    ForEach(store.blockedApps, id: \.self) { app in
                                        AppIconCard(
                                            appName: app,
                                            onTap: {
                                                // When tapped from inside BreakLoop, show theme selection
                                                selectedAppForBreakLoop = app
                                                showThemeSelector = true
                                            },
                                            onRemove: {
                                                store.removeBlockedApp(app)
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.vertical, 30)
                            }
                            .frame(maxHeight: 300) // Limit height for scrollable area
                            
                            // Enlarged Add App Button with bigger tap area
                            Button(action: {
                                showFamilyActivityPicker = true
                            }) {
                                VStack(spacing: 8) {
                                    Image(systemName: "plus")
                                        .font(.system(size: 18, weight: .bold))
                                        .foregroundColor(.white)
                                    
                                    Text("Add More")
                                        .font(.system(size: 16, weight: .bold))
                                        .foregroundColor(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(12)
                                .shadow(color: Color.green.opacity(0.3), radius: 6, x: 0, y: 3)
                            }
                            .padding(.horizontal, 40)
                            .padding(.bottom, 20)
                        }
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color(.darkGray).opacity(0.8),
                                Color(.darkGray).opacity(0.6)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(16)
                    .padding(.horizontal, 24)
                }
                .frame(width: UIScreen.main.bounds.width - 48, height: UIScreen.main.bounds.width - 48) // Square layout
            }
        }
        .onAppear {
            startAffirmationTimer()
        }
        .familyActivityPicker(isPresented: $showFamilyActivityPicker, selection: $activitySelection)
        .onChange(of: activitySelection) { newSelection in
            // Add selected apps to the store and gating manager
            #if canImport(FamilyControls)
            for token in newSelection.applicationTokens {
                if let app = try? Application(token: token) {
                    // Improved app name extraction
                    let appName = getAppDisplayName(app)
                    if !store.blockedApps.contains(appName) {
                        // Add to AffirmationStore
                        store.addBlockedApp(appName)
                        
                        // Add to AppGatingManager for actual gating
                        // Note: This method doesn't exist in current AppGatingManager
                        // gatingManager.addGatedAppToken(appName, token: token)
                        
                        // Immediately show theme selection for this app
                        appForThemeSelection = appName
                        showThemeSelector = true
                    }
                }
            }
            #else
            print("FamilyControls not available - cannot process selected apps")
            #endif
        }
        .sheet(isPresented: $showThemeSelector) {
            AffirmationThemesView(appName: selectedAppForBreakLoop.isEmpty ? appForThemeSelection : selectedAppForBreakLoop) { selectedThemes in
                // Themes have been selected and saved
                print("Selected themes for \(selectedAppForBreakLoop.isEmpty ? appForThemeSelection : selectedAppForBreakLoop): \(selectedThemes)")
                selectedAppForBreakLoop = "" // Reset for next use
            }
        }
        .fullScreenCover(isPresented: $showAffirmationThemes) {
            AffirmationThemesView()
        }
        .fullScreenCover(isPresented: $showBreakLoopView) {
            BreakTheLoopView(appName: selectedAppForBreakLoop) {
                // App unlocked callback
                showBreakLoopView = false
            }
        }
        .fullScreenCover(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // Enhanced app name extraction function with better fallbacks
    private func getAppDisplayName(_ app: Application) -> String {
        // Try to get the localized display name first
        if let displayName = app.localizedDisplayName, !displayName.isEmpty {
            return displayName
        }
        
        // Fallback to bundle identifier if display name is not available
        if let bundleId = app.bundleIdentifier, !bundleId.isEmpty {
            // Extract app name from bundle identifier (e.g., "com.apple.Maps" -> "Maps")
            let components = bundleId.components(separatedBy: ".")
            if let lastComponent = components.last {
                // Clean up the component name
                let cleanName = lastComponent
                    .replacingOccurrences(of: "App", with: "")
                    .replacingOccurrences(of: "app", with: "")
                    .replacingOccurrences(of: "ios", with: "")
                    .replacingOccurrences(of: "iOS", with: "")
                    .replacingOccurrences(of: "Client", with: "")
                    .replacingOccurrences(of: "client", with: "")
                    .replacingOccurrences(of: "Mobile", with: "")
                    .replacingOccurrences(of: "mobile", with: "")
                
                // Capitalize first letter
                return cleanName.prefix(1).uppercased() + cleanName.dropFirst()
            }
            return bundleId
        }
        
        // Final fallback
        return "Unknown App"
    }
    
    // Helper function to get app icon
    private func iconForApp(_ app: String) -> String? {
        switch app.lowercased() {
        case "instagram": return "camera"
        case "tiktok": return "music.note"
        case "youtube": return "play.rectangle"
        case "twitter": return "bird"
        case "facebook": return "f.square"
        case "snapchat": return "camera.viewfinder"
        case "maps": return "map"
        case "messages": return "message"
        case "mail": return "envelope"
        case "photos": return "photo"
        case "camera": return "camera"
        case "settings": return "gearshape"
        case "safari": return "globe"
        case "app store": return "bag"
        case "music": return "music.note"
        case "phone": return "phone"
        case "facetime": return "video"
        case "calendar": return "calendar"
        case "notes": return "note.text"
        case "weather": return "cloud.sun"
        case "spotify": return "music.note"
        case "netflix": return "play.rectangle"
        case "whatsapp": return "message"
        case "telegram": return "message"
        case "discord": return "message"
        case "reddit": return "globe"
        case "linkedin": return "person.2"
        case "pinterest": return "pin"
        case "tumblr": return "text.quote"
        case "twitch": return "video"
        case "zoom": return "video"
        case "teams": return "person.3"
        case "slack": return "message"
        case "notion": return "doc.text"
        case "trello": return "list.bullet"
        case "asana": return "checklist"
        case "figma": return "paintbrush"
        case "canva": return "paintbrush"
        case "dropbox": return "folder"
        case "google drive": return "folder"
        case "onedrive": return "folder"
        case "icloud": return "cloud"
        case "find my": return "location"
        case "health": return "heart"
        case "wallet": return "creditcard"
        case "home": return "house"
        case "shortcuts": return "bolt"
        case "files": return "folder"
        case "calculator": return "plus.forwardslash.minus"
        case "clock": return "clock"
        case "voice memos": return "mic"
        case "translate": return "character.bubble"
        case "measure": return "ruler"
        case "compass": return "location.north"
        case "stocks": return "chart.line.uptrend.xyaxis"
        case "books": return "book"
        case "podcasts": return "mic"
        case "tv": return "tv"
        case "arcade": return "gamecontroller"
        case "tips": return "lightbulb"
        case "feedback": return "envelope"
        default: return nil
        }
    }
    
    // Timer to change affirmations every 5 seconds
    private func startAffirmationTimer() {
        Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            withAnimation(.easeInOut(duration: 0.5)) {
                fadeOpacity = 0.0
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                currentAffirmationIndex = (currentAffirmationIndex + 1) % affirmations.count
                withAnimation(.easeInOut(duration: 0.5)) {
                    fadeOpacity = 1.0
                }
            }
        }
    }
}

struct AppIconCard: View {
    let appName: String
    let onTap: () -> Void
    let onRemove: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            Button(action: onTap) {
                VStack(spacing: 8) {
                    // App Icon with fallback to styled placeholder
                    if let iconName = iconForApp(appName), iconName != "app" {
                        Image(systemName: iconName)
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.purple.opacity(0.6),
                                        Color.blue.opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    } else {
                        // Styled placeholder with first letter
                        Text(String(appName.prefix(1)).uppercased())
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(width: 40, height: 40)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color.purple.opacity(0.6),
                                        Color.blue.opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    }
                    
                    Text(appName)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .minimumScaleFactor(0.8)
                }
            }
            .buttonStyle(PlainButtonStyle())
            
            // Remove button
            Button(action: onRemove) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.red)
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 4)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(.darkGray).opacity(0.7),
                    Color(.darkGray).opacity(0.5)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
    }
    
    private func iconForApp(_ app: String) -> String? {
        switch app.lowercased() {
        case "instagram": return "camera"
        case "tiktok": return "music.note"
        case "youtube": return "play.rectangle"
        case "twitter": return "bird"
        case "facebook": return "f.square"
        case "snapchat": return "camera.viewfinder"
        case "maps": return "map"
        case "messages": return "message"
        case "mail": return "envelope"
        case "photos": return "photo"
        case "camera": return "camera"
        case "settings": return "gearshape"
        case "safari": return "globe"
        case "app store": return "bag"
        case "music": return "music.note"
        case "phone": return "phone"
        case "facetime": return "video"
        case "calendar": return "calendar"
        case "notes": return "note.text"
        case "weather": return "cloud.sun"
        case "spotify": return "music.note"
        case "netflix": return "play.rectangle"
        case "whatsapp": return "message"
        case "telegram": return "message"
        case "discord": return "message"
        case "reddit": return "globe"
        case "linkedin": return "person.2"
        case "pinterest": return "pin"
        case "tumblr": return "text.quote"
        case "twitch": return "video"
        case "zoom": return "video"
        case "teams": return "person.3"
        case "slack": return "message"
        case "notion": return "doc.text"
        case "trello": return "list.bullet"
        case "asana": return "checklist"
        case "figma": return "paintbrush"
        case "canva": return "paintbrush"
        case "dropbox": return "folder"
        case "google drive": return "folder"
        case "onedrive": return "folder"
        case "icloud": return "cloud"
        case "find my": return "location"
        case "health": return "heart"
        case "wallet": return "creditcard"
        case "home": return "house"
        case "shortcuts": return "bolt"
        case "files": return "folder"
        case "calculator": return "plus.forwardslash.minus"
        case "clock": return "clock"
        case "voice memos": return "mic"
        case "translate": return "character.bubble"
        case "measure": return "ruler"
        case "compass": return "location.north"
        case "stocks": return "chart.line.uptrend.xyaxis"
        case "books": return "book"
        case "podcasts": return "mic"
        case "tv": return "tv"
        case "arcade": return "gamecontroller"
        case "tips": return "lightbulb"
        case "feedback": return "envelope"
        default: return nil
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AffirmationStore())
        .environmentObject(AppGatingManager.shared)
} 