//
//  StatsGridView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//
// Views/Dashboard/Components/StatsGridView.swift
import SwiftUI

struct StatsGridView: View {
    let metrics: DashboardMetrics
    
    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 16) {
            StatCard(
                title: "Total Habits",
                value: "\(metrics.totalHabits)",
                icon: "checklist",
                color: .blue
            )
            
            StatCard(
                title: "Completion Rate",
                value: "\(Int(metrics.averageCompletionRate))%",
                icon: "chart.bar.fill",
                color: .green
            )
            
            StatCard(
                title: "Best Habit",
                value: metrics.bestPerformingHabit,
                icon: "star.fill",
                color: .orange
            )
            
            StatCard(
                title: "Total Completions",
                value: "\(metrics.totalCompletions)",
                icon: "checkmark.circle.fill",
                color: .purple
            )
        }
    }
}

struct StatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                Spacer()
                Text(value)
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(color)
            }
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

#Preview {
    StatsGridView(metrics: DashboardMetrics(
        totalHabits: 5,
        averageCompletionRate: 85.5,
        bestPerformingHabit: "Exercise",
        totalCompletions: 120,
        weeklyTrend: [:]
    ))
    .padding()
}
