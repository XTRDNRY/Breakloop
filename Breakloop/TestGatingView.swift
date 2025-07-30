import SwiftUI

struct TestGatingView: View {
    @EnvironmentObject var gatingManager: AppGatingManager
    @EnvironmentObject var store: AffirmationStore
    @State private var testAppName = "Instagram"
    
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
            
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Image(systemName: "testtube.2")
                        .font(.system(size: 70))
                        .foregroundColor(.white)
                        .shadow(color: .purple.opacity(0.5), radius: 10)
                    
                    Text("Test App Gating")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Test the affirmation gate functionality")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                
                // Test Controls
                VStack(spacing: 20) {
                    // Test App Name Input
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Test App Name:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        TextField("Enter app name", text: $testAppName)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding(.horizontal)
                    }
                    
                    // Test Buttons
                    VStack(spacing: 12) {
                                                Button(action: {
                            gatingManager.testAffirmationGate()
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Test Affirmation Gate")
                                .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            gatingManager.forceTriggerGating()
                        }) {
                            HStack {
                                Image(systemName: "bolt.circle.fill")
                                    .font(.title2)
                                Text("Force Trigger Gating")
                                .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            gatingManager.forceTriggerGating()
                        }) {
                            HStack {
                                Image(systemName: "list.bullet.circle.fill")
                                    .font(.title2)
                                Text("Trigger All Blocked Apps")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            gatingManager.forceTriggerGating()
                        }) {
                            HStack {
                                Image(systemName: "bolt.horizontal.circle.fill")
                                    .font(.title2)
                                Text("Force Show Gate NOW")
                                .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            gatingManager.showGateImmediately()
                        }) {
                            HStack {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Show Gate IMMEDIATELY")
                                    .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            gatingManager.showGateWithDelay()
                        }) {
                            HStack {
                                Image(systemName: "clock.circle.fill")
                                    .font(.title2)
                                Text("Show Gate with Delay")
                                .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            gatingManager.testRealAppGating()
                        }) {
                            HStack {
                                Image(systemName: "shield.checkered")
                                    .font(.title2)
                                Text("Test Real App Gating")
                                .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.purple)
                            .cornerRadius(12)
                        }
                        
                        Button(action: {
                            gatingManager.forceTriggerRealGating()
                        }) {
                            HStack {
                                Image(systemName: "bolt.shield")
                                    .font(.title2)
                                Text("Force Real Gating")
                                .fontWeight(.semibold)
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .cornerRadius(12)
                        }
                    }
                    
                    // Environment Info
                    VStack(spacing: 12) {
                        Text("Environment Information:")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Environment:")
                                Spacer()
                                Text(FamilyControlsHelper.environmentInfo)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("Family Controls:")
                                Spacer()
                                Text(FamilyControlsHelper.availabilityMessage)
                                    .foregroundColor(.gray)
                            }
                            
                            HStack {
                                Text("Blocked Apps:")
                                Spacer()
                                Text("\(gatingManager.blockedApps.count)")
                                    .foregroundColor(.gray)
                            }
                        }
                        .font(.subheadline)
                        .padding()
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(12)
                    }
                }
                
                Spacer()
            }
            .padding(.top, 50)
            .padding(.horizontal, 20)
        }
    }
}

#Preview {
    TestGatingView()
        .environmentObject(AppGatingManager.shared)
        .environmentObject(AffirmationStore())
} 