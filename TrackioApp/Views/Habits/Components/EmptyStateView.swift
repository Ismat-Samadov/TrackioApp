//
//  EmptyStateView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Habits/Components/EmptyStateView.swift
import SwiftUI

struct EmptyStateView: View {
    @Binding var showingAddHabit: Bool
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "checklist")
                .font(.system(size: 60))
                .foregroundColor(.blue)
                .padding()
            
            Text("No Habits Yet")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Start tracking your daily habits by adding your first habit.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal)
            
            Button {
                showingAddHabit = true
            } label: {
                Label("Add Your First Habit", systemImage: "plus")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
        .frame(maxHeight: .infinity)
    }
}
