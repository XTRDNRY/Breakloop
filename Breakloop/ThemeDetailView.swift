import SwiftUI

struct ThemeDetailView: View {
    @EnvironmentObject var store: AffirmationStore
    @Environment(\.dismiss) var dismiss
    @State private var editingIndex: Int?
    @State private var editingText: String = ""
    @State private var showingAddSheet = false
    @State private var newAffirmationText = ""
    
    let themeName: String
    
    var affirmations: [String] {
        if themeName == "My Affirmations" {
            return store.customAffirmations
        } else {
            return store.affirmationsByTheme[themeName] ?? []
        }
    }
    
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
            
            VStack(spacing: 0) {
                // Header
                VStack(spacing: 16) {
                    HStack {
                        Button(action: {
                            dismiss()
                        }) {
                            Image(systemName: "chevron.left")
                                .font(.title2)
                                .foregroundColor(.white)
                                .padding(12)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [
                                            Color(.darkGray).opacity(0.8),
                                            Color(.darkGray).opacity(0.6)
                                        ]),
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .clipShape(Circle())
                        }
                        Spacer()
                        Text(themeName)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        Spacer()
                        
                        // Add button for "My Affirmations"
                        if themeName == "My Affirmations" {
                            Button(action: {
                                showingAddSheet = true
                            }) {
                                Image(systemName: "plus")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                    .padding(12)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .clipShape(Circle())
                            }
                        } else {
                            // Placeholder for spacing
                            Color.clear
                                .frame(width: 44, height: 44)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    Text("\(affirmations.count) affirmations")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
                
                // Content
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(Array(affirmations.enumerated()), id: \.offset) { index, affirmation in
                            AffirmationCard(
                                affirmation: affirmation,
                                isEditing: editingIndex == index,
                                editingText: $editingText,
                                onEdit: {
                                    editingIndex = index
                                    editingText = affirmation
                                },
                                onSave: {
                                    if themeName == "My Affirmations" {
                                        store.updateCustomAffirmation(at: index, newText: editingText)
                                    } else {
                                        store.updateAffirmation(theme: themeName, index: index, newText: editingText)
                                    }
                                    editingIndex = nil
                                    editingText = ""
                                },
                                onCancel: {
                                    editingIndex = nil
                                    editingText = ""
                                },
                                onDelete: {
                                    if themeName == "My Affirmations" {
                                        store.removeCustomAffirmation(at: index)
                                    } else {
                                        store.removeAffirmation(theme: themeName, index: index)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    .padding(.bottom, 100) // Space for potential bottom content
                }
            }
        }
        .navigationBarHidden(true)
        .sheet(isPresented: $showingAddSheet) {
            AddCustomAffirmationView { newAffirmation in
                store.addCustomAffirmation(newAffirmation)
            }
        }
    }
}

struct AffirmationCard: View {
    let affirmation: String
    let isEditing: Bool
    @Binding var editingText: String
    let onEdit: () -> Void
    let onSave: () -> Void
    let onCancel: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            if isEditing {
                // Editing mode
                VStack(spacing: 12) {
                    TextField("Enter affirmation", text: $editingText, axis: .vertical)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .background(Color(.darkGray).opacity(0.3))
                        .cornerRadius(12)
                        .lineLimit(3...6)
                    
                    HStack(spacing: 12) {
                        Button(action: onCancel) {
                            Text("Cancel")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.gray)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(Color(.darkGray).opacity(0.5))
                                .cornerRadius(8)
                        }
                        
                        Spacer()
                        
                        Button(action: onSave) {
                            Text("Save")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(.white)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .cornerRadius(8)
                        }
                        .disabled(editingText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.darkGray).opacity(0.9),
                            Color(.darkGray).opacity(0.7)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color.green.opacity(0.5), lineWidth: 1)
                )
            } else {
                // Display mode
                HStack(alignment: .top, spacing: 12) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(affirmation)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.white)
                            .multilineTextAlignment(.leading)
                            .lineLimit(nil)
                    }
                    
                    Spacer()
                    
                    Menu {
                        Button(action: onEdit) {
                            Label("Edit", systemImage: "pencil")
                        }
                        Button(role: .destructive, action: onDelete) {
                            Label("Delete", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color(.darkGray).opacity(0.5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(.darkGray).opacity(0.8),
                            Color(.darkGray).opacity(0.6)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .cornerRadius(16)
            }
        }
        .animation(.easeInOut(duration: 0.2), value: isEditing)
    }
}

struct AddCustomAffirmationView: View {
    @Environment(\.dismiss) var dismiss
    @State private var affirmationText = ""
    let onAdd: (String) -> Void
    
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
            
            VStack(spacing: 24) {
                // Header
                HStack {
                    Button(action: {
                        dismiss()
                    }) {
                        Image(systemName: "xmark")
                            .font(.title2)
                            .foregroundColor(.white)
                            .padding(12)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        Color(.darkGray).opacity(0.8),
                                        Color(.darkGray).opacity(0.6)
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .clipShape(Circle())
                    }
                    Spacer()
                    Text("Add Affirmation")
                        .font(.title2.bold())
                        .foregroundColor(.white)
                    Spacer()
                    Color.clear
                        .frame(width: 44, height: 44)
                }
                .padding(.horizontal, 20)
                .padding(.top, 16)
                
                // Content
                VStack(spacing: 20) {
                    Text("Create your own personal affirmation")
                        .font(.body)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                    
                    TextField("Enter your affirmation...", text: $affirmationText, axis: .vertical)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 16)
                        .background(Color(.darkGray).opacity(0.3))
                        .cornerRadius(12)
                        .lineLimit(3...6)
                        .padding(.horizontal, 20)
                }
                
                Spacer()
                
                // Add Button
                VStack {
                    Button(action: {
                        let trimmedText = affirmationText.trimmingCharacters(in: .whitespacesAndNewlines)
                        if !trimmedText.isEmpty {
                            onAdd(trimmedText)
                            dismiss()
                        }
                    }) {
                        Text("Add Affirmation")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                affirmationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ?
                                AnyShapeStyle(Color.gray) :
                                AnyShapeStyle(
                                    LinearGradient(
                                        gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color.green.opacity(0.3), radius: 8, x: 0, y: 4)
                    }
                    .disabled(affirmationText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color.black.opacity(0.9),
                            Color.black.opacity(0.8)
                        ]),
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
        }
        .navigationBarHidden(true)
    }
}

#Preview {
    ThemeDetailView(themeName: "Motivation")
        .environmentObject(AffirmationStore())
} 