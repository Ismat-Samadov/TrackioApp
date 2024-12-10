//
//  HabitRowView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Habits/Components/HabitRowView.swift
import SwiftUI

struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var habitStore: HabitStore
    @Binding var habitToEdit: Habit?
    let onDelete: () -> Void
    
    private var streak: Int {
        habitStore.getStreak(for: habit.id)
    }
    
    private var completionRate: Double {
        habitStore.getCompletionRate(for: habit.id) / 100
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                // Habit Icon and Progress
                ZStack {
                    Circle()
                        .fill(habit.color.opacity(0.2))
                        .frame(width: 44, height: 44)
                    
                    Circle()
                        .trim(from: 0, to: completionRate)
                        .stroke(habit.color, lineWidth: 3)
                        .frame(width: 44, height: 44)
                        .rotationEffect(.degrees(-90))
                    
                    Text(habit.emoji)
                        .font(.system(size: 20))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(habit.title)
                        .font(.headline)
                    HStack {
                        Text(habit.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if streak > 0 {
                            StreakBadge(streak: streak)
                        }
                    }
                }
                
                Spacer()
                
                Menu {
                    Button("Edit", systemImage: "pencil") { habitToEdit = habit }
                    Button("Delete", systemImage: "trash", role: .destructive, action: onDelete)
                } label: {
                    Image(systemName: "ellipsis.circle.fill")
                        .symbolRenderingMode(.hierarchical)
                        .foregroundStyle(.secondary)
                        .font(.system(size: 24))
                }
            }
            
            WeekGridView(habit: habit, habitStore: habitStore)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 2)
        )
    }
}

// MARK: - Preview Provider
#Preview {
    HabitRowView(
        habit: Habit(
            title: "Exercise",
            description: "Daily workout",
            emoji: "🏃‍♂️",
            color: .blue
        ),
        habitStore: HabitStore(),
        habitToEdit: .constant(nil),
        onDelete: {}
    )
    .padding()
}
