//
//  WeekGridView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Habits/Components/WeekGridView.swift
import SwiftUI

struct WeekGridView: View {
    let habit: Habit
    let habitStore: HabitStore
    private let weekDays = ["Mon", "Tue", "Wed", "Thu", "Fri", "Sat", "Sun"]
    
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
                    CheckmarkView(
                        date: date,
                        isCompleted: habit.completedDates.contains(date.startOfDay),
                        color: habit.color
                    ) {
                        habitStore.toggleHabit(habit.id, date: date)
                        HapticManager.shared.trigger(.success)
                    }
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
