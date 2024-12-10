//
//  ChartCard.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// Views/Dashboard/Components/ChartCard.swift
import SwiftUI

struct ChartCard<Content: View>: View {
    // MARK: - Properties
    let title: String
    let content: () -> Content
    
    // MARK: - Initialization
    init(title: String, @ViewBuilder content: @escaping () -> Content) {
        self.title = title
        self.content = content
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
            
            content()
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
        )
    }
}

// MARK: - Preview Provider
#Preview {
    ScrollView {
        VStack(spacing: 20) {
            ChartCard(title: "Example Chart") {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.blue.opacity(0.2))
                    .frame(height: 200)
                    .overlay(
                        Text("Chart Content")
                            .foregroundColor(.secondary)
                    )
            }
            
            ChartCard(title: "Another Example") {
                VStack(spacing: 8) {
                    ForEach(0..<3) { index in
                        HStack {
                            Circle()
                                .fill(Color.blue)
                                .frame(width: 8, height: 8)
                            Text("Data point \(index + 1)")
                            Spacer()
                            Text("\(Int.random(in: 10...100))%")
                        }
                    }
                }
            }
        }
        .padding()
    }
}
