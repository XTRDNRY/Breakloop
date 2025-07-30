import Foundation

struct Affirmation: Identifiable, Codable, Equatable {
    enum Theme: String, Codable, CaseIterable, Identifiable {
        case focus = "Focus & Productivity"
        case confidence = "Self-Worth & Confidence"
        case gratitude = "Gratitude"
        case peace = "Inner Peace / Spirituality"
        case relationships = "Healthy Relationships"
        case trustingGod = "Trusting God"
        case user = "User" // For user-created affirmations

        var id: String { rawValue }
        var icon: String {
            switch self {
            case .focus: return "brain.head.profile"
            case .confidence: return "bolt.heart"
            case .gratitude: return "leaf"
            case .peace: return "dove"
            case .relationships: return "heart"
            case .trustingGod: return "cross"
            case .user: return "person.crop.circle"
            }
        }
    }
    let id: UUID
    let theme: Theme
    let text: String
    var icon: String { theme.icon }
    
    init(theme: Theme, text: String) {
        self.id = UUID()
        self.theme = theme
        self.text = text
    }
} 