//
//  DataExportView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 11.12.24.
//
// Views/Dashboard/Components/DataExportView.swift

import SwiftUI

struct DataExportView: View {
    @ObservedObject var habitStore: HabitStore
    let analytics: [HabitAnalytics]
    @Environment(\.dismiss) private var dismiss
    @State private var selectedFormat = ExportFormat.json
    @State private var showingShareSheet = false
    @State private var exportedFileURL: URL?
    @State private var showingError = false
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Export Format") {
                    Picker("Format", selection: $selectedFormat) {
                        ForEach(ExportFormat.allCases, id: \.self) { format in
                            Text(format.rawValue).tag(format)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                
                Section("Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        PreviewRow(title: "Total Habits", value: "\(habitStore.habits.count)")
                        PreviewRow(title: "Total Completions", value: "\(habitStore.getTotalCompletions())")
                        PreviewRow(title: "Average Completion Rate", value: String(format: "%.1f%%", habitStore.getAverageCompletionRate()))
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: exportData) {
                        HStack {
                            Spacer()
                            Label("Export Data", systemImage: "square.and.arrow.up")
                            Spacer()
                        }
                    }
                }
            }
            .navigationTitle("Export Data")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .alert("Export Error", isPresented: $showingError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("An error occurred while exporting your data. Please try again.")
            }
            .sheet(isPresented: $showingShareSheet) {
                if let url = exportedFileURL {
                    ShareSheet(items: [url])
                        .onDisappear {
                            try? FileManager.default.removeItem(at: url)
                        }
                }
            }
        }
    }
    
    private func exportData() {
        let exportData: [String: Any] = [
            "exportDate": Date().ISO8601Format(),
            "habits": habitStore.habits.map { habit in
                [
                    "id": habit.id.uuidString,
                    "title": habit.title,
                    "description": habit.description,
                    "emoji": habit.emoji,
                    "completedDates": habit.completedDates.map { $0.ISO8601Format() }
                ] as [String: Any]
            },
            "analytics": analytics.map { analytic in
                [
                    "id": analytic.id.uuidString,
                    "habitId": analytic.habitId.uuidString,
                    "title": analytic.title,
                    "emoji": analytic.emoji,
                    "completionRate": analytic.completionRate,
                    "currentStreak": analytic.currentStreak,
                    "longestStreak": analytic.longestStreak,
                    "totalCompletions": analytic.totalCompletions
                ] as [String: Any]
            }
        ]
        
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
            let temporaryDirectory = FileManager.default.temporaryDirectory
            let fileURL = temporaryDirectory.appendingPathComponent("habit_data_\(Date().ISO8601Format()).json")
            try jsonData.write(to: fileURL)
            exportedFileURL = fileURL
            showingShareSheet = true
        } catch {
            print("Export error: \(error)")
            showingError = true
        }
    }
}

struct PreviewRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .fontWeight(.medium)
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: items,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

#Preview {
    DataExportView(
        habitStore: HabitStore(),
        analytics: []
    )
}
