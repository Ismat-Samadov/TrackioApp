// Views/Habits/Components/CheckmarkView.swift
// Replace your existing CheckmarkView.swift with this content

import SwiftUI

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
            print("CheckmarkView button tapped for date: \(date)")
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
        // Remove the disabled(!isToday) to allow toggling any day
        // .disabled(!isToday)
        // Change the opacity to be consistent
        .opacity(isToday ? 1 : 0.6)
    }
}
