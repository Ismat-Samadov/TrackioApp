//
//  AnalyticCharts.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Dashboard/Charts/AnalyticCharts.swift
import SwiftUI
import Charts

struct CompletionDistributionChart: View {
    let analytics: [HabitAnalytics]
    @Environment(\.colorScheme) private var colorScheme
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Completion Distribution")
                .font(.headline)
                .padding(.horizontal)
            
            if analytics.isEmpty {
                emptyStateView
            } else {
                chartView
            }
        }
    }
    
    private var chartView: some View {
        Chart {
            ForEach(analytics) { analytic in
                BarMark(
                    x: .value("Habit", analytic.title),
                    y: .value("Completion Rate", analytic.completionRate)
                )
                .foregroundStyle(analytic.color)
                .annotation(position: .top) {
                    Text("\(Int(analytic.completionRate))%")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .chartYScale(domain: 0...100)
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let title = value.as(String.self) {
                        Text(title)
                            .font(.caption2)
                    }
                }
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let number = value.as(Double.self) {
                        Text("\(Int(number))%")
                            .font(.caption2)
                    }
                }
                AxisGridLine()
            }
        }
        .frame(height: 200)
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No data available")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding()
    }
}

struct StreakDistributionChart: View {
    let analytics: [HabitAnalytics]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Streak Distribution")
                .font(.headline)
                .padding(.horizontal)
            
            if analytics.isEmpty {
                emptyStateView
            } else {
                chartView
            }
        }
    }
    
    private var chartView: some View {
        Chart {
            ForEach(analytics) { analytic in
                LineMark(
                    x: .value("Habit", analytic.title),
                    y: .value("Current Streak", analytic.currentStreak)
                )
                .foregroundStyle(analytic.color)
                .symbol(.circle)
                
                LineMark(
                    x: .value("Habit", analytic.title),
                    y: .value("Longest Streak", analytic.longestStreak)
                )
                .foregroundStyle(analytic.color.opacity(0.3))
                .symbol(.square)
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let number = value.as(Double.self) {
                        Text("\(Int(number))d")
                            .font(.caption2)
                    }
                }
                AxisGridLine()
            }
        }
        .chartXAxis {
            AxisMarks { value in
                AxisValueLabel {
                    if let title = value.as(String.self) {
                        Text(title)
                            .font(.caption2)
                    }
                }
            }
        }
        .frame(height: 200)
        .padding()
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text("No streak data available")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .frame(height: 200)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
        .padding()
    }
}

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            CompletionDistributionChart(analytics: [
                HabitAnalytics(
                    id: UUID(),
                    habitId: UUID(),
                    title: "Exercise",
                    emoji: "🏃‍♂️",
                    color: .blue,
                    completionRate: 85.0,
                    currentStreak: 5,
                    longestStreak: 7,
                    totalCompletions: 20,
                    weekdayDistribution: [:],
                    monthlyProgress: [:]
                ),
                HabitAnalytics(
                    id: UUID(),
                    habitId: UUID(),
                    title: "Reading",
                    emoji: "📚",
                    color: .green,
                    completionRate: 65.0,
                    currentStreak: 3,
                    longestStreak: 8,
                    totalCompletions: 15,
                    weekdayDistribution: [:],
                    monthlyProgress: [:]
                )
            ])
            
            StreakDistributionChart(analytics: [
                HabitAnalytics(
                    id: UUID(),
                    habitId: UUID(),
                    title: "Exercise",
                    emoji: "🏃‍♂️",
                    color: .blue,
                    completionRate: 85.0,
                    currentStreak: 5,
                    longestStreak: 7,
                    totalCompletions: 20,
                    weekdayDistribution: [:],
                    monthlyProgress: [:]
                ),
                HabitAnalytics(
                    id: UUID(),
                    habitId: UUID(),
                    title: "Reading",
                    emoji: "📚",
                    color: .green,
                    completionRate: 65.0,
                    currentStreak: 3,
                    longestStreak: 8,
                    totalCompletions: 15,
                    weekdayDistribution: [:],
                    monthlyProgress: [:]
                )
            ])
        }
        .padding()
    }
}
