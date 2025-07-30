import Foundation
import Combine
import ManagedSettings // Added for ManagedSettingsStore context
import SwiftUI
import FamilyControls

class AffirmationStore: ObservableObject {
    @Published var selectedTheme: String?
    @Published var blockedApps: [String] = []
    @Published var affirmationsByTheme: [String: [String]] = [:]
    @Published var appThemes: [String: [String]] = [:]
    @Published var customAffirmations: [String] = []
    
    private let gatingManager = AppGatingManager.shared
    
    init() {
        loadData()
        setupDefaultAffirmations()
    }
    
    private func setupDefaultAffirmations() {
        if affirmationsByTheme.isEmpty {
            affirmationsByTheme = [
                "Trusting God": [
                    "I trust in God's plan for my life.",
                    "God is guiding my every step.",
                    "I am blessed and highly favored.",
                    "God's timing is perfect.",
                    "I walk by faith, not by sight.",
                    "God is my strength and my shield.",
                    "I am fearfully and wonderfully made.",
                    "God's love surrounds me always.",
                    "I am a child of God.",
                    "God is working all things for my good.",
                    "I trust God with my future.",
                    "God's grace is sufficient for me.",
                    "I am protected by God's love.",
                    "God is my refuge and strength.",
                    "I am chosen and called by God.",
                    "God's peace fills my heart.",
                    "I am walking in God's purpose.",
                    "God is my provider and sustainer.",
                    "I am victorious through Christ.",
                    "God's wisdom guides my decisions.",
                    "I am loved unconditionally by God.",
                    "God is my healer and restorer.",
                    "I am confident in God's promises.",
                    "God is my light in darkness.",
                    "I am secure in God's embrace.",
                    "God is my hope and anchor.",
                    "I am empowered by God's spirit.",
                    "God is my comfort in trials.",
                    "I am blessed to be a blessing.",
                    "God is my joy and my song."
                ],
                "Work": [
                    "I am productive and efficient.",
                    "I excel in my professional endeavors.",
                    "I am a valuable team member.",
                    "I approach challenges with confidence.",
                    "I am constantly improving my skills.",
                    "I am respected in my workplace.",
                    "I am focused and goal-oriented.",
                    "I am a natural leader.",
                    "I am creative and innovative.",
                    "I am reliable and trustworthy.",
                    "I am passionate about my work.",
                    "I am adaptable to change.",
                    "I am detail-oriented and thorough.",
                    "I am a problem solver.",
                    "I am motivated and driven.",
                    "I am collaborative and supportive.",
                    "I am organized and efficient.",
                    "I am confident in my abilities.",
                    "I am committed to excellence.",
                    "I am a quick learner.",
                    "I am professional and polished.",
                    "I am results-driven.",
                    "I am a strategic thinker.",
                    "I am resilient under pressure.",
                    "I am inspiring to others.",
                    "I am accountable for my actions.",
                    "I am growth-minded.",
                    "I am a positive influence.",
                    "I am successful in my career.",
                    "I am making a difference."
                ],
                "Motivation": [
                    "I am unstoppable.",
                    "I have unlimited potential.",
                    "I am motivated and driven.",
                    "I am capable of achieving anything.",
                    "I am focused on my goals.",
                    "I am determined to succeed.",
                    "I am passionate about my dreams.",
                    "I am committed to excellence.",
                    "I am resilient and strong.",
                    "I am confident in my abilities.",
                    "I am a force to be reckoned with.",
                    "I am making progress every day.",
                    "I am inspired and inspiring.",
                    "I am taking action towards my goals.",
                    "I am building momentum.",
                    "I am overcoming obstacles.",
                    "I am staying focused and disciplined.",
                    "I am pushing through challenges.",
                    "I am growing stronger each day.",
                    "I am creating my own success.",
                    "I am motivated by my vision.",
                    "I am taking massive action.",
                    "I am unstoppable in pursuit of my dreams.",
                    "I am building an extraordinary life.",
                    "I am motivated by my purpose.",
                    "I am creating positive change.",
                    "I am inspiring others to greatness.",
                    "I am living up to my potential.",
                    "I am achieving my goals.",
                    "I am becoming the best version of myself."
                ],
                "Relationships": [
                    "I attract healthy relationships.",
                    "I am worthy of love and respect.",
                    "I communicate clearly and honestly.",
                    "I set healthy boundaries.",
                    "I am a great listener.",
                    "I am empathetic and understanding.",
                    "I am loyal and trustworthy.",
                    "I am supportive of others.",
                    "I am patient and kind.",
                    "I am open to love and connection.",
                    "I am confident in social situations.",
                    "I am authentic in my relationships.",
                    "I am forgiving and compassionate.",
                    "I am a positive influence on others.",
                    "I am building meaningful connections.",
                    "I am respected by others.",
                    "I am creating space for deep relationships.",
                    "I am bringing joy to others.",
                    "I am setting healthy boundaries with ease.",
                    "I am a great listener and communicator.",
                    "I am building trust through honesty.",
                    "I am deserving of loyal relationships.",
                    "I am emotionally available.",
                    "I am making others feel valued.",
                    "I am choosing love over ego.",
                    "I am safe to express myself.",
                    "I am nurturing important relationships.",
                    "I am attracting aligned people.",
                    "I am patient and compassionate.",
                    "I am releasing toxic connections.",
                    "I am growing with my partner."
                ],
                "Manifest Wealth": [
                    "I am worthy of financial abundance.",
                    "Money flows to me easily.",
                    "I attract opportunities to grow my income.",
                    "I think like a wealthy person.",
                    "I use money with intention.",
                    "I am aligned with the energy of wealth.",
                    "My income expands constantly.",
                    "I am grateful for all I have.",
                    "I believe in limitless earning potential.",
                    "Wealth comes from serving others.",
                    "I attract unexpected financial blessings.",
                    "My mind is wired for prosperity.",
                    "I make smart financial decisions.",
                    "I invest in my future.",
                    "I multiply money with purpose.",
                    "I use wealth to make a difference.",
                    "Abundance is my natural state.",
                    "I receive money with joy.",
                    "I am financially free.",
                    "I break limiting beliefs around money.",
                    "I deserve to live in luxury.",
                    "I create wealth doing what I love.",
                    "I release scarcity and welcome abundance.",
                    "I have a millionaire mindset.",
                    "I save and grow money consistently.",
                    "I trust money comes at the right time.",
                    "My bank account keeps rising.",
                    "I feel powerful managing money.",
                    "I am a magnet for wealth.",
                    "Wealth finds me daily.",
                    "I am creating multiple income streams."
                ],
                "Push Through Failure": [
                    "Failure is part of my greatness.",
                    "I grow every time I fall.",
                    "I am not afraid to try again.",
                    "I fail forward with purpose.",
                    "Setbacks sharpen my skills.",
                    "I rise every time I fall.",
                    "I learn more through failure than success.",
                    "I don't stop when it's hard.",
                    "I keep showing up.",
                    "Failure is a setup for my comeback.",
                    "I bend but never break.",
                    "I make mistakes and improve.",
                    "I bounce back stronger.",
                    "I turn losses into lessons.",
                    "My past doesn't define me.",
                    "I'm not done until I win.",
                    "I trust my process, even when it's messy.",
                    "I am resilient to my core.",
                    "I overcome everything that tests me.",
                    "I use rejection as redirection.",
                    "I fail boldly.",
                    "I get back up every time.",
                    "I thrive through discomfort.",
                    "I rise with grit.",
                    "I fail and grow with no shame.",
                    "I am never stuck — I evolve.",
                    "I keep trying.",
                    "I become better, not bitter.",
                    "I rewrite the story every day.",
                    "My failure is my fire.",
                    "I am unstoppable despite setbacks."
                ],
                "Believe in Yourself": [
                    "I am confident and powerful.",
                    "I believe in my ability to figure things out.",
                    "I am proud of who I am.",
                    "I trust my inner voice.",
                    "I believe in my dreams fully.",
                    "I am enough.",
                    "I stand tall in my truth.",
                    "I radiate self-belief.",
                    "I am capable of doing hard things.",
                    "I believe I can create anything.",
                    "I walk with purpose.",
                    "I honor my uniqueness.",
                    "I celebrate my progress.",
                    "I deserve success.",
                    "I trust my intuition.",
                    "I am exactly where I'm meant to be.",
                    "I silence self-doubt.",
                    "I am worthy of my vision.",
                    "I speak to myself with love.",
                    "I keep promises to myself.",
                    "I am courageous in uncertainty.",
                    "I embrace my flaws.",
                    "I define who I am.",
                    "I am limitless.",
                    "I believe I was born for greatness.",
                    "I lead myself first.",
                    "I am aligned with my potential.",
                    "I back myself fully.",
                    "I am brave, bold, and unstoppable.",
                    "I believe in me — no matter what.",
                    "I am becoming my best self."
                ],
                "Digital Wellness": [
                    "I am mindful of my screen time.",
                    "I choose meaningful content.",
                    "I am present in the real world.",
                    "I use technology intentionally.",
                    "I prioritize real connections.",
                    "I am in control of my digital habits.",
                    "I choose quality over quantity.",
                    "I am aware of my online behavior.",
                    "I set healthy digital boundaries.",
                    "I use apps that serve my goals.",
                    "I am intentional about my online time.",
                    "I prioritize my mental health.",
                    "I choose content that uplifts me.",
                    "I am mindful of my digital footprint.",
                    "I use technology as a tool, not a crutch.",
                    "I am present in my relationships.",
                    "I choose real experiences over virtual ones.",
                    "I am in control of my attention.",
                    "I use social media mindfully.",
                    "I prioritize my well-being.",
                    "I am intentional about my choices.",
                    "I choose what serves my highest good.",
                    "I am mindful of my time.",
                    "I use technology to enhance my life.",
                    "I am present in this moment.",
                    "I choose meaningful interactions.",
                    "I am aware of my digital consumption.",
                    "I prioritize my mental clarity.",
                    "I use apps that align with my values.",
                    "I am in control of my digital life.",
                    "I choose presence over distraction."
                ]
            ]
            
            loadAppThemes()
            loadCustomAffirmations()
        }
    }
    
