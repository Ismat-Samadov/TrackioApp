import SwiftUI

struct ContentView: View {
    @StateObject private var habitStore = HabitStore()
    @State private var showingAddHabit = false
    @State private var habitToEdit: Habit?
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(habitStore.habits) { habit in
                        HabitRowView(habit: habit, habitStore: habitStore)
                            .contextMenu {
                                Button("Edit") { habitToEdit = habit }
                                Button("Delete", role: .destructive) {
                                    habitStore.deleteHabit(habit.id)
                                }
                            }
                    }
                }
                .padding()
            }
            .navigationTitle("Habit Tracker")
            .toolbar {
                Button { showingAddHabit = true } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            .sheet(isPresented: $showingAddHabit) {
                AddHabitView(habitStore: habitStore)
            }
            .sheet(item: $habitToEdit) { habit in
                EditHabitView(habitStore: habitStore, habit: habit)
            }
        }
    }
}

// Subviews
struct HabitRowView: View {
    let habit: Habit
    @ObservedObject var habitStore: HabitStore
    @Binding var habitToEdit: Habit?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Existing habit row content
            HStack {
                Circle()
                    .fill(habit.color)
                    .frame(width: 40, height: 40)
                    .overlay(Text(habit.emoji))
                
                VStack(alignment: .leading) {
                    Text(habit.title).font(.headline)
                    Text(habit.description).font(.caption).foregroundColor(.gray)
                }
                
                Spacer()
                
                Menu {
                    Button("Edit") { habitToEdit = habit }
                    Button("Delete", role: .destructive) {
                        habitStore.deleteHabit(habit.id)
                    }
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            
            WeekGridView(habit: habit, habitStore: habitStore)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8)
        .swipeActions(edge: .trailing) {
            Button(role: .destructive) {
                habitStore.deleteHabit(habit.id)
            } label: {
                Label("Delete", systemImage: "trash")
            }
            
            Button {
                habitToEdit = habit
            } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
        }
        .contextMenu {
            Button("Edit") { habitToEdit = habit }
            Button("Delete", role: .destructive) {
                habitStore.deleteHabit(habit.id)
            }
        }
    }
}

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
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }
    
    private func getDaysOfWeek() -> [Date] {
        let calendar = Calendar.current
        let today = Date()
        return (0...6).compactMap { dayOffset in
            calendar.date(byAdding: .day, value: dayOffset, to: today)
        }
    }
}

struct CheckmarkView: View {
    let date: Date
    let isCompleted: Bool
    let color: Color
    let action: () -> Void
    
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button(action: action) {
            Circle()
                .strokeBorder(isCompleted ? color : .gray.opacity(0.3), lineWidth: 1.5)
                .background(Circle().fill(isCompleted ? color : .clear))
                .frame(width: 32, height: 32)
                .overlay(
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.white)
                        .opacity(isCompleted ? 1 : 0)
                )
        }
        .disabled(!isToday)
        .opacity(isToday ? 1 : 0.6)
    }
}

struct AddHabitView: View {
    @ObservedObject var habitStore: HabitStore
    @Environment(\.dismiss) var dismiss
    @State private var title = ""
    @State private var description = ""
    @State private var selectedColor: Color = .blue
    @State private var emoji = "📝"
    
    private let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink]
    
    var body: some View {
        NavigationView {
            Form {
                Section("HABIT DETAILS") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section("APPEARANCE") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                ColorCircleView(color: color, isSelected: color == selectedColor)
                                    .onTapGesture { selectedColor = color }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let habit = Habit(
                            title: title,
                            description: description,
                            emoji: emoji,
                            color: selectedColor
                        )
                        habitStore.addHabit(habit)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct EditHabitView: View {
    @ObservedObject var habitStore: HabitStore
    let habit: Habit
    @Environment(\.dismiss) var dismiss
    
    @State private var title: String
    @State private var description: String
    @State private var selectedColor: Color
    @State private var emoji: String
    
    private let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink]
    
    init(habitStore: HabitStore, habit: Habit) {
        self.habitStore = habitStore
        self.habit = habit
        _title = State(initialValue: habit.title)
        _description = State(initialValue: habit.description)
        _selectedColor = State(initialValue: habit.color)
        _emoji = State(initialValue: habit.emoji)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("HABIT DETAILS") {
                    TextField("Title", text: $title)
                    TextField("Description", text: $description)
                }
                
                Section("APPEARANCE") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                ColorCircleView(color: color, isSelected: color == selectedColor)
                                    .onTapGesture { selectedColor = color }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
            }
            .navigationTitle("Edit Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updates = Habit.Updates(
                            title: title,
                            description: description,
                            emoji: emoji,
                            color: selectedColor
                        )
                        habitStore.updateHabit(habit.id, with: updates)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
        }
    }
}

struct ColorCircleView: View {
    let color: Color
    let isSelected: Bool
    
    var body: some View {
        Circle()
            .fill(color)
            .frame(width: 30, height: 30)
            .overlay(
                Circle()
                    .stroke(.white, lineWidth: 2)
                    .opacity(isSelected ? 1 : 0)
            )
    }
}
