// Views/Components/LoadingView.swift
import SwiftUI

struct LoadingView: View {
    @State private var rotation: Double = 0
    @State private var opacity: Double = 0.3
    
    var body: some View {
        VStack(spacing: 20) {
            // Animated logo
            ZStack {
                // Background circle
                Circle()
                    .stroke(Color.blue.opacity(0.3), lineWidth: 3)
                    .frame(width: 70, height: 70)
                
                // Rotating circle
                Circle()
                    .trim(from: 0, to: 0.7)
                    .stroke(Color.blue, lineWidth: 3)
                    .frame(width: 70, height: 70)
                    .rotationEffect(.degrees(rotation))
                
                // App icon
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 30))
                    .foregroundColor(.blue)
            }
            .onAppear {
                withAnimation(.linear(duration: 2).repeatForever(autoreverses: false)) {
                    rotation = 360
                }
            }
            
            // App name
            Text("Trackio")
                .font(.title)
                .fontWeight(.bold)
            
            // Loading text
            Text("Loading...")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .opacity(opacity)
                .onAppear {
                    withAnimation(.easeInOut(duration: 1).repeatForever()) {
                        opacity = 0.7
                    }
                }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemBackground))
    }
}

#Preview {
    LoadingView()
}
