// Models/Habit.swift
// Replace your existing Habit.swift with this content

import SwiftUI

struct Habit: Identifiable, Codable, Equatable {
    var id = UUID()
    var title: String
    var description: String
    var emoji: String
    var completedDates: Set<Date> = []
    var color: Color = .blue
    
    static func == (lhs: Habit, rhs: Habit) -> Bool {
        lhs.id == rhs.id
    }
    
    enum CodingKeys: String, CodingKey {
        case id, title, description, emoji, completedDates
        case colorRed, colorGreen, colorBlue, colorOpacity
    }
    
    init(title: String, description: String, emoji: String, color: Color = .blue, completedDates: Set<Date> = []) {
        self.title = title
        self.description = description
        self.emoji = emoji
        self.color = color
        self.completedDates = completedDates
    }
    
    // Decoder init
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        description = try container.decode(String.self, forKey: .description)
        emoji = try container.decode(String.self, forKey: .emoji)
        
        // Handle dates properly by ensuring they're all startOfDay
        let rawDates = try container.decode(Set<Date>.self, forKey: .completedDates)
        let calendar = Calendar.current
        completedDates = Set(rawDates.map { calendar.startOfDay(for: $0) })
        
        // If we have color components, decode them. Otherwise use default blue.
        if container.contains(.colorRed) {
            let red = try container.decode(Double.self, forKey: .colorRed)
            let green = try container.decode(Double.self, forKey: .colorGreen)
            let blue = try container.decode(Double.self, forKey: .colorBlue)
            let opacity = try container.decode(Double.self, forKey: .colorOpacity)
            color = Color(.sRGB, red: red, green: green, blue: blue, opacity: opacity)
        } else {
            color = .blue
        }
    }
    
    // Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        try container.encode(description, forKey: .description)
        try container.encode(emoji, forKey: .emoji)
        try container.encode(completedDates, forKey: .completedDates)
        
        // Encode color components
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
