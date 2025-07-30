import SwiftUI

struct AffirmationsView: View {
    @EnvironmentObject var store: AffirmationStore
    @State private var selectedTheme: String? = nil
    @State private var editingIndex: Int? = nil
    @State private var editingText: String = ""
    @State private var newAffirmation: String = ""
    @State private var showAddField: Bool = false
    @State private var showActionSheet: Bool = false
    @State private var actionSheetIdx: Int? = nil
    @State private var showEditField: Bool = false

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            VStack(spacing: 0) {
                // Affirmation strip (top)
                if let selected = selectedTheme, let affirmations = store.affirmationsByTheme[selected] {
                    let isMyAffirmations = selected == "My affirmations"
                    HStack {
                        Spacer()
                        if isMyAffirmations {
                            Button(action: {
                                showAddField = true
                                newAffirmation = ""
                            }) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 26, weight: .bold))
                                    .foregroundColor(.green)
                                    .padding(.trailing, 18)
                                    .padding(.top, 2)
                            }
                        }
                    }
                    if affirmations.isEmpty {
                        Text("No affirmations yet. Add your own!")
                            .foregroundColor(.gray)
                            .font(.body)
                            .padding(.vertical, 32)
                    } else {
                        let grid = chunked(affirmations, into: 3)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(alignment: .top, spacing: 12) {
                                ForEach(0..<grid[0].count, id: \ .self) { col in
                                    VStack(spacing: 8) {
                                        ForEach(0..<3, id: \ .self) { row in
                                            let globalIdx = row * grid[0].count + col
                                            if row < grid.count, col < grid[row].count {
                                                let affirmation = grid[row][col]
                                                HStack(spacing: 4) {
                                                    if showEditField && editingIndex == globalIdx {
                                                        TextField("Edit", text: $editingText, onCommit: {
                                                            saveEdit(idx: globalIdx)
                                                        })
                                                        .foregroundColor(.white)
                                                        .padding(.horizontal, 12)
                                                        .padding(.vertical, 8)
                                                        .background(Color(.darkGray).opacity(0.8))
                                                        .cornerRadius(20)
                                                        .frame(minWidth: 120)
                                                        Button(action: {
                                                            saveEdit(idx: globalIdx)
                                                        }) {
                                                            Image(systemName: "checkmark.circle.fill")
                                                                .foregroundColor(.green)
                                                        }
                                                    } else {
                                                        Text(affirmation)
                                                            .foregroundColor(.white)
                                                            .padding(.horizontal, 16)
                                                            .padding(.vertical, 10)
                                                            .background(Color(.darkGray).opacity(0.8))
                                                            .cornerRadius(20)
                                                            .frame(minWidth: 120)
                                                        Button(action: {
                                                            actionSheetIdx = globalIdx
                                                            showActionSheet = true
                                                        }) {
                                                            Image(systemName: "ellipsis")
                                                                .foregroundColor(.white)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 18)
                        }
                        .actionSheet(isPresented: $showActionSheet) {
                            ActionSheet(title: Text("Edit or Delete Affirmation"), buttons: [
                                .default(Text("Edit")) {
                                    if let idx = actionSheetIdx, let affirmations = store.affirmationsByTheme[selected] {
                                        editingIndex = idx
                                        editingText = affirmations[idx]
                                        showEditField = true
                                    }
                                },
                                .destructive(Text("Delete")) {
                                    if let idx = actionSheetIdx {
                                        store.removeAffirmation(theme: selected, index: idx)
                                    }
                                },
                                .cancel {
                                    editingIndex = nil
                                    editingText = ""
                                    showEditField = false
                                }
                            ])
                        }
                    }
                    // Add new affirmation field (modal style for My affirmations)
                    if isMyAffirmations && showAddField {
                        VStack {
                            Spacer()
                            VStack(spacing: 16) {
                                Text("Add a new affirmation")
                                    .foregroundColor(.white)
                                    .font(.headline)
                                TextField("Your affirmation", text: $newAffirmation)
                                    .foregroundColor(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 12)
                                    .background(Color(.darkGray).opacity(0.95))
                                    .cornerRadius(16)
                                    .frame(minWidth: 200)
                                HStack(spacing: 24) {
                                    Button(action: {
                                        showAddField = false
                                        newAffirmation = ""
                                    }) {
                                        Text("Cancel")
                                            .foregroundColor(.gray)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 8)
                                            .background(Color(.black).opacity(0.7))
                                            .cornerRadius(12)
                                    }
                                    Button(action: {
                                        addAffirmation(keepModalOpen: true)
                                    }) {
                                        Text("Save")
                                            .foregroundColor(.white)
                                            .padding(.horizontal, 18)
                                            .padding(.vertical, 8)
                                            .background(Color.green.opacity(0.8))
                                            .cornerRadius(12)
                                    }
                                }
                            }
                            .padding(24)
                            .background(Color(.black).opacity(0.98))
                            .cornerRadius(24)
                            .shadow(radius: 24)
                            Spacer()
                        }
                        .background(Color.black.opacity(0.7).ignoresSafeArea())
                        .transition(.opacity)
                    }
                }
                // Theme/category grid (bottom)
                Spacer()
                Text("Categories")
                    .font(.title.bold())
                    .foregroundColor(.white)
                    .padding(.top, 12)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 20)
                Text("Select the categories you want to mix or add your own affirmations")
                    .foregroundColor(.gray)
                    .font(.body)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 8)
                let columns = [GridItem(.flexible()), GridItem(.flexible())]
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(Array(store.affirmationsByTheme.keys), id: \ .self) { theme in
                        Button(action: {
                            selectTheme(theme)
                        }) {
                            VStack(spacing: 8) {
                                Spacer(minLength: 0)
                                Text(themeEmoji(theme))
                                    .font(.system(size: 32))
                                    .frame(height: 38)
                                Text(theme)
                                    .font(.headline)
                                    .foregroundColor(.white)
                                    .multilineTextAlignment(.center)
                                    .lineLimit(2)
                                    .minimumScaleFactor(0.7)
                                    .frame(maxWidth: .infinity)
                                Text("\(store.affirmationsByTheme[theme]?.count ?? 0) affirmations")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                    .frame(maxWidth: .infinity)
                                Spacer(minLength: 0)
                            }
                            .frame(width: 160, height: 120)
                            .padding(0)
                            .background(
                                RoundedRectangle(cornerRadius: 22, style: .continuous)
                                    .stroke(selectedTheme == theme ? Color.green : Color.gray.opacity(0.18), lineWidth: 2)
                                    .background(
                                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                                            .fill(Color(.darkGray).opacity(selectedTheme == theme ? 0.9 : 0.7))
                                    )
                            )
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 32)
            }
        }
    }

    // Helper to chunk affirmations into 3 rows for the grid
    private func chunked(_ affirmations: [String], into rows: Int) -> [[String]] {
        let perRow = Int(ceil(Double(affirmations.count) / Double(rows)))
        let safePerRow = max(1, perRow)
        return stride(from: 0, to: affirmations.count, by: safePerRow).map {
            Array(affirmations[$0..<min($0 + safePerRow, affirmations.count)])
        }
    }

    private func selectTheme(_ theme: String) {
        selectedTheme = theme
        editingIndex = nil
        editingText = ""
        showAddField = false
        newAffirmation = ""
        showEditField = false
    }

    private func saveEdit(idx: Int) {
        guard let selected = selectedTheme, !editingText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        store.removeAffirmation(theme: selected, index: idx)
        store.addAffirmation(theme: selected, affirmation: editingText)
        editingIndex = nil
        editingText = ""
        showEditField = false
    }

    private func addAffirmation(keepModalOpen: Bool = false) {
        guard let selected = selectedTheme, !newAffirmation.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        store.addAffirmation(theme: selected, affirmation: newAffirmation)
        showAddField = false
        newAffirmation = ""
    }

    private func themeEmoji(_ theme: String) -> String {
        switch theme {
        case "My affirmations": return "📝"
        case "Trusting God": return "🙏"
        case "Motivation": return "⚡️"
        case "Relationships": return "💖"
        case "Work": return "💼"
        case "Believe in yourself": return "🌟"
        case "Push through the pain": return "🔥"
        case "Manifest wealth": return "💰"
        default: return "��"
        }
    }
} 

