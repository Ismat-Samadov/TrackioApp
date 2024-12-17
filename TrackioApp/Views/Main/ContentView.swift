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
            // Handle notifications synchronously
            notificationManager.requestAuthorization()
            
            // Handle async operations
            await storeManager.checkPurchaseStatus()
            await storeManager.loadProducts()
            
            #if DEBUG
            UserDefaults.standard.set(true, forKey: "isPurchased")
            await storeManager.checkPurchaseStatus()
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
        .onChange(of: selectedTab) { old, new in
            if old != new {
                let haptic = UIImpactFeedbackGenerator(style: .light)
                haptic.prepare()
                haptic.impactOccurred()
            }
        }
    }
}

// MARK: - Preview Provider
#Preview {
    ContentView()
}
