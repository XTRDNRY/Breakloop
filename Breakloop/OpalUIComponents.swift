import SwiftUI

// MARK: - Opal Card
struct OpalCard<Content: View>: View {
    let content: Content
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    var body: some View {
        content
            .padding(24)
            .background(
                LinearGradient(gradient: Gradient(colors: [Color(.sRGB, white: 0.12, opacity: 1), Color(.sRGB, white: 0.18, opacity: 1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .cornerRadius(20)
            .shadow(color: Color.black.opacity(0.35), radius: 16, x: 0, y: 8)
    }
}

// MARK: - Opal Button
struct OpalButton: View {
    let title: String
    let icon: String?
    var gradient: LinearGradient = LinearGradient(gradient: Gradient(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .bottomTrailing)
    var action: () -> Void
    @State private var pressed = false
    var body: some View {
        Button(action: action) {
            HStack(spacing: 10) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.title2)
                }
                Text(title)
                    .font(.system(size: 22, weight: .bold, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(gradient)
            .cornerRadius(18)
            .shadow(color: Color.purple.opacity(0.18), radius: 10, x: 0, y: 6)
            .scaleEffect(pressed ? 0.97 : 1.0)
            .animation(.easeInOut(duration: 0.15), value: pressed)
        }
        .buttonStyle(PlainButtonStyle())
        .simultaneousGesture(DragGesture(minimumDistance: 0).onChanged { _ in pressed = true }.onEnded { _ in pressed = false })
    }
}

// MARK: - Opal List Row
struct OpalListRow: View {
    let icon: String?
    let title: String
    let subtitle: String?
    var trailing: AnyView? = nil
    var body: some View {
        HStack(spacing: 16) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundColor(.blue)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 20, weight: .medium, design: .rounded))
                    .foregroundColor(.white)
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 15, weight: .light, design: .rounded))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
            if let trailing = trailing {
                trailing
            }
        }
        .padding(18)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, white: 0.13, opacity: 1), Color(.sRGB, white: 0.19, opacity: 1)]), startPoint: .topLeading, endPoint: .bottomTrailing)
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.22), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Opal Section Header
struct OpalSectionHeader: View {
    let title: String
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            Spacer()
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 8)
        .background(
            LinearGradient(gradient: Gradient(colors: [Color(.sRGB, white: 0.18, opacity: 1), Color(.sRGB, white: 0.13, opacity: 1)]), startPoint: .top, endPoint: .bottom)
        )
        .cornerRadius(16)
        .shadow(color: Color.black.opacity(0.12), radius: 4, x: 0, y: 2)
    }
}

// MARK: - Preview
struct OpalUIComponents_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 32) {
                OpalSectionHeader(title: "Affirmations")
                OpalCard {
                    Text("I choose purpose over distraction")
                        .font(.system(size: 22, weight: .medium, design: .rounded))
                        .foregroundColor(.white)
                }
                OpalButton(title: "Start Session", icon: "play.fill") {}
                OpalListRow(icon: "app.badge", title: "Instagram", subtitle: "Blocked app", trailing: AnyView(Image(systemName: "trash").foregroundColor(.red)))
            }
            .padding()
        }
        .preferredColorScheme(.dark)
    }
} 