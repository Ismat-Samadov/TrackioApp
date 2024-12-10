//
//  HabitAnalyticRowView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Dashboard/Components/HabitAnalyticRowView.swift
import SwiftUI

struct HabitAnalyticRowView: View {
    let analytic: HabitAnalytics
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(analytic.emoji)
                Text(analytic.title)
                    .font(.headline)
                Spacer()
                Text(analytic.completionRateFormatted)
                    .foregroundColor(.secondary)
            }
            
            HStack {
                Label("\(analytic.currentStreak) streak", systemImage: "flame.fill")
                    .foregroundColor(.orange)
                Spacer()
                Label("\(analytic.totalCompletions) total", systemImage: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            .font(.caption)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 3)
        )
    }
}
