import SwiftUI
import FamilyControls
import LocalAuthentication
import UserNotifications

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var isScreenTimeEnabled = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        ZStack {
            // Background
            Color.black.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // Welcome Text
                VStack(spacing: 16) {
                    Text("Welcome to BreakLoop")
                        .font(.largeTitle.bold())
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("Block distractions. Stay focused. Unlock your power.")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                
                // Screen Time Permission Section
                VStack(spacing: 24) {
                    HStack(spacing: 16) {
                        Image(systemName: "timer")
                            .font(.system(size: 24, weight: .medium))
                            .foregroundColor(.purple)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Enable Screen Time")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Text("Required for app gating")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        
                        Spacer()
                        
                        Toggle("", isOn: $isScreenTimeEnabled)
                            .toggleStyle(SwitchToggleStyle(tint: .purple))
                            .onChange(of: isScreenTimeEnabled) { newValue in
                                if newValue {
                                    requestScreenTimePermission()
                                }
                            }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 16)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(.darkGray).opacity(0.3))
                    )
                    .padding(.horizontal, 24)
                    
                    if showError {
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.red)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color.red.opacity(0.1))
                            )
                            .padding(.horizontal, 24)
                    }
                }
                
                Spacer()
                
                // Continue Button
                Button(action: {
                    if isScreenTimeEnabled {
                        hasCompletedOnboarding = true
                    } else {
                        showError = true
                        errorMessage = "You must enable Screen Time for BreakLoop to work properly."
                        
                        // Hide error after 3 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                            withAnimation {
                                showError = false
                            }
                        }
                    }
                }) {
                    Text("Continue")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            isScreenTimeEnabled ?
                            LinearGradient(
                                gradient: Gradient(colors: [Color.purple, Color.blue]),
                                startPoint: .leading,
                                endPoint: .trailing
                            ) :
                            LinearGradient(
                                gradient: Gradient(colors: [Color.gray, Color.gray.opacity(0.8)]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(16)
                        .shadow(color: isScreenTimeEnabled ? Color.purple.opacity(0.3) : Color.clear, radius: 8, x: 0, y: 4)
                }
                .disabled(!isScreenTimeEnabled)
                .padding(.horizontal, 24)
                .padding(.bottom, 40)
            }
        }
        .navigationBarHidden(true)
    }
    
    private func requestScreenTimePermission() {
        Task {
            do {
                try await AuthorizationCenter.shared.requestAuthorization(for: .individual)
                DispatchQueue.main.async {
                    isScreenTimeEnabled = true
                    withAnimation { showError = false }
                }
            } catch {
                DispatchQueue.main.async {
                    isScreenTimeEnabled = false
                    errorMessage = "Screen Time permission denied. Please enable it in Settings."
                    withAnimation { showError = true }
                    
                    // Hide error after 4 seconds
                    DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
                        withAnimation { showError = false }
                    }
                }
            }
        }
    }
}

#Preview {
    OnboardingView(hasCompletedOnboarding: .constant(false))
} 