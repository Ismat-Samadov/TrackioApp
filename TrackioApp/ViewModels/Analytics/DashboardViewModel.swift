//
//  DashboardViewModel.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// ViewModels/Analytics/DashboardViewModel.swift
import SwiftUI
import Combine

final class DashboardViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published private(set) var metrics: AnalyticsMetrics?
    @Published private(set) var habitAnalytics: [HabitAnalytics] = []
    @Published var selectedPeriod: AnalyticsPeriod = .week {
        didSet {
            if oldValue != selectedPeriod {
                calculateMetrics()
            }
        }
    }
    
    // MARK: - Private Properties
    private let habitStore: HabitStore
    private var cancellables = Set<AnyCancellable>()
    private let calendar = Calendar.current
    
    // MARK: - Initialization
    init(habitStore: HabitStore) {
        self.habitStore = habitStore
        setupSubscriptions()
        calculateMetrics()
    }
    
    // MARK: - Setup
    private func setupSubscriptions() {
        habitStore.$habits
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.calculateMetrics()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Metrics Calculation
    private func calculateMetrics() {
        Task { @MainActor in
            // Calculate per-habit analytics
            habitAnalytics = habitStore.habits.map { habit in
                HabitAnalytics(
                    id: UUID(),
                    habitId: habit.id,
                    title: habit.title,
                    emoji: habit.emoji,
                    color: habit.color,
                    completionRate: habitStore.getCompletionRate(for: habit.id, days: selectedPeriod.days),
                    currentStreak: habitStore.getStreak(for: habit.id),
                    longestStreak: habitStore.getLongestStreak(for: habit.id),
                    totalCompletions: habit.completedDates.count,
                    weekdayDistribution: habitStore.getWeekdayDistribution(for: habit.id),
                    monthlyProgress: habitStore.getMonthlyProgress(for: habit.id)
                )
            }
            
            // Calculate overall metrics
            metrics = AnalyticsMetrics(
                totalHabits: habitStore.habits.count,
                activeHabits: calculateActiveHabits(),
                averageCompletionRate: habitStore.getAverageCompletionRate(days: selectedPeriod.days),
                bestPerformingHabit: findBestPerformingHabit(),
                totalCompletions: habitStore.getTotalCompletions(),
                weeklyTrend: calculateWeeklyTrend(),
                maxStreak: calculateMaxStreak(),
                totalActiveStreaks: calculateActiveStreaks()
            )
        }
    }
    
    // MARK: - Helper Methods
    private func calculateActiveHabits() -> Int {
        habitStore.habits.filter { habit in
            habitStore.getStreak(for: habit.id) > 0
        }.count
    }
    
    private func findBestPerformingHabit() -> String {
        guard let bestHabit = habitStore.getBestPerformingHabit() else {
            return "No habits yet"
        }
        return bestHabit.title
    }
    
    private func calculateWeeklyTrend() -> [String: Double] {
        var trend: [String: Double] = [:]
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE"
        
        let today = calendar.startOfDay(for: Date())
        
        for dayOffset in (0..<7).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let dayString = dateFormatter.string(from: date)
            let startOfDay = calendar.startOfDay(for: date)
            
            let completionCount = Double(habitStore.habits.filter { habit in
                habit.completedDates.contains(startOfDay)
            }.count)
            
            let completionRate = habitStore.habits.isEmpty ? 0 : (completionCount / Double(habitStore.habits.count)) * 100
            trend[dayString] = completionRate
        }
        
        return trend
    }
    
    private func calculateMaxStreak() -> Int {
        habitStore.habits.reduce(0) { currentMax, habit in
            max(currentMax, habitStore.getLongestStreak(for: habit.id))
        }
    }
    
    private func calculateActiveStreaks() -> Int {
        habitStore.habits.filter { habit in
            habitStore.getStreak(for: habit.id) > 0
        }.count
    }
}

// MARK: - Public Interface
extension DashboardViewModel {
    func getHabitAnalytics(for habitId: UUID) -> HabitAnalytics? {
        habitAnalytics.first { $0.habitId == habitId }
    }
    
    func getCompletionTrend(for habit: Habit) -> [(date: Date, completed: Bool)] {
        var trend: [(date: Date, completed: Bool)] = []
        let today = calendar.startOfDay(for: Date())
        
        for dayOffset in (0..<selectedPeriod.days).reversed() {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let startOfDay = calendar.startOfDay(for: date)
            trend.append((date: startOfDay, completed: habit.completedDates.contains(startOfDay)))
        }
        
        return trend
    }
    
    func refreshMetrics() {
        calculateMetrics()
    }
}
