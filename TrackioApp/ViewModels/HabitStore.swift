import SwiftUI

class HabitStore: ObservableObject {
    @Published var habits: [Habit] = [] {
        didSet {
            save()
        }
    }
    
    init() {
        loadHabits()
    }
    
    func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: "Habits"),
           let decoded = try? JSONDecoder().decode([Habit].self, from: data) {
            habits = decoded
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(habits) {
            UserDefaults.standard.set(encoded, forKey: "Habits")
        }
    }
    
    func toggleHabit(_ habit: Habit, for date: Date) {
        guard Calendar.current.isDateInToday(date) else { return }
        
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            var updatedHabit = habits[index]
            if updatedHabit.completedDates.contains(date.startOfDay) {
                updatedHabit.completedDates.remove(date.startOfDay)
            } else {
                updatedHabit.completedDates.insert(date.startOfDay)
            }
            habits[index] = updatedHabit
        }
    }
}
