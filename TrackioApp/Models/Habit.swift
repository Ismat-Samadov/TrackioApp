// Models/Habit.swift
import SwiftUI

struct Habit: Identifiable, Codable {
    var id = UUID()
    var title: String
    var description: String
    var emoji: String
    var completedDates: Set<Date> = []
    var color: Color = .blue
    
    private enum CodingKeys: String, CodingKey {
        case id, title, description, emoji, completedDates
    }
}
