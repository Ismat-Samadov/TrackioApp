import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var habitStore = HabitStore()
    @StateObject private var notificationManager = NotificationManager()
    @State private var showingAddHabit = false
    @State private var habitToEdit: Habit?
    @State private var showingDeleteAlert = false
    @State private var habitToDelete: UUID?
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 16) {
                    ForEach(habitStore.habits) { habit in
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
            .navigationTitle("Habit Tracker")
            .toolbar {
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
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    notificationManager.requestAuthorization()
                }
            }
        }
    }
}

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
                    Text(habit.title).font(.headline)
                    HStack {
                        Text(habit.description)
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        if streak > 0 {
                            Text("\(streak)d 🔥")
                                .font(.caption.bold())
                                .foregroundColor(.orange)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color.orange.opacity(0.2))
                                .cornerRadius(8)
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
        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
            Button(role: .destructive, action: onDelete) {
                Label("Delete", systemImage: "trash")
            }
            Button { habitToEdit = habit } label: {
                Label("Edit", systemImage: "pencil")
            }
            .tint(.blue)
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

struct CheckmarkView: View {
    let date: Date
    let isCompleted: Bool
    let color: Color
    let action: () -> Void
    
    @State private var scale = 1.0
    private var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var body: some View {
        Button {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                scale = 1.3
                action()
            }
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6).delay(0.1)) {
                scale = 1.0
            }
        } label: {
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
                .scaleEffect(scale)
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
    @State private var selectedEmoji = "📝"
    @State private var showingAlert = false
    
    private let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink]
    private let emojis = ["📝", "🏃‍♂️", "📚", "🧘‍♂️", "🎵", "💪", "🎨", "🌱"]
    
    var body: some View {
        NavigationView {
            Form {
                Section("HABIT DETAILS") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    TextField("Description", text: $description)
                }
                
                Section("APPEARANCE") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojis, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 24))
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .stroke(selectedEmoji == emoji ? selectedColor : .clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedEmoji = emoji
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 2)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedColor = color
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section {
                    HStack {
                        Spacer()
                        Button("Create Habit") {
                            createHabit()
                        }
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .background(title.isEmpty ? Color.gray : selectedColor)
                        .cornerRadius(10)
                        .disabled(title.isEmpty)
                        Spacer()
                    }
                }
                .listRowBackground(Color.clear)
            }
            .navigationTitle("New Habit")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Invalid Title", isPresented: $showingAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Please enter a title for your habit.")
            }
        }
    }
    
    private func createHabit() {
        guard !title.isEmpty else {
            showingAlert = true
            return
        }
        
        withAnimation {
            let habit = Habit(
                title: title,
                description: description,
                emoji: selectedEmoji,
                color: selectedColor
            )
            habitStore.addHabit(habit)
            HapticManager.shared.trigger(.success)
            dismiss()
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
    @State private var selectedEmoji: String
    @State private var showingDeleteAlert = false
    
    private let colors: [Color] = [.blue, .green, .orange, .purple, .red, .pink]
    private let emojis = ["📝", "🏃‍♂️", "📚", "🧘‍♂️", "🎵", "💪", "🎨", "🌱"]
    
    init(habitStore: HabitStore, habit: Habit) {
        self.habitStore = habitStore
        self.habit = habit
        _title = State(initialValue: habit.title)
        _description = State(initialValue: habit.description)
        _selectedColor = State(initialValue: habit.color)
        _selectedEmoji = State(initialValue: habit.emoji)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("HABIT DETAILS") {
                    TextField("Title", text: $title)
                        .textInputAutocapitalization(.words)
                    TextField("Description", text: $description)
                }
                
                Section("APPEARANCE") {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(emojis, id: \.self) { emoji in
                                Text(emoji)
                                    .font(.system(size: 24))
                                    .padding(8)
                                    .background(
                                        Circle()
                                            .stroke(selectedEmoji == emoji ? selectedColor : .clear, lineWidth: 2)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedEmoji = emoji
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(colors, id: \.self) { color in
                                Circle()
                                    .fill(color)
                                    .frame(width: 30, height: 30)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 2)
                                            .opacity(selectedColor == color ? 1 : 0)
                                    )
                                    .onTapGesture {
                                        withAnimation(.spring(response: 0.3)) {
                                            selectedColor = color
                                        }
                                    }
                            }
                        }
                        .padding(.vertical, 8)
                    }
                }
                
                Section {
                    Button(role: .destructive) {
                        showingDeleteAlert = true
                    } label: {
                        HStack {
                            Spacer()
                            Text("Delete Habit")
                            Spacer()
                        }
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
                            emoji: selectedEmoji,
                            color: selectedColor
                        )
                        habitStore.updateHabit(habit.id, with: updates)
                        HapticManager.shared.trigger(.success)
                        dismiss()
                    }
                    .disabled(title.isEmpty)
                }
            }
            .alert("Delete Habit", isPresented: $showingDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    habitStore.deleteHabit(habit.id)
                    dismiss()
                }
            } message: {
                Text("Are you sure you want to delete this habit? This action cannot be undone.")
            }
        }
    }
}
