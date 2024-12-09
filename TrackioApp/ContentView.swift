import SwiftUI

struct ContentView: View {
    @StateObject private var habitStore = HabitStore()
    @State private var showingAddHabit = false
    
    var body: some View {
        NavigationView {
            HabitListView(habitStore: habitStore)
                .navigationTitle("Habit Tracker")
                .navigationBarItems(trailing:
                    Button(action: { showingAddHabit = true }) {
                        Image(systemName: "plus")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.blue)
                    }
                )
                .sheet(isPresented: $showingAddHabit) {
                    AddHabitView(habitStore: habitStore)
                }
        }
    }
}

struct AddHabitView: View {
    @ObservedObject var habitStore: HabitStore
    @Environment(\.dismiss) var dismiss
    
    @State private var title = ""
    @State private var description = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Habit Title", text: $title)
                TextField("Description", text: $description)
            }
            .navigationTitle("New Habit")
            .navigationBarItems(
                leading: Button("Cancel") {
                    dismiss()
                },
                trailing: Button("Add") {
                    let habit = Habit(
                        title: title,
                        description: description,
                        emoji: "📝"
                    )
                    habitStore.habits.append(habit)
                    dismiss()
                }
                .disabled(title.isEmpty)
            )
        }
    }
}
