import SwiftUI

struct AffirmationGateView: View {
    let appName: String
    let onAppUnlocked: () -> Void
    @EnvironmentObject var gatingManager: AppGatingManager
    @EnvironmentObject var affirmationStore: AffirmationStore
    
    @State private var userInput: String = ""
    @State private var hasCompletedAffirmation = false
    @State private var showError = false
    @State private var isSubmitting = false
    @State private var currentAffirmation: String = ""
    @State private var showRefreshButton = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.black, Color.purple.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                    
                    Text("Break the Loop")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Complete the affirmation to unlock \(appName)")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Affirmation Section
                VStack(spacing: 20) {
                    HStack {
                        Text("Repeat this affirmation:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        Spacer()
                        
                        // Refresh button
                        Button(action: refreshAffirmation) {
                            Image(systemName: "arrow.clockwise")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.7))
                        }
                        .disabled(hasCompletedAffirmation)
                    }
                    
                    Text(currentAffirmation)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white.opacity(0.1))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 12)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                                )
                        )
                    
                    Text("Type the affirmation exactly to continue:")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.7))
                }
                
                // Input Field
                VStack(spacing: 12) {
                    TextField("Type the affirmation here...", text: $userInput)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.body)
                        .padding(.horizontal)
                        .disabled(hasCompletedAffirmation)
                        .onChange(of: userInput) { _ in
                            showError = false
                        }
                    
                    if showError {
                        Text("Please type the affirmation exactly as shown")
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }
                }
                
                // Submit Button
                Button(action: submitAffirmation) {
                    HStack {
                        if isSubmitting {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title2)
                        }
                        
                        Text(hasCompletedAffirmation ? "Unlocking..." : "Submit Affirmation")
                            .fontWeight(.semibold)
                    }
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        hasCompletedAffirmation ? 
                        Color.green : 
                        (userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() == currentAffirmation.lowercased() ? Color.blue : Color.gray)
                    )
                    .cornerRadius(12)
                    .padding(.horizontal)
                    .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased() != currentAffirmation.lowercased() || hasCompletedAffirmation)
                }
                
                // Skip Button (only show if not completed)
                if !hasCompletedAffirmation {
                    Button("Skip for now") {
                        // Allow skipping but with a delay
                        withAnimation {
                            hasCompletedAffirmation = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            // Complete the affirmation - this will temporarily unlock apps
                            gatingManager.completeAffirmation()
                            
                            onAppUnlocked()
                        }
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .font(.subheadline)
                    .padding(.top, 8)
                }
                
                Spacer()
            }
            .padding(.top, 50)
        }
        .interactiveDismissDisabled()
        .onAppear {
            loadRandomAffirmation()
        }
    }
    
    private func loadRandomAffirmation() {
        // Get random affirmation from themes linked to this app
        if let affirmation = affirmationStore.getRandomAffirmationForApp(appName) {
            currentAffirmation = affirmation
        } else {
            // Fallback to general affirmations
            currentAffirmation = "I am mindful of my choices"
        }
        
        // Clear any previous input
        userInput = ""
        showError = false
    }
    
    private func refreshAffirmation() {
        withAnimation(.easeInOut(duration: 0.3)) {
            loadRandomAffirmation()
            userInput = ""
            showError = false
        }
    }
    
    private func submitAffirmation() {
        let trimmedInput = userInput.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedInput.lowercased() == currentAffirmation.lowercased() {
            withAnimation {
                hasCompletedAffirmation = true
                showError = false
                isSubmitting = true
            }
            
            // Simulate processing time
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                isSubmitting = false
                
                // Complete the affirmation - this will temporarily unlock apps
                gatingManager.completeAffirmation()
                
                onAppUnlocked()
            }
        } else {
            withAnimation {
                showError = true
            }
            
            // Clear error after 3 seconds
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                showError = false
            }
        }
    }
}

#Preview {
    AffirmationGateView(appName: "Instagram") {
        print("App unlocked!")
    }
    .environmentObject(AppGatingManager.shared)
    .environmentObject(AffirmationStore())
} 