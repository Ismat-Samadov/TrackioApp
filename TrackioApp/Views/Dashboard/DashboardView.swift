//
//  DashboardView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Dashboard/DashboardView.swift
import SwiftUI
import Charts

struct AnalyticsDashboardView: View {
    // MARK: - Properties
    @StateObject private var viewModel: DashboardViewModel
    @Environment(\.colorScheme) private var colorScheme
    
    // MARK: - Initialization
    init(habitStore: HabitStore) {
        _viewModel = StateObject(wrappedValue: DashboardViewModel(habitStore: habitStore))
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    periodSelector
                    
                    if let metrics = viewModel.metrics {
                        statsOverview(metrics)
                        progressCharts
                        habitsList
                    } else {
                        loadingView
                    }
                }
                .padding()
            }
            .navigationTitle("Analytics")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    shareButton
                }
                
                ToolbarItem(placement: .navigationBarLeading) {
                    refreshButton
                }
            }
        }
        .navigationViewStyle(.stack)
    }
    
    // MARK: - Components
    private var periodSelector: some View {
        Picker("Analysis Period", selection: $viewModel.selectedPeriod) {
            ForEach(AnalyticsPeriod.allCases) { period in
                Text(period.title)
                    .tag(period)
            }
        }
        .pickerStyle(.segmented)
    }
    
    private func statsOverview(_ metrics: AnalyticsMetrics) -> some View {
        VStack(spacing: 16) {
            LazyVGrid(columns: [
                GridItem(.flexible()),
                GridItem(.flexible())
            ], spacing: 16) {
                AnalyticCardView(
                    title: "Total Habits",
                    value: "\(metrics.totalHabits)",
                    icon: "list.bullet",
                    color: .blue
                )
                
                AnalyticCardView(
                    title: "Active Habits",
                    value: "\(metrics.activeHabits)",
                    icon: "sparkles",
                    color: .green
                )
                
                AnalyticCardView(
                    title: "Completion Rate",
                    value: metrics.completionRateFormatted,
                    icon: "chart.bar.fill",
                    color: .orange
                )
                
                AnalyticCardView(
                    title: "Best Streak",
                    value: "\(metrics.maxStreak)d",
                    icon: "flame.fill",
                    color: .red
                )
            }
        }
        .padding(.vertical)
    }
    
    private var progressCharts: some View {
        VStack(spacing: 24) {
            if #available(iOS 16.0, *) {
                WeeklyProgressChart(analytics: viewModel.habitAnalytics)
                    .frame(height: 250)
                    .background(chartBackground)
                
                CompletionDistributionChart(analytics: viewModel.habitAnalytics)
                    .frame(height: 250)
                    .background(chartBackground)
            } else {
                // Fallback for earlier iOS versions
                legacyChartView
            }
        }
    }
    
    @ViewBuilder
    private var legacyChartView: some View {
        VStack(spacing: 16) {
            Text("Charts are available in iOS 16 and later")
                .font(.caption)
                .foregroundColor(.secondary)
            
            // Simple bar representation for earlier iOS versions
            HStack(alignment: .bottom, spacing: 4) {
                ForEach(viewModel.habitAnalytics) { analytic in
                    VStack {
                        Rectangle()
                            .fill(analytic.color)
                            .frame(height: CGFloat(analytic.completionRate) * 2)
                        Text(analytic.title)
                            .font(.caption2)
                            .rotationEffect(.degrees(-45))
                    }
                }
            }
            .frame(height: 250)
            .padding()
            .background(chartBackground)
        }
    }
    
    private var habitsList: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Habit Details")
                .font(.headline)
            
            ForEach(viewModel.habitAnalytics) { analytic in
                HabitAnalyticRowView(analytic: analytic)
            }
        }
        .padding(.vertical)
    }
    
    private var loadingView: some View {
        VStack(spacing: 20) {
            ProgressView()
            Text("Loading analytics...")
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var shareButton: some View {
        Button(action: shareAnalytics) {
            Image(systemName: "square.and.arrow.up")
        }
    }
    
    private var refreshButton: some View {
        Button(action: {
            viewModel.refreshMetrics()
        }) {
            Image(systemName: "arrow.clockwise")
        }
    }
    
    private var chartBackground: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 5)
    }
    
    // MARK: - Actions
    private func shareAnalytics() {
        guard let metrics = viewModel.metrics else { return }
        
        let shareText = """
        Habit Tracker Analytics
        
        Total Habits: \(metrics.totalHabits)
        Active Habits: \(metrics.activeHabits)
        Completion Rate: \(metrics.completionRateFormatted)
        Best Streak: \(metrics.maxStreak) days
        Total Completions: \(metrics.totalCompletions)
        """
        
        let av = UIActivityViewController(
            activityItems: [shareText],
            applicationActivities: nil
        )
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first,
           let rootVC = window.rootViewController {
            rootVC.present(av, animated: true)
        }
    }
}

// MARK: - Preview
#Preview {
    AnalyticsDashboardView(habitStore: HabitStore())
}
