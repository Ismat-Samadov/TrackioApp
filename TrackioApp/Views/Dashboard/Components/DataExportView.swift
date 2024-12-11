//
//  DataExportView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 11.12.24.
//
// Views/Dashboard/Components/DataExportView.swift

import SwiftUI
import UniformTypeIdentifiers

// MARK: - Supporting Types
struct ExportData {
    let data: Data
    let filename: String
    let utType: UTType
    
    var activityItems: [Any] {
        return [data, filename]
    }
}

struct ExportableData: Codable {
    let exportDate: Date
    let habits: [Habit]
    let analytics: [HabitAnalytics]
    
    var summary: Summary {
        Summary(
            totalHabits: habits.count,
            totalCompletions: habits.reduce(0) { $0 + $1.completedDates.count },
            averageCompletionRate: analytics.reduce(0.0) { $0 + $1.completionRate } / Double(max(analytics.count, 1))
        )
    }
    
    struct Summary: Codable {
        let totalHabits: Int
        let totalCompletions: Int
        let averageCompletionRate: Double
    }
}

enum ExportError: LocalizedError {
    case csvEncodingFailed
    case jsonEncodingFailed
    case dataPreparationFailed
    case exportFailed
    
    var errorDescription: String? {
        switch self {
        case .csvEncodingFailed:
            return "Failed to create CSV data"
        case .jsonEncodingFailed:
            return "Failed to create JSON data"
        case .dataPreparationFailed:
            return "Failed to prepare data for export"
        case .exportFailed:
            return "Failed to export data"
        }
    }
}

// MARK: - Share Controller
class ShareController: NSObject {
    static func share(data: Data, filename: String, utType: UTType, from view: UIView) -> UIActivityViewController {
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString + "_" + filename)
        
        do {
            try data.write(to: tempURL)
            
            let activityViewController = UIActivityViewController(
                activityItems: [tempURL],
                applicationActivities: nil
            )
            
            // Cleanup after sharing
            activityViewController.completionWithItemsHandler = { _, _, _, _ in
                try? FileManager.default.removeItem(at: tempURL)
            }
            
            if let popover = activityViewController.popoverPresentationController {
                popover.sourceView = view
                popover.sourceRect = CGRect(x: UIScreen.main.bounds.midX, y: UIScreen.main.bounds.midY, width: 0, height: 0)
                popover.permittedArrowDirections = []
            }
            
            return activityViewController
            
        } catch {
            // If file operations fail, fall back to direct data sharing
            return UIActivityViewController(
                activityItems: [data],
                applicationActivities: nil
            )
        }
    }
}

// MARK: - ShareSheet
struct ShareSheet: UIViewControllerRepresentable {
    let exportData: ExportData
    @Binding var isPresented: Bool
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = ShareController.share(
            data: exportData.data,
            filename: exportData.filename,
            utType: exportData.utType,
            from: UIView()
        )
        
        controller.completionWithItemsHandler = { _, _, _, _ in
            isPresented = false
        }
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Main View
struct DataExportView: View {
    @ObservedObject var habitStore: HabitStore
    let analytics: [HabitAnalytics]
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedFormat = ExportFormat.csv
    @State private var showingShareSheet = false
    @State private var exportData: ExportData?
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var isExporting = false
    
    enum ExportFormat: String, CaseIterable {
        case json = "JSON"
        case csv = "CSV"
        
        var fileExtension: String { rawValue.lowercased() }
        var utType: UTType {
            switch self {
            case .json: return .json
            case .csv: return .commaSeparatedText
            }
        }
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
                
                Section("Data Preview") {
                    VStack(alignment: .leading, spacing: 8) {
                        PreviewRow(title: "Total Habits", value: "\(habitStore.habits.count)")
                        PreviewRow(title: "Total Completions", value: "\(habitStore.getTotalCompletions())")
                        PreviewRow(title: "Average Completion Rate", value: String(format: "%.1f%%", habitStore.getAverageCompletionRate()))
                    }
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: prepareAndExportData) {
                        HStack {
                            Spacer()
                            Group {
                                if isExporting {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle())
                                } else {
                                    Label("Export Data", systemImage: "square.and.arrow.up")
                                }
                            }
                            Spacer()
                        }
                    }
                    .disabled(isExporting)
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
                Text(errorMessage)
            }
            .sheet(isPresented: $showingShareSheet) {
                if let exportData = exportData {
                    ShareSheet(exportData: exportData, isPresented: $showingShareSheet)
                }
            }
        }
    }
    
    private func prepareAndExportData() {
        isExporting = true
        
        Task {
            do {
                try await performExport()
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showingError = true
                }
            }
            
            await MainActor.run {
                isExporting = false
            }
        }
    }
    
    private func performExport() async throws {
        switch selectedFormat {
        case .json:
            try await exportAsJSON()
        case .csv:
            try await exportAsCSV()
        }
    }
    
    private func getFormattedTimestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HHmmss"
        return formatter.string(from: Date())
    }
    
    private func exportAsJSON() async throws {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        let exportObject = ExportableData(
            exportDate: Date(),
            habits: habitStore.habits,
            analytics: analytics
        )
        
        let jsonData = try encoder.encode(exportObject)
        let timestamp = getFormattedTimestamp()
        
        await MainActor.run {
            exportData = ExportData(
                data: jsonData,
                filename: "habits_export_\(timestamp).json",
                utType: .json
            )
            showingShareSheet = true
        }
    }
    
    private func exportAsCSV() async throws {
        var csvString = "ID,Habit ID,Title,Emoji,Completion Rate,Current Streak,Longest Streak,Total Completions\n"
        
        for analytic in analytics {
            let row = "\(analytic.id),\(analytic.habitId),\"\(analytic.title)\",\(analytic.emoji),\(analytic.completionRate),\(analytic.currentStreak),\(analytic.longestStreak),\(analytic.totalCompletions)\n"
            csvString.append(row)
        }
        
        guard let csvData = csvString.data(using: .utf8) else {
            throw ExportError.csvEncodingFailed
        }
        
        let timestamp = getFormattedTimestamp()
        
        await MainActor.run {
            exportData = ExportData(
                data: csvData,
                filename: "habits_export_\(timestamp).csv",
                utType: .commaSeparatedText
            )
            showingShareSheet = true
        }
    }
}

// MARK: - Preview Row
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

#Preview {
    DataExportView(
        habitStore: HabitStore(),
        analytics: []
    )
}
