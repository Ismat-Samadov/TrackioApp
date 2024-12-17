// Views/Main/ContentView.swift
import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var habitStore = HabitStore()
    @StateObject private var notificationManager = NotificationManager()
    @StateObject private var storeManager = StoreManager.shared
    @State private var selectedTab = 0
    @State private var isLoading = true
    
    // MARK: - Body
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .transition(.opacity)
            } else if storeManager.isPurchased {
                mainContent
                    .transition(.opacity)
            } else {
                PaywallView()
                    .transition(.opacity)
                    .interactiveDismissDisabled()
            }
        }
        .task {
            // Initialize app data
            await initializeApp()
            
            #if DEBUG
            UserDefaults.standard.set(true, forKey: "isPurchased")
            await storeManager.checkPurchaseStatus()
            #endif
            
            // Hide loading screen with animation
            withAnimation(.easeOut(duration: 0.3)) {
                isLoading = false
            }
        }
    }
    
    // MARK: - Initialization
    private func initializeApp() async {
        // Add artificial delay for minimum loading time
        do {
            try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
        } catch {
            print("Sleep interrupted: \(error.localizedDescription)")
        }
        
        // Initialize all required services
        await withTaskGroup(of: Void.self) { group in
            // Request notification authorization
            group.addTask {
                await notificationManager.requestAuthorization()
            }
            
            // Check purchase status
            group.addTask {
                await storeManager.checkPurchaseStatus()
            }
            
            // Load store products
            group.addTask {
                await storeManager.loadProducts()
            }
            
            // Wait for all tasks to complete
            await group.waitForAll()
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
