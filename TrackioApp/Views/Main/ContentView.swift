// Views/Main/ContentView.swift
import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    @StateObject private var habitStore = HabitStore()
    @StateObject private var notificationManager = NotificationManager()
    @State private var selectedTab = 0
    @State private var isLoading = true
    
    // MARK: - Body
    var body: some View {
        Group {
            if isLoading {
                LoadingView()
                    .transition(.opacity)
            } else {
                mainContent
                    .transition(.opacity)
            }
        }
        .task {
            // Initialize app data
            do {
                // Add artificial delay for minimum loading time
                try await Task.sleep(nanoseconds: 1_500_000_000) // 1.5 seconds
                
                // Request notification authorization
                notificationManager.requestAuthorization()
                
                // Hide loading screen with animation
                withAnimation(.easeOut(duration: 0.3)) {
                    isLoading = false
                }
            } catch {
                print("Initialization error: \(error.localizedDescription)")
                isLoading = false
            }
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
