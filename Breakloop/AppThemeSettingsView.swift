import SwiftUI

struct AppThemeSettingsView: View {
    @EnvironmentObject var affirmationStore: AffirmationStore
    @State private var selectedApp: String = ""
    @State private var showingAppPicker = false
    
    private let availableApps = [
        "Instagram", "TikTok", "YouTube", "Facebook", "WhatsApp", 
        "Twitter", "Netflix", "Spotify", "Snapchat", "Reddit",
        "Discord", "Telegram", "LinkedIn", "Pinterest", "Twitch"
    ]
    
    private var availableThemes: [String] {
        return Array(affirmationStore.affirmationsByTheme.keys).sorted()
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "paintbrush.fill")
                        .font(.system(size: 50))
                        .foregroundColor(.purple)
                    
                    Text("App Theme Settings")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("Link specific themes to apps for personalized affirmations")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.top)
                
                // App Selection
                VStack(alignment: .leading, spacing: 8) {
                    Text("Select App")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Button(action: {
                        showingAppPicker = true
                    }) {
                        HStack {
                            Text(selectedApp.isEmpty ? "Choose an app..." : selectedApp)
                                .foregroundColor(selectedApp.isEmpty ? .secondary : .primary)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(10)
                        .padding(.horizontal)
                    }
                }
                
                // Theme Selection for Selected App
                if !selectedApp.isEmpty {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Themes for \(selectedApp)")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        let appThemes = affirmationStore.getThemesForApp(selectedApp)
                        
                        if appThemes.isEmpty {
                            Text("No themes selected. This app will use general affirmations.")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding(.horizontal)
                        } else {
                            ForEach(appThemes, id: \.self) { theme in
                                HStack {
                                    Text(theme)
                                        .font(.subheadline)
                                    Spacer()
                                    Button("Remove") {
                                        removeThemeFromApp(theme)
                                    }
                                    .foregroundColor(.red)
                                    .font(.caption)
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 8)
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }
                        }
                        
                        // Add Theme Button
                        Button("Add Theme") {
                            showingThemePicker = true
                        }
                        .buttonStyle(.borderedProminent)
                        .padding(.horizontal)
                    }
                }
                
                Spacer()
            }
            .navigationTitle("App Themes")
            .navigationBarTitleDisplayMode(.inline)
        }
        .sheet(isPresented: $showingAppPicker) {
            AppPickerSheet(selectedApp: $selectedApp, availableApps: availableApps)
        }
        .sheet(isPresented: $showingThemePicker) {
            ThemePickerSheet(
                selectedThemes: Binding(
                    get: { Set(affirmationStore.getThemesForApp(selectedApp)) },
                    set: { newThemes in
                        affirmationStore.setThemesForApp(selectedApp, themes: Array(newThemes))
                    }
                ),
                availableThemes: availableThemes
            )
        }
    }
    
    @State private var showingThemePicker = false
    
    private func removeThemeFromApp(_ theme: String) {
        var currentThemes = affirmationStore.getThemesForApp(selectedApp)
        currentThemes.removeAll { $0 == theme }
        affirmationStore.setThemesForApp(selectedApp, themes: currentThemes)
    }
}

struct AppPickerSheet: View {
    @Binding var selectedApp: String
    let availableApps: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(availableApps, id: \.self) { app in
                Button(action: {
                    selectedApp = app
                    dismiss()
                }) {
                    HStack {
                        Text(app)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedApp == app {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select App")
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

struct ThemePickerSheet: View {
    @Binding var selectedThemes: Set<String>
    let availableThemes: [String]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            List(availableThemes, id: \.self) { theme in
                Button(action: {
                    if selectedThemes.contains(theme) {
                        selectedThemes.remove(theme)
                    } else {
                        selectedThemes.insert(theme)
                    }
                }) {
                    HStack {
                        Text(theme)
                            .foregroundColor(.primary)
                        Spacer()
                        if selectedThemes.contains(theme) {
                            Image(systemName: "checkmark")
                                .foregroundColor(.blue)
                        }
                    }
                }
            }
            .navigationTitle("Select Themes")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    AppThemeSettingsView()
        .environmentObject(AffirmationStore())
} 