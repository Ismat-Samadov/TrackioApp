// Views/Habits/Components/WeekGridView.swift
// Replace your existing WeekGridView.swift with this content

import SwiftUI

struct WeekGridView: View {
    let habit: Habit
    let habitStore: HabitStore
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
    @State private var triggerRefresh = false
    
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                ForEach(weekDays, id: \.self) { day in
                    Text(day)
                        .font(.caption2)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                }
            }
            
            HStack {
                ForEach(getDaysOfWeek(), id: \.self) { date in
                    let startOfDay = Calendar.current.startOfDay(for: date)
                    let isCompleted = habit.completedDates.contains(startOfDay)
                    
                    CheckmarkView(
                        date: date,
                        isCompleted: isCompleted,
                        color: habit.color
                    ) {
                        print("WeekGridView action triggered for date: \(date)")
                        habitStore.toggleHabit(habit.id, date: date)
                        HapticManager.shared.trigger(.success)
                        
                        // Force a redraw after toggle
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                            triggerRefresh.toggle()
                        }
                    }
                    .id("\(habit.id)-\(date)-\(isCompleted)-\(triggerRefresh)")
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func getDaysOfWeek() -> [Date] {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        let weekStart = calendar.date(byAdding: .day, value: 2-weekday, to: today)!
        
        return (0...6).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: weekStart)
        }
    }
}
