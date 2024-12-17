// Views/Main/ContentView.swift
import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var habitStore = HabitStore()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedTab = 0
    
    // MARK: - Body
    var body: some View {
        Group {
            if storeManager.isPurchased {
                mainContent
            } else {
                PaywallView()
                    .interactiveDismissDisabled()
            }
        }
        .task {
            // Request notification permissions when app launches
            notificationManager.requestAuthorization()
            
            // Check purchase status
            await storeManager.checkPurchaseStatus()
            
            // Load available products
            await storeManager.loadProducts()
            
            // For development/testing only
            #if DEBUG
            await MainActor.run {
                UserDefaults.standard.set(true, forKey: "isPurchased")
                await storeManager.checkPurchaseStatus()
            }
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
        .onChange(of: selectedTab) { _, _ in
            let haptic = UIImpactFeedbackGenerator(style: .light)
            haptic.prepare()
            haptic.impactOccurred()
        }
    }
}

// MARK: - Preview Provider
#Preview {
    ContentView()
}
