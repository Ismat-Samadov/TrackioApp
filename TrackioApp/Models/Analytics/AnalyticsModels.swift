//
//  AnalyticsModels.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Models/Analytics/AnalyticsModels.swift
import SwiftUI

// MARK: - Habit Analytics Model
public struct HabitAnalytics: Identifiable, Codable, Equatable {
    public let id: UUID
    public let habitId: UUID
    public let title: String
    public let emoji: String
    public let color: Color
    public let completionRate: Double
    public let currentStreak: Int
    public let longestStreak: Int
    public let totalCompletions: Int
    public let weekdayDistribution: [String: Double]
    public let monthlyProgress: [Date: Int]
    
    // MARK: - Computed Properties
    public var averageCompletionsPerWeek: Double {
        Double(totalCompletions) / 7.0
    }
    
    public var bestPerformingDay: String? {
        weekdayDistribution.max { $0.value < $1.value }?.key
    }
    
    // MARK: - Coding Keys
    private enum CodingKeys: String, CodingKey {
        case id, habitId, title, emoji, completionRate, currentStreak
        case longestStreak, totalCompletions, weekdayDistribution, monthlyProgress
        case colorRed, colorGreen, colorBlue, colorOpacity
    }
    
    // MARK: - Initialization
    public init(id: UUID = UUID(),
         habitId: UUID,
         title: String,
         emoji: String,
         color: Color,
         completionRate: Double,
         currentStreak: Int,
         longestStreak: Int,
         totalCompletions: Int,
         weekdayDistribution: [String: Double],
         monthlyProgress: [Date: Int]) {
        self.id = id
        self.habitId = habitId
        self.title = title
        self.emoji = emoji
        self.color = color
        self.completionRate = completionRate
        self.currentStreak = currentStreak
        self.longestStreak = longestStreak
        self.totalCompletions = totalCompletions
        self.weekdayDistribution = weekdayDistribution
        self.monthlyProgress = monthlyProgress
    }
    
    // MARK: - Codable Implementation
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        habitId = try container.decode(UUID.self, forKey: .habitId)
        title = try container.decode(String.self, forKey: .title)
        emoji = try container.decode(String.self, forKey: .emoji)
        completionRate = try container.decode(Double.self, forKey: .completionRate)
        currentStreak = try container.decode(Int.self, forKey: .currentStreak)
        longestStreak = try container.decode(Int.self, forKey: .longestStreak)
        totalCompletions = try container.decode(Int.self, forKey: .totalCompletions)
        weekdayDistribution = try container.decode([String: Double].self, forKey: .weekdayDistribution)
        monthlyProgress = try container.decode([Date: Int].self, forKey: .monthlyProgress)
        
        let red = try container.decode(Double.self, forKey: .colorRed)
        let green = try container.decode(Double.self, forKey: .colorGreen)
        let blue = try container.decode(Double.self, forKey: .colorBlue)
        let opacity = try container.decode(Double.self, forKey: .colorOpacity)
        
        color = Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(habitId, forKey: .habitId)
        try container.encode(title, forKey: .title)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(completionRate, forKey: .completionRate)
        try container.encode(currentStreak, forKey: .currentStreak)
        try container.encode(longestStreak, forKey: .longestStreak)
        try container.encode(totalCompletions, forKey: .totalCompletions)
        try container.encode(weekdayDistribution, forKey: .weekdayDistribution)
        try container.encode(monthlyProgress, forKey: .monthlyProgress)
        
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var opacity: CGFloat = 0
        
        UIColor(color).getRed(&red, green: &green, blue: &blue, alpha: &opacity)
        
        try container.encode(red, forKey: .colorRed)
        try container.encode(green, forKey: .colorGreen)
        try container.encode(blue, forKey: .colorBlue)
        try container.encode(opacity, forKey: .colorOpacity)
    }
}

// MARK: - Dashboard Metrics Model
public struct AnalyticsMetrics: Codable, Equatable {
    public let totalHabits: Int
    public let activeHabits: Int
    public let averageCompletionRate: Double
    public let bestPerformingHabit: String
    public let totalCompletions: Int
    public let weeklyTrend: [String: Double]
    public let maxStreak: Int
    public let totalActiveStreaks: Int
    
    // MARK: - Computed Properties
    public var completionRateFormatted: String {
        String(format: "%.1f%%", averageCompletionRate)
    }
    
    public var hasActiveHabits: Bool {
        activeHabits > 0
    }
    
    public var weeklyTrendSorted: [(day: String, value: Double)] {
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        return weekdays.map { day in
            (day: day, value: weeklyTrend[day] ?? 0)
        }
    }
    
    // MARK: - Static Properties
    public static let empty = AnalyticsMetrics(
        totalHabits: 0,
        activeHabits: 0,
        averageCompletionRate: 0,
        bestPerformingHabit: "No habits yet",
        totalCompletions: 0,
        weeklyTrend: [:],
        maxStreak: 0,
        totalActiveStreaks: 0
    )
}

// MARK: - Analytics Period Enum
public enum AnalyticsPeriod: Int, CaseIterable, Identifiable, Codable, Hashable {
    case week = 7
    case month = 30
    case year = 365
    
    public var id: Int { rawValue }
    
    public var title: String {
        switch self {
        case .week: return "Last Week"
        case .month: return "Last Month"
        case .year: return "Last Year"
        }
    }
    
    public var days: Int { rawValue }
    
    public var shortTitle: String {
        switch self {
        case .week: return "1W"
        case .month: return "1M"
        case .year: return "1Y"
        }
    }
    
    public var analyticsTitle: String {
        "\(days)-Day Analysis"
    }
}

// MARK: - Helper Extensions
public extension HabitAnalytics {
    var completionRateFormatted: String {
        String(format: "%.1f%%", completionRate)
    }
    
    var streakText: String {
        "\(currentStreak) day\(currentStreak == 1 ? "" : "s")"
    }
    
    func weekdayCompletionRate(for day: String) -> Double {
        weekdayDistribution[day] ?? 0
    }
}
