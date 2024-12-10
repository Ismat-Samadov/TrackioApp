//
//  HabitStats.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Models/Analytics/HabitStats.swift
import Foundation

struct HabitStats: Identifiable {
    let id: UUID
    let habitId: UUID
    let completionRate: Double
    let currentStreak: Int
    let longestStreak: Int
    let totalCompletions: Int
    let weekdayDistribution: [String: Double]
    let monthlyProgress: [Date: Int]
}

struct DashboardMetrics {
    let totalHabits: Int
    let averageCompletionRate: Double
    let bestPerformingHabit: String
    let totalCompletions: Int
    let weeklyTrend: [String: Double]
}
