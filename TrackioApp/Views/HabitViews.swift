import SwiftUI

struct HabitListView: View {
    @ObservedObject var habitStore: HabitStore
    
    var body: some View {
        List(habitStore.habits) { habit in
            HabitRowView(habit: habit, habitStore: habitStore)
        }
        .listStyle(.plain)
    }
}

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var habitStore: HabitStore
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(habit.title)
                .font(.headline)
            Text(habit.description)
                .font(.caption)
                .foregroundColor(.gray)
            
            HStack(spacing: 8) {
                ForEach(getDaysOfWeek(), id: \.self) { date in
                    VStack(spacing: 4) {
                        Text(formatWeekDay(date))
                            .font(.caption2)
                            .foregroundColor(.gray)
                        CheckmarkView(
                            date: date,
                            isCompleted: habit.completedDates.contains(date.startOfDay),
                            action: { habitStore.toggleHabit(habit, for: date) }
                        )
                    }
                }
            }
        }
        .padding(.vertical, 8)
    }
    
    private func getDaysOfWeek() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0...6).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)
        }
    }
    
    private func formatWeekDay(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }
}

struct CheckmarkView: View {
    let date: Date
    let isCompleted: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Circle()
                .strokeBorder(isCompleted ? Color.blue : Color.gray.opacity(0.3), lineWidth: 1.5)
                .frame(width: 30, height: 30)
                .overlay(
                    Image(systemName: "checkmark")
                        .foregroundColor(.blue)
                        .opacity(isCompleted ? 1 : 0)
                )
        }
    }
}
