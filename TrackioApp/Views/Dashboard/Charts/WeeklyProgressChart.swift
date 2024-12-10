//
//  WeeklyProgressChart.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Dashboard/Charts/WeeklyProgressChart.swift
import SwiftUI
import Charts

struct WeeklyProgressChart: View {
    let analytics: [HabitAnalytics]
    @Environment(\.colorScheme) private var colorScheme
    
    private let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Weekly Progress")
                .font(.headline)
                .padding(.horizontal)
            
            if analytics.isEmpty {
                emptyStateView
            } else {
                chartContent
            }
        }
    }
    
    private var chartContent: some View {
        Chart {
            ForEach(analytics) { analytic in
                chartElements(for: analytic)
            }
        }
        .chartYScale(domain: 0...100)
        .chartXAxis(content: xAxisContent)
        .chartYAxis(content: yAxisContent)
        .chartLegend(position: .bottom, spacing: 20)
        // Remove the custom color scale and let SwiftUI handle it automatically
        .frame(height: 200)
        .padding()
    }
    
    private func chartElements(for analytic: HabitAnalytics) -> some ChartContent {
        ForEach(weekdays, id: \.self) { day in
            LineMark(
                x: .value("Day", day),
                y: .value("Completions", analytic.weekdayDistribution[day] ?? 0)
            )
            .foregroundStyle(analytic.color)  // Directly use the color
            .symbol(.circle)
            .interpolationMethod(.catmullRom)
            
            AreaMark(
                x: .value("Day", day),
                y: .value("Completions", analytic.weekdayDistribution[day] ?? 0)
            )
            .foregroundStyle(analytic.color.opacity(0.1))  // Directly use the color with opacity
        }
    }
    
    private func xAxisContent() -> some AxisContent {
        AxisMarks(values: weekdays) { value in
            AxisValueLabel {
                if let day = value.as(String.self) {
                    Text(day.prefix(1))
                        .font(.caption2)
                }
            }
        }
    }
    
    private func yAxisContent() -> some AxisContent {
        AxisMarks(position: .leading) { value in
            AxisValueLabel {
                if let number = value.as(Double.self) {
                    Text("\(Int(number))%")
                        .font(.caption2)
                }
            }
            AxisGridLine()
        }
    }
    
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "chart.line.uptrend.xyaxis")
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

// MARK: - Preview Provider
#Preview {
    WeeklyProgressChart(analytics: [
        HabitAnalytics(
            id: UUID(),
            habitId: UUID(),
            title: "Exercise",
            emoji: "🏃‍♂️",
            color: .blue,
            completionRate: 85.7,
            currentStreak: 5,
            longestStreak: 7,
            totalCompletions: 20,
            weekdayDistribution: [
                "Mon": 85.7,
                "Tue": 71.4,
                "Wed": 57.1,
                "Thu": 42.9,
                "Fri": 28.6,
                "Sat": 14.3,
                "Sun": 0.0
            ],
            monthlyProgress: [:]
        ),
        HabitAnalytics(
            id: UUID(),
            habitId: UUID(),
            title: "Reading",
            emoji: "📚",
            color: .green,
            completionRate: 71.4,
            currentStreak: 3,
            longestStreak: 5,
            totalCompletions: 15,
            weekdayDistribution: [
                "Mon": 71.4,
                "Tue": 57.1,
                "Wed": 42.9,
                "Thu": 28.6,
                "Fri": 14.3,
                "Sat": 0.0,
                "Sun": 85.7
            ],
            monthlyProgress: [:]
        )
    ])
    .padding()
    .background(Color(.systemGroupedBackground))
}
