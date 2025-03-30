//
//  TestHabitView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 30.03.25.
//

// Views/Debug/TestHabitView.swift
// Add this file to your project to test habit toggling

import SwiftUI

struct TestHabitView: View {
    @StateObject private var habitStore = HabitStore()
    @State private var selectedHabit: Habit? = nil
    
    var body: some View {
        VStack {
            Text("Habit Test View")
                .font(.title)
                .padding()
            
            List {
                ForEach(habitStore.habits) { habit in
                    VStack(alignment: .leading) {
                        Text(habit.title)
                            .font(.headline)
                        
                        Text("Completed dates: \(habit.completedDates.count)")
                            .font(.caption)
                        
                        Button("Toggle Today") {
                            habitStore.toggleHabit(habit.id, date: Date())
                        }
                        .buttonStyle(.bordered)
                        
                        Button("Select for Debug") {
                            selectedHabit = habit
                        }
                        .buttonStyle(.bordered)
                        
                        Text("Week Grid:")
                        WeekGridView(habit: habit, habitStore: habitStore)
                            .frame(height: 50)
                    }
                    .padding(.vertical)
                }
            }
            .listStyle(.plain)
            
            if let habit = selectedHabit {
                HabitDebugView(habitStore: habitStore, habit: habit)
            }
        }
    }
}

// Add a preview provider
struct TestHabitView_Previews: PreviewProvider {
    static var previews: some View {
        TestHabitView()
    }
}
