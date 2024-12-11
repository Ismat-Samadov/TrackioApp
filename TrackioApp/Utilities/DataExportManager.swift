//
//  DataExportManager.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 11.12.24.
//
// Utilities/DataExportManager.swift

import Foundation
import SwiftUI

class DataExportManager {
    static func exportData(habits: [Habit], analytics: [HabitAnalytics]) -> Data? {
        let exportData = HabitExportData(
            exportDate: Date(),
            habits: habits,
            analytics: analytics
        )
        
        return try? JSONEncoder().encode(exportData)
    }
}

struct HabitExportData: Codable {
    let exportDate: Date
    let habits: [Habit]
    let analytics: [HabitAnalytics]
    
    var summary: ExportSummary {
        ExportSummary(
            totalHabits: habits.count,
            totalCompletions: habits.reduce(0) { $0 + $1.completedDates.count },
            averageCompletionRate: analytics.isEmpty ? 0 : analytics.reduce(0) { $0 + $1.completionRate } / Double(analytics.count)
        )
    }
}

struct ExportSummary: Codable {
    let totalHabits: Int
    let totalCompletions: Int
    let averageCompletionRate: Double
}
