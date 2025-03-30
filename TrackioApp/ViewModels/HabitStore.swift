// ViewModels/FixedHabitStore.swift
// Replace your existing HabitStore.swift with this content

import SwiftUI
import Combine

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet { save() }
    }
    
    init() {
        loadHabits()
        if habits.isEmpty {
            createSampleHabits()
        }
    }
    
    // MARK: - CRUD Operations
    
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
        print("Toggle habit called for \(habitId) on date \(date)")
        
        guard let index = habits.firstIndex(where: { $0.id == habitId }) else {
            print("❌ Habit not found with ID: \(habitId)")
            return
        }
        
        // Remove this check to allow toggling any day
        // if !Calendar.current.isDateInToday(date) {
        //    print("❌ Date is not today: \(date)")
        //    return
        // }
        
        var habit = habits[index]
        let startOfDay = Calendar.current.startOfDay(for: date)
        
        print("Habit before toggle: \(habit.title), completed dates: \(habit.completedDates.count)")
        
        if habit.completedDates.contains(startOfDay) {
            print("✅ Removing date \(startOfDay) from completed dates")
            habit.completedDates.remove(startOfDay)
        } else {
            print("✅ Adding date \(startOfDay) to completed dates")
            habit.completedDates.insert(startOfDay)
        }
        
        habits[index] = habit
        print("Habit after toggle: \(habit.title), completed dates: \(habit.completedDates.count)")
    }
    
    // MARK: - Analytics
    
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
    
    func getLongestStreak(for habitId: UUID) -> Int {
        guard let habit = habits.first(where: { $0.id == habitId }) else { return 0 }
        
        let calendar = Calendar.current
        var longestStreak = 0
        var currentStreak = 0
        var currentDate = Date()
        
        while true {
            let startOfDay = calendar.startOfDay(for: currentDate)
            if habit.completedDates.contains(startOfDay) {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 0
            }
            
            guard let previousDay = calendar.date(byAdding: .day, value: -1, to: currentDate) else { break }
            currentDate = previousDay
            
            if calendar.dateComponents([.day], from: previousDay, to: Date()).day ?? 0 > 365 {
                break
            }
        }
        
        return longestStreak
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
    
    // Other methods unchanged...
    
    func getWeekdayDistribution(for habitId: UUID) -> [String: Double] {
        guard let habit = habits.first(where: { $0.id == habitId }) else { return [:] }
        
        let weekdays = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
        let calendar = Calendar.current
        var distribution: [String: Double] = [:]
        
        for (index, day) in weekdays.enumerated() {
            let completions = habit.completedDates.filter {
                calendar.component(.weekday, from: $0) - 1 == index
            }.count
            distribution[day] = Double(completions)
        }
        
        return distribution
    }
    
    func getMonthlyProgress(for habitId: UUID) -> [Date: Int] {
        guard let habit = habits.first(where: { $0.id == habitId }) else { return [:] }
        
        let calendar = Calendar.current
        let today = Date()
        guard let monthAgo = calendar.date(byAdding: .month, value: -1, to: today) else {
            return [:]
        }
        
        var progress: [Date: Int] = [:]
        var date = monthAgo
        
        while date <= today {
            let startOfDay = calendar.startOfDay(for: date)
            progress[startOfDay] = habit.completedDates.contains(startOfDay) ? 1 : 0
            
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: date) else { break }
            date = nextDay
        }
        
        return progress
    }
    
    func getBestPerformingHabit() -> Habit? {
        return habits.max { habit1, habit2 in
            getCompletionRate(for: habit1.id) < getCompletionRate(for: habit2.id)
        }
    }
    
    func getTotalCompletions() -> Int {
        habits.reduce(0) { $0 + $1.completedDates.count }
    }
    
    func getAverageCompletionRate(days: Int = 7) -> Double {
        let rates = habits.map { getCompletionRate(for: $0.id, days: days) }
        return rates.isEmpty ? 0 : rates.reduce(0, +) / Double(rates.count)
    }
    
    // MARK: - Persistence
    
    private func save() {
        guard let encoded = try? JSONEncoder().encode(habits) else { return }
        UserDefaults.standard.set(encoded, forKey: "habits.data")
    }
    
    private func loadHabits() {
        guard let data = UserDefaults.standard.data(forKey: "habits.data"),
              let decoded = try? JSONDecoder().decode([Habit].self, from: data) else { return }
        habits = decoded
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

// MARK: - Habit Updates Helper

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
