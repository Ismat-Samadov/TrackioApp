//
//  HabitDebugView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 30.03.25.
//

// Put this in Views/Debug/HabitDebugView.swift
import SwiftUI

struct HabitDebugView: View {
    @ObservedObject var habitStore: HabitStore
    let habit: Habit
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Habit Debug: \(habit.title)")
                .font(.headline)
            
            Text("ID: \(habit.id.uuidString)")
                .font(.caption)
            
            Text("Completed Dates Count: \(habit.completedDates.count)")
            
            ScrollView {
                VStack(alignment: .leading, spacing: 5) {
                    ForEach(Array(habit.completedDates), id: \.self) { date in
                        HStack {
                            Text(dateFormatter.string(from: date))
                            Spacer()
                            Button("Remove") {
                                removeDate(date)
                            }
                            .foregroundColor(.red)
                        }
                    }
                }
            }
            .frame(height: 200)
            
            Divider()
            
            // Test buttons for today
            let today = Date()
            let startOfToday = Calendar.current.startOfDay(for: today)
            
            VStack(alignment: .leading, spacing: 10) {
                Text("Debug Actions:")
                    .font(.headline)
                
                HStack {
                    Button("Add Today (Raw)") {
                        addTodayRaw()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Add Today (StartOfDay)") {
                        addTodayStartOfDay()
                    }
                    .buttonStyle(.bordered)
                }
                
                Text("Today: \(dateFormatter.string(from: today))")
                Text("Today (startOfDay): \(dateFormatter.string(from: startOfToday))")
                
                Text("Contains Today? \(containsToday() ? "Yes" : "No")")
                Text("Contains Today (startOfDay)? \(containsTodayStartOfDay() ? "Yes" : "No")")
                
                Divider()
                
                Button("Completely Reset Habit") {
                    resetHabit()
                }
                .foregroundColor(.red)
                .buttonStyle(.bordered)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.1))
        .cornerRadius(10)
        .padding()
    }
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter
    }()
    
    private func removeDate(_ date: Date) {
        var updatedHabit = habit
        updatedHabit.completedDates.remove(date)
        updateHabit(updatedHabit)
    }
    
    private func addTodayRaw() {
        var updatedHabit = habit
        updatedHabit.completedDates.insert(Date())
        updateHabit(updatedHabit)
    }
    
    private func addTodayStartOfDay() {
        var updatedHabit = habit
        let startOfToday = Calendar.current.startOfDay(for: Date())
        updatedHabit.completedDates.insert(startOfToday)
        updateHabit(updatedHabit)
    }
    
    private func containsToday() -> Bool {
        return habit.completedDates.contains(Date())
    }
    
    private func containsTodayStartOfDay() -> Bool {
        let startOfToday = Calendar.current.startOfDay(for: Date())
        return habit.completedDates.contains(startOfToday)
    }
    
    private func resetHabit() {
        var updatedHabit = habit
        updatedHabit.completedDates = []
        updateHabit(updatedHabit)
    }
    
    private func updateHabit(_ updatedHabit: Habit) {
        if let index = habitStore.habits.firstIndex(where: { $0.id == habit.id }) {
            var habits = habitStore.habits
            habits[index] = updatedHabit
            habitStore.habits = habits
        }
    }
}
