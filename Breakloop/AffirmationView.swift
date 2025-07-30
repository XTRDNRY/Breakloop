import SwiftUI

struct AffirmationView: View {
    @EnvironmentObject var store: AffirmationStore
    @AppStorage("mainTheme") private var mainThemeRaw: String = Affirmation.Theme.focus.rawValue
    @State private var affirmation: Affirmation? = nil
    @State private var userInput: String = ""
    @State private var showSuccess = false
    @Environment(\.presentationMode) var presentationMode

    var mainTheme: Affirmation.Theme {
        Affirmation.Theme(rawValue: mainThemeRaw) ?? .focus
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 32) {
                Image("icon_1024x1024")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.top, 32)
                Text("Type the affirmation to continue")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                if let affirmation = affirmation {
                    Text(affirmation.text)
                        .font(.title3.weight(.medium))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }
                TextField("Type here...", text: $userInput)
                    .padding()
                    .background(Color(.darkGray).opacity(0.9))
                    .foregroundColor(.white)
                    .font(.title3)
                    .cornerRadius(14)
                    .padding(.horizontal, 24)
                    .accentColor(.green)
                Button(action: checkInput) {
                    Text("Submit")
                        .font(.title3.bold())
                        .foregroundColor(.black)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color.green)
                        .cornerRadius(14)
                        .padding(.horizontal, 24)
                }
                .disabled(userInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                Spacer()
            }
            if showSuccess {
                VStack {
                    Spacer()
                    Text("🎉 Success!")
                        .font(.title.bold())
                        .foregroundColor(.green)
                        .padding()
                        .background(Color(.darkGray).opacity(0.8))
                        .cornerRadius(16)
                    Spacer()
                }
                .transition(.opacity)
            }
        }
        .onAppear(perform: loadAffirmation)
    }

    func loadAffirmation() {
        let themeKey = mainTheme.rawValue
        if let themeAffirmations = store.affirmationsByTheme[themeKey], !themeAffirmations.isEmpty {
            let randomText = themeAffirmations.randomElement() ?? "I am focused and present."
            affirmation = Affirmation(theme: mainTheme, text: randomText)
        } else {
            affirmation = Affirmation(theme: mainTheme, text: "I am focused and present.")
        }
        userInput = ""
        showSuccess = false
    }

    func checkInput() {
        guard let affirmation = affirmation else { return }
        let expected = affirmation.text.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let typed = userInput.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if typed == expected {
            withAnimation {
                showSuccess = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation {
                    showSuccess = false
                }
                presentationMode.wrappedValue.dismiss()
            }
        }
    }
} 