import SwiftUI

struct ThemeSelectorView: View {
    @EnvironmentObject var store: AffirmationStore
    @Environment(\.dismiss) var dismiss
    @State private var selectedThemes: Set<String> = []
    let appName: String
    
    let availableThemes = [
        ("🧠", "Focus", "Focus"),
        ("💪", "Motivation", "Motivation"),
        ("😌", "Calm", "Calm"),
        ("🎯", "Goals", "Goals"),
        ("🌟", "Confidence", "Confidence"),
        ("❤️", "Self-Love", "Self-Love"),
        ("🌱", "Growth", "Growth"),
        ("✨", "Gratitude", "Gratitude")
    ]
    
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
                        Text("Choose Themes")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Button(action: {
                            saveThemes()
                        }) {
                            Text("Save")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    selectedThemes.isEmpty ?
                                    AnyShapeStyle(Color.gray) :
                                    AnyShapeStyle(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                )
                                .cornerRadius(12)
                        }
                        .disabled(selectedThemes.isEmpty)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Text("Select affirmation themes for \(appName)")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Themes Grid
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible()),
                        GridItem(.flexible())
                    ], spacing: 16) {
                        ForEach(availableThemes, id: \.1) { theme in
                            ThemeCard(
                                emoji: theme.0,
                                title: theme.1,
                                isSelected: selectedThemes.contains(theme.2),
                                action: {
                                    if selectedThemes.contains(theme.2) {
                                        selectedThemes.remove(theme.2)
                                    } else {
                                        selectedThemes.insert(theme.2)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                }
                
                // Save Button
                VStack {
                    Button(action: {
                        saveThemes()
                    }) {
                        Text("Save Themes")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                selectedThemes.isEmpty ?
                                AnyShapeStyle(Color.gray) :
                                AnyShapeStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(selectedThemes.isEmpty)
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
        .navigationBarHidden(true)
    }
    
    private func saveThemes() {
        // Save selected themes for this app
        var appThemes = UserDefaults.standard.dictionary(forKey: "appThemes") as? [String: [String]] ?? [:]
        appThemes[appName] = Array(selectedThemes)
        UserDefaults.standard.set(appThemes, forKey: "appThemes")
        
        dismiss()
    }
}

struct ThemeCard: View {
    let emoji: String
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Text(emoji)
                    .font(.system(size: 32))
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
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
                                gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        ) :
                        AnyShapeStyle(Color.clear),
                        lineWidth: 2
                    )
            )
            .shadow(color: isSelected ? Color.green.opacity(0.3) : Color.purple.opacity(0.3), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    ThemeSelectorView(appName: "Instagram")
        .environmentObject(AffirmationStore())
} 