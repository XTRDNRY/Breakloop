import SwiftUI

struct MyAffirmationsView: View {
    @State private var userAffirmations: [String] = []
    @State private var newAffirmation: String = ""
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // Title
                Text("My Affirmations")
                    .font(.largeTitle.bold())
                    .foregroundColor(.white)
                    .padding(.top, 32)
                    .padding(.bottom, 16)
                // List of affirmations
                if userAffirmations.isEmpty {
                    Spacer()
                    Text("No custom affirmations yet.")
                        .foregroundColor(.gray)
                        .font(.body)
                        .padding(.top, 32)
                    Spacer()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 16) {
                            ForEach(userAffirmations.indices, id: \.self) { idx in
                                HStack {
                                    Text(userAffirmations[idx])
                                        .foregroundColor(.white)
                                    Spacer()
                                    Button(action: {
                                        userAffirmations.remove(at: idx)
                                    }) {
                                        Image(systemName: "trash")
                                            .foregroundColor(.red)
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)
                                .background(Color(.darkGray).opacity(0.5))
                                .cornerRadius(10)
                            }
                        }
                        .padding(.horizontal, 8)
                        .padding(.top, 8)
                    }
                }
                Spacer()
                // Add new affirmation
                HStack {
                    TextField("Add affirmation", text: $newAffirmation)
                        .textFieldStyle(PlainTextFieldStyle())
                        .padding(12)
                        .background(Color(.darkGray).opacity(0.7))
                        .cornerRadius(12)
                        .foregroundColor(.white)
                    Button(action: {
                        let trimmed = newAffirmation.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmed.isEmpty {
                            userAffirmations.append(trimmed)
                            newAffirmation = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                            .font(.title2)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 18)
                .background(Color.black)
            }
        }
    }
}

// Preview
struct MyAffirmationsView_Previews: PreviewProvider {
    static var previews: some View {
        MyAffirmationsView()
    }
} 