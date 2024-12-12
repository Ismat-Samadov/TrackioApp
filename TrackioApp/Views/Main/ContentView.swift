// Views/Main/ContentView.swift
import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var habitStore = HabitStore()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedTab = 0
    @State private var showingPaywall = false
    
    // MARK: - Body
    var body: some View {
        Group {
            if storeManager.hasFullAccess {
                mainContent
            } else {
                PaywallView()
                    .interactiveDismissDisabled()
            }
        }
        .onAppear {
            // Request notification permissions when app launches
            notificationManager.requestAuthorization()
            
            // Check purchase status
            Task {
                await storeManager.checkPurchaseStatus()
            }
            
            // For development/testing only
            #if DEBUG
            storeManager.hasFullAccess = true  // Simply set the property directly
            #endif
        }
    }
    
    // MARK: - Views
    private var mainContent: some View {
        TabView(selection: $selectedTab) {
            HabitsView(habitStore: habitStore)
                .tabItem {
                    Label("Habits", systemImage: "checkmark.circle.fill")
                }
                .tag(0)
            
            AnalyticsDashboardView(habitStore: habitStore)
                .tabItem {
                    Label("Analytics", systemImage: "chart.bar.fill")
                }
                .tag(1)
        }
        .onChange(of: selectedTab) { oldValue, newValue in
            triggerHapticFeedback()
        }
    }
    
    // MARK: - Helper Methods
    private func triggerHapticFeedback() {
        let haptic = UIImpactFeedbackGenerator(style: .light)
        haptic.prepare()
        haptic.impactOccurred()
    }
}

// MARK: - Preview Provider
#Preview {
    ContentView()
}
