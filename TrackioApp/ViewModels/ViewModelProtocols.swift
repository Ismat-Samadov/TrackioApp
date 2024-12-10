//
//  ViewModelProtocols.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 10.12.24.
//

// ViewModels/ViewModelProtocols.swift
protocol AnalyticsViewModel {
    var averageCompletionRate: Double { get }
    var activeStreaks: Int { get }
    var bestStreak: Int { get }
}
