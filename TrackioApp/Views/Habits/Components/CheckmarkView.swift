//
//  CheckmarkView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Habits/Components/CheckmarkView.swift
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
