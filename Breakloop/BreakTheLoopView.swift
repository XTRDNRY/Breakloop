import SwiftUI

struct BreakTheLoopView: View {
    let appName: String
    let onAppUnlocked: () -> Void
    
    @State private var userInput: String = ""
    @State private var hasCompletedAffirmation = false
    @State private var showError = false
    @State private var isSubmitting = false
    @State private var currentAffirmation: String = ""
    @EnvironmentObject var gatingManager: AppGatingManager
    @EnvironmentObject var affirmationStore: AffirmationStore
    
    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "lock.shield")
                        .font(.system(size: 60))
                        .foregroundColor(.white)
                    
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
                    Text("Repeat this affirmation:")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text(currentAffirmation)
                        .font(.title2)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("Type the affirmation to continue:")
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
                            onAppUnlocked()
                        }
                    }
                    .foregroundColor(.white.opacity(0.6))
                    .font(.subheadline)
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
    BreakTheLoopView(appName: "Instagram") {
        print("App unlocked!")
    }
    .environmentObject(AppGatingManager.shared)
    .environmentObject(AffirmationStore())
} 