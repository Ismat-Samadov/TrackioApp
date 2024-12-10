//
//  AnalyticsHelpers.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Helpers/AnalyticsHelpers.swift
import Foundation

extension Date {
    func startOfWeek(using calendar: Calendar = .current) -> Date {
        calendar.dateComponents([.calendar, .yearForWeekOfYear, .weekOfYear], from: self).date!
    }
}

extension Collection where Element == HabitAnalytics {
    var averageCompletionRate: Double {
        guard !isEmpty else { return 0 }
        return reduce(0) { $0 + $1.completionRate } / Double(count)
    }
}
