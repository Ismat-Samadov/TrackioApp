//
//  HabitsView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Habits/HabitsView.swift
import SwiftUI

struct HabitsView: View {
    // MARK: - Properties
    @ObservedObject var habitStore: HabitStore
    @State private var showingAddHabit = false
    @State private var habitToEdit: Habit?
    @State private var showingDeleteAlert = false
    @State private var habitToDelete: UUID?
    @State private var searchText = ""
    
    // MARK: - Computed Properties
    var filteredHabits: [Habit] {
        if searchText.isEmpty {
            return habitStore.habits
        }
        return habitStore.habits.filter { habit in
            habit.title.localizedCaseInsensitiveContains(searchText) ||
            habit.description.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            ScrollView {
                if habitStore.habits.isEmpty {
                    EmptyStateView(showingAddHabit: $showingAddHabit)
                } else {
                    LazyVStack(spacing: 16) {
                        ForEach(filteredHabits) { habit in
                            HabitRowView(
                                habit: habit,
                                habitStore: habitStore,
                                habitToEdit: $habitToEdit,
                                onDelete: {
                                    habitToDelete = habit.id
                                    showingDeleteAlert = true
                                }
                            )
                            .transition(.opacity.combined(with: .scale))
                        }
                    }
                    .padding()
                }
            }
            .searchable(text: $searchText, prompt: "Search habits...")
            .navigationTitle("Habit Tracker")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        withAnimation(.spring()) {
                            showingAddHabit = true
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .symbolRenderingMode(.hierarchical)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(habitStore: habitStore)
            }
            .sheet(item: $habitToEdit) { habit in
                EditHabitView(habitStore: habitStore, habit: habit)
            }
            .alert("Delete Habit", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    if let id = habitToDelete {
                        withAnimation {
                            habitStore.deleteHabit(id)
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this habit? This action cannot be undone.")
            }
        }
        .navigationViewStyle(.stack)
    }
}

// MARK: - Preview Provider
#Preview {
    HabitsView(habitStore: HabitStore())
}