    func addBlockedApp(_ app: String) {
        if !blockedApps.contains(app) {
            blockedApps.append(app)
            saveBlockedApps()
            
            // Actually gate the app using AppGatingManager
            // Note: This method doesn't exist in current AppGatingManager
            // gatingManager.gateApp(app)
        }
    }
    
    func removeBlockedApp(_ app: String) {
        blockedApps.removeAll { $0 == app }
        saveBlockedApps()
        
        // Actually ungate the app using AppGatingManager
        // Note: This method doesn't exist in current AppGatingManager
        // gatingManager.ungateApp(app)
    }
    
    func addAffirmation(theme: String, affirmation: String) {
        if affirmationsByTheme[theme] != nil {
            affirmationsByTheme[theme]?.append(affirmation)
        } else {
            affirmationsByTheme[theme] = [affirmation]
        }
        saveAffirmations()
    }
    
    func removeAffirmation(theme: String, index: Int) {
        guard var affirmations = affirmationsByTheme[theme], affirmations.indices.contains(index) else { return }
        affirmations.remove(at: index)
        affirmationsByTheme[theme] = affirmations
            saveAffirmations()
    }
    
    func updateAffirmation(theme: String, index: Int, newText: String) {
        guard var affirmations = affirmationsByTheme[theme], affirmations.indices.contains(index) else { return }
        affirmations[index] = newText
        affirmationsByTheme[theme] = affirmations
        saveAffirmations()
    }
    
    // Custom affirmations functions
    func addCustomAffirmation(_ affirmation: String) {
        customAffirmations.append(affirmation)
        saveCustomAffirmations()
    }
    
    func removeCustomAffirmation(at index: Int) {
        guard customAffirmations.indices.contains(index) else { return }
        customAffirmations.remove(at: index)
        saveCustomAffirmations()
    }
    
    func updateCustomAffirmation(at index: Int, newText: String) {
        guard customAffirmations.indices.contains(index) else { return }
        customAffirmations[index] = newText
        saveCustomAffirmations()
    }
    
    func getThemesForApp(_ appName: String) -> [String] {
        return appThemes[appName] ?? []
    }
    
    func setThemesForApp(_ appName: String, themes: [String]) {
        appThemes[appName] = themes
        saveAppThemes()
    }
    
    func getRandomAffirmationForApp(_ appName: String) -> String? {
        let themes = getThemesForApp(appName)
        
        // If no specific themes are set for this app, use general themes
        let availableThemes = themes.isEmpty ? ["Digital Wellness", "Motivation", "Believe in Yourself"] : themes
        
        var allAffirmations: [String] = []
        
        // Collect affirmations from all available themes
        for theme in availableThemes {
            if let themeAffirmations = affirmationsByTheme[theme] {
                allAffirmations.append(contentsOf: themeAffirmations)
            }
        }
        
        // If no affirmations found, use fallback
        if allAffirmations.isEmpty {
            allAffirmations = [
                "I am mindful of my choices",
                "I am in control of my digital habits",
                "I choose to be present",
                "I am intentional about my time",
                "I choose what serves my highest good"
            ]
        }
        
        return allAffirmations.randomElement()
    }
    
    // MARK: - Persistence
    
    private func loadData() {
        loadBlockedApps()
        loadAppThemes()
        loadCustomAffirmations()
    }
    
    private func loadBlockedApps() {
        if let savedApps = UserDefaults.standard.array(forKey: "blockedApps") as? [String] {
            blockedApps = savedApps
        }
    }
    
    private func saveBlockedApps() {
        UserDefaults.standard.set(blockedApps, forKey: "blockedApps")
    }
    
    private func loadAppThemes() {
        if let savedThemes = UserDefaults.standard.dictionary(forKey: "appThemes") as? [String: [String]] {
            appThemes = savedThemes
        }
    }
    
    private func saveAppThemes() {
        UserDefaults.standard.set(appThemes, forKey: "appThemes")
    }
    
    private func loadCustomAffirmations() {
        if let savedAffirmations = UserDefaults.standard.array(forKey: "customAffirmations") as? [String] {
            customAffirmations = savedAffirmations
        }
    }
    
    private func saveCustomAffirmations() {
        UserDefaults.standard.set(customAffirmations, forKey: "customAffirmations")
    }
    
    private func saveAffirmations() {
        // Save affirmations to UserDefaults if needed
        // For now, we're using the default affirmations in memory
    }
    
    func isAppGated(_ appName: String) -> Bool {
        return blockedApps.contains(appName)
    }
    
    func getAppThemesString() -> String {
        if let data = try? JSONEncoder().encode(appThemes),
           let string = String(data: data, encoding: .utf8) {
            return string
        }
        return "{}"
    }
} 