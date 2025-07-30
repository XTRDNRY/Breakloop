import SwiftUI

struct DarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(.white)
            .padding(.vertical, 14)
            .padding(.horizontal, 24)
            .background(Color(.darkGray).opacity(configuration.isPressed ? 0.7 : 0.9))
            .cornerRadius(12)
            .opacity(configuration.isPressed ? 0.85 : 1.0)
            .animation(.easeInOut(duration: 0.12), value: configuration.isPressed)
    }
}

// MARK: - Preview
struct DarkButtonStyle_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 24) {
            Button("Dark Button", action: {})
                .buttonStyle(DarkButtonStyle())
            Button(action: {}) {
                HStack {
                    Image(systemName: "star.fill")
                    Text("With Icon")
                }
            }
            .buttonStyle(DarkButtonStyle())
        }
        .padding()
        .background(Color.black.ignoresSafeArea())
        .preferredColorScheme(.dark)
    }
} 