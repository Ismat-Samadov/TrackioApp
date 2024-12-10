// ViewModels/HabitStore.swift

import SwiftUI
 
class HabitStore: ObservableObject  {
    @Published var habits: [Habit] = [] {
        didSet { save() }
    }
    
    init() {
        loadHabits()
        if habits.isEmpty {
            createSampleHabits()
        }
    }
    
    // CRUD Operations
    func addHabit(_ habit: Habit) {
        habits.append(habit)
    }
    
    func updateHabit(_ habitId: UUID, with updates: Habit.Updates) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else { return }
        var habit = habits[index]
        habit.apply(updates)
        habits[index] = habit
    }
    
    func deleteHabit(_ habitId: UUID) {
        habits.removeAll { $0.id == habitId }
    }
    
    func toggleHabit(_ habitId: UUID, date: Date) {
        guard let index = habits.firstIndex(where: { $0.id == habitId }),
              Calendar.current.isDateInToday(date) else { return }
        
        var habit = habits[index]
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        if habit.completedDates.contains(startOfDay) {
            habit.completedDates.remove(startOfDay)
        } else {
            habit.completedDates.insert(startOfDay)
        }
        
        habits[index] = habit
    }
    
    // Persistence
    private func save() {
        guard let encoded = try? JSONEncoder().encode(habits) else { return }
        UserDefaults.standard.set(encoded, forKey: "habits.data")
    }
    
    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: "habits.data"),
              let decoded = try? JSONDecoder().decode([Habit].self, from: data) else { return }
        habits = decoded
    }
    
    // Analytics
    func getStreak(for habitId: UUID) -> Int {
        guard let habit = habits.first(where: { $0.id == habitId }) else { return 0 }
        
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: Date())
        var streak = 0
        
        while habit.completedDates.contains(currentDate) {
            streak += 1
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
        }
        
        return streak
    }
    
    func getCompletionRate(for habitId: UUID, days: Int = 7) -> Double {
        guard let habit = habits.first(where: { $0.id == habitId }) else { return 0 }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -(days - 1), to: today) else { return 0 }
        
        var date = startDate
        var completedDays = 0
        
        while date <= today {
            if habit.completedDates.contains(date) {
                completedDays += 1
            }
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDay
        }
        
        return Double(completedDays) / Double(days) * 100
    }
    
    private func createSampleHabits() {
        let samples = [
            Habit(title: "Exercise", description: "Stay active everyday", emoji: "🏃‍♂️", color: .green),
            Habit(title: "Reading", description: "Read everyday", emoji: "📚", color: .blue),
            Habit(title: "Meditation", description: "Mindfulness practice", emoji: "🧘‍♂️", color: .purple),
            Habit(title: "Sing", description: "Sing everyday", emoji: "🎵", color: .orange)
        ]
        habits = samples
    }
}

// Helper extension for Habit updates
extension Habit {
    struct Updates {
        var title: String?
        var description: String?
        var emoji: String?
        var color: Color?
    }
    
    mutating func apply(_ updates: Updates) {
        if let title = updates.title { self.title = title }
        if let description = updates.description { self.description = description }
        if let emoji = updates.emoji { self.emoji = emoji }
        if let color = updates.color { self.color = color }
    }
}
