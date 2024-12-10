//
//  StreakBadge.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Habits/Components/StreakBadge.swift
import SwiftUI

struct StreakBadge: View {
    let streak: Int
    
    var body: some View {
        Text("\(streak)d 🔥")
            .font(.caption.bold())
            .foregroundColor(.orange)
            .padding(.horizontal, 8)
            .padding(.vertical, 2)
            .background(Color.orange.opacity(0.2))
            .cornerRadius(8)
    }
}
