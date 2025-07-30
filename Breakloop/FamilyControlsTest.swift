import SwiftUI

// ✅ This is a SwiftUI view, not a unit test
// ✅ It should be in the main target, not test target
// ✅ Uses FamilyControlsHelper for safe type checking
struct FamilyControlsTest: View {
    
    var body: some View {
        VStack(spacing: 20) {
            Text("FamilyControls Framework Test")
                .font(.title)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("✅ Framework Status:")
                    .font(.headline)
                
                Text("• ApplicationToken: \(FamilyControlsHelper.isFamilyControlsAvailable ? "Available" : "Not Available")")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("• FamilyActivitySelection: \(FamilyControlsHelper.isFamilyControlsAvailable ? "Available" : "Not Available")")
                    .font(.caption)
                    .foregroundColor(.green)
                
                Text("• FamilyActivityPicker: \(FamilyControlsHelper.canUseFamilyControls ? "Available" : "Not Available")")
                    .font(.caption)
                    .foregroundColor(FamilyControlsHelper.canUseFamilyControls ? .green : .red)
            }
            .padding()
            .background(Color.green.opacity(0.1))
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("ℹ️ Environment Info:")
                    .font(.headline)
                
                Text("• Environment: \(FamilyControlsHelper.environmentInfo)")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("• Availability: \(FamilyControlsHelper.availabilityMessage)")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("• Preview Mode: \(FamilyControlsHelper.isPreviewEnvironment ? "Yes" : "No")")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("• Test Environment: \(FamilyControlsHelper.isTestEnvironment ? "Yes" : "No")")
                    .font(.caption)
                    .foregroundColor(.blue)
                
                Text("• Simulator: \(FamilyControlsHelper.isSimulator ? "Yes" : "No")")
                    .font(.caption)
                    .foregroundColor(.blue)
            }
            .padding()
            .background(Color.blue.opacity(0.1))
            .cornerRadius(10)
            
            VStack(alignment: .leading, spacing: 8) {
                Text("📋 Testing Instructions:")
                    .font(.headline)
                
                Text("• SwiftUI Preview: FamilyControls not available")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text("• Unit Tests: FamilyControls not available")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text("• Simulator: FamilyControls not available")
                    .font(.caption)
                    .foregroundColor(.orange)
                
                Text("• Real Device: FamilyControls available")
                    .font(.caption)
                    .foregroundColor(.green)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(10)
            
            Button("Test FamilyActivityPicker") {
                // This will test if FamilyActivityPicker is available
                print("🎯 FamilyActivityPicker test button tapped")
                print("✅ FamilyControls available: \(FamilyControlsHelper.canUseFamilyControls)")
                print("✅ Environment: \(FamilyControlsHelper.environmentInfo)")
            }
            .buttonStyle(.borderedProminent)
            .disabled(!FamilyControlsHelper.canUseFamilyControls)
        }
        .padding()
        .onAppear {
            print("✅ FamilyControls framework is loaded successfully")
            print("✅ ApplicationToken available: \(FamilyControlsHelper.isFamilyControlsAvailable)")
            print("✅ FamilyActivitySelection available: \(FamilyControlsHelper.isFamilyControlsAvailable)")
            print("✅ Environment: \(FamilyControlsHelper.environmentInfo)")
            print("✅ Available: \(FamilyControlsHelper.canUseFamilyControls)")
        }
    }
}

#Preview {
    FamilyControlsTest()
} 