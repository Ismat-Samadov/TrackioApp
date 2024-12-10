//
//  EditHabitView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//
// Views/Habits/EditHabitView.swift
import SwiftUI

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
