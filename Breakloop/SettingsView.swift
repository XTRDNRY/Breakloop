import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var reminderMinutes: Double = 10.0
    @State private var showingAppThemeSettings = false
    
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
                VStack(spacing: 12) {
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
                        Text("Settings")
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                        Color.clear
                            .frame(width: 44, height: 44)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                }
                
                // Content
                ScrollView {
                    VStack(spacing: 24) {
                        // App Theme Settings Section
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "paintbrush.fill")
                                    .font(.title2)
                                    .foregroundColor(.purple)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("App Theme Settings")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Link themes to specific apps")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                                
                                Button(action: {
                                    showingAppThemeSettings = true
                                }) {
                                    Image(systemName: "chevron.right")
                                        .font(.title3)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()
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
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                        
                        // Reminder Section
                        VStack(spacing: 20) {
                            Text("Remind me again after:")
                                .font(.system(size: 18, weight: .medium))
                                .foregroundColor(.white)
                                .multilineTextAlignment(.center)
                            
                            // Minutes Display
                            Text("\(Int(reminderMinutes)) minutes")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.green)
                                .padding(.vertical, 8)
                            
                            // Slider
                            VStack(spacing: 16) {
                                Slider(
                                    value: $reminderMinutes,
                                    in: 5...20,
                                    step: 1
                                )
                                .accentColor(.green)
                                .padding(.horizontal, 20)
                                
                                // Min/Max labels
                                HStack {
                                    Text("5 min")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                    Spacer()
                                    Text("20 min")
                                        .font(.system(size: 12, weight: .medium))
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal, 20)
                            }
                            .padding(.vertical, 16)
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
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                        
                        // About Section
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "info.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.blue)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("About BreakLoop")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    
                                    Text("Version 1.0.0")
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                                
                                Spacer()
                            }
                            .padding()
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
                            .cornerRadius(16)
                            .padding(.horizontal, 20)
                        }
                    }
                    .padding(.top, 20)
                }
                
                // Save Button
                VStack {
                    Button(action: {
                        // Save the reminder setting
                        UserDefaults.standard.set(Int(reminderMinutes), forKey: "reminderMinutes")
                        dismiss()
                    }) {
                        Text("Save")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
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
        .sheet(isPresented: $showingAppThemeSettings) {
            AppThemeSettingsView()
        }
        .onAppear {
            // Load saved reminder setting
            let savedMinutes = UserDefaults.standard.integer(forKey: "reminderMinutes")
            if savedMinutes > 0 {
                reminderMinutes = Double(savedMinutes)
            }
        }
    }
}

#Preview {
    SettingsView()
} 