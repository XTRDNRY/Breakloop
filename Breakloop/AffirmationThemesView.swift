import SwiftUI

struct AffirmationThemesView: View {
    @EnvironmentObject var store: AffirmationStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedThemes: Set<String> = []
    @State private var showingThemeDetail = false
    @State private var selectedThemeForDetail = ""
    
    let affirmationThemes = [
        ("📝", "My Affirmations", "My Affirmations"),
        ("🙏", "Trusting God", "Trusting God"),
        ("💼", "Work", "Work"),
        ("⚡", "Motivation", "Motivation"),
        ("💖", "Relationships", "Relationships"),
        ("💰", "Manifest Wealth", "Manifest Wealth"),
        ("🔥", "Push Through Failure", "Push Through Failure"),
        ("🌟", "Believe in Yourself", "Believe in Yourself")
    ]
    
    // For app-specific theme selection
    let appName: String?
    let onThemesSelected: (([String]) -> Void)?
    
    // Default initializer for general theme browsing
    init() {
        self.appName = nil
        self.onThemesSelected = nil
    }
    
    // Initializer for app-specific theme selection
    init(appName: String, onThemesSelected: @escaping ([String]) -> Void) {
        self.appName = appName
        self.onThemesSelected = onThemesSelected
    }
    
    var body: some View {
        ZStack {
            // Background
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
                        Text(appName != nil ? "Select Themes for \(appName!)" : "Affirmation Themes")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    if appName != nil {
                        VStack(spacing: 8) {
                            Text("Select 1-2 affirmation themes for \(appName!)")
                                .font(.body)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            if selectedThemes.count > 0 {
                                Text("\(selectedThemes.count) theme\(selectedThemes.count == 1 ? "" : "s") selected")
                                    .font(.caption)
                                    .foregroundColor(.green)
                                    .padding(.horizontal, 20)
                            }
                        }
                    } else {
                        Text("Choose your affirmation themes")
                            .font(.body)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 20)
                    }
                }
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // Categories Section
                        VStack(spacing: 16) {
                            HStack {
                                Text("Categories")
                                    .font(.title3.bold())
                                    .foregroundColor(.white)
                                Spacer()
                            }
                            .padding(.horizontal, 20)
                            
                            LazyVGrid(columns: [
                                GridItem(.flexible()),
                                GridItem(.flexible())
                            ], spacing: 16) {
                                ForEach(affirmationThemes, id: \.1) { theme in
                                    AffirmationThemeCard(
                                        emoji: theme.0,
                                        title: theme.1,
                                        store: store,
                                        isSelected: selectedThemes.contains(theme.2),
                                        action: {
                                            if appName != nil {
                                                // App-specific selection mode
                                                withAnimation(.easeInOut(duration: 0.2)) {
                                                    if selectedThemes.contains(theme.2) {
                                                        selectedThemes.remove(theme.2)
                                                    } else if selectedThemes.count < 2 {
                                                        selectedThemes.insert(theme.2)
                                                    }
                                                }
                                            } else {
                                                // General browsing mode - navigate to detail
                                                selectedThemeForDetail = theme.2
                                                showingThemeDetail = true
                                            }
                                        }
                                    )
                                }
                            }
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Space for bottom save button
                }
                
                // Save Button for app-specific selection
                if appName != nil {
                    VStack {
                        Button(action: {
                            saveAppThemes()
                        }) {
                            Text("Save Themes")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(
                                    selectedThemes.count >= 1 && selectedThemes.count <= 2 ?
                                    AnyShapeStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    ) :
                                    AnyShapeStyle(Color.gray)
                                )
                                .cornerRadius(16)
                                .shadow(color: selectedThemes.count >= 1 && selectedThemes.count <= 2 ? Color.green.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                        }
                        .disabled(selectedThemes.count < 1 || selectedThemes.count > 2)
                        .padding(.horizontal, 20)
                        .padding(.bottom, 20)
                    }
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.black.opacity(0.9),
                                Color.black.opacity(0.8)
                            ]),
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            if appName != nil {
                // Load existing themes for this app
                selectedThemes = Set(store.getThemesForApp(appName!))
            }
        }
        .fullScreenCover(isPresented: $showingThemeDetail) {
            ThemeDetailView(themeName: selectedThemeForDetail)
        }
    }
    
    private func saveAppThemes() {
        guard let appName = appName, let onThemesSelected = onThemesSelected else { return }
        
        // Validate selection before saving
        guard selectedThemes.count >= 1 && selectedThemes.count <= 2 else { return }
        
        // Save themes for this app
        store.setThemesForApp(appName, themes: Array(selectedThemes))
        
        // Call the completion handler
        onThemesSelected(Array(selectedThemes))
        
        // Dismiss the view
        dismiss()
    }
}

struct AffirmationThemeCard: View {
    let emoji: String
    let title: String
    let store: AffirmationStore
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 32))
                
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                    .minimumScaleFactor(0.8)
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.green)
                } else {
                    // Show count instead of checkmark
                    let count = getAffirmationCount(for: title)
                    Text("\(count)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.gray)
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
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        ) :
                        AnyShapeStyle(Color.purple.opacity(0.3)),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
            .shadow(color: isSelected ? Color.green.opacity(0.3) : Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private func getAffirmationCount(for theme: String) -> Int {
        if theme == "My Affirmations" {
            return store.customAffirmations.count
        } else {
            return store.affirmationsByTheme[theme]?.count ?? 0
        }
    }
}

#Preview {
    AffirmationThemesView()
        .environmentObject(AffirmationStore())
} 