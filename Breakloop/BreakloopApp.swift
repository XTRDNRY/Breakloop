//
//  BreakloopApp.swift
//  Breakloop
//
//  Created by ASAF GOREN on 7/14/25.
//

import SwiftUI

@main
struct BreakloopApp: App {
    @StateObject private var gatingManager = AppGatingManager.shared
    @StateObject private var store = AffirmationStore()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                // Main content
                if hasCompletedOnboarding {
                    HomeView()
                        .environmentObject(store)
                        .environmentObject(gatingManager)
                } else {
                    OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        .environmentObject(store)
                }
                
                // Overlay for AffirmationGateView when app is gated
                if gatingManager.showAffirmationGate {
                    AffirmationGateView(appName: gatingManager.currentAppName) {
                        gatingManager.hideAffirmationGate()
                    }
                    .environmentObject(store)
                    .environmentObject(gatingManager)
                    .transition(.opacity)
                    .zIndex(1000)
                    .allowsHitTesting(true)
                }
            }
            .onAppear {
                // App gating is automatically set up in the manager
            }
        }
    }
}
