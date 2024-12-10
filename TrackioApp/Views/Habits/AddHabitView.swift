//
//  AddHabitView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Habits/AddHabitView.swift
import SwiftUI

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
