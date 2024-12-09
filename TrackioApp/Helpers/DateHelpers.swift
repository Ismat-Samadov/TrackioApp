// Helpers/DateHelpers.swift
import Foundation

extension Date {
    var startOfDay: Date {
        Calendar.current.startOfDay(for: self)
    }
    
    static func dates(in range: Range<Date>) -> [Date] {
        var dates: [Date] = []
        var date = range.lowerBound
        while date < range.upperBound {
            dates.append(date)
            date = Calendar.current.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return dates
    }
}
