//
//  StoreManager.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 12.12.24.
//
//private let productIdentifier = "art.TrackioApp.trackio.fullaccess"

// Store/StoreManager.swift
import StoreKit
import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published var hasFullAccess = false
    @Published private(set) var products: [Product] = []
    @Published var purchaseError: String?
    @Published var isLoading = false
    @Published private(set) var isTrialActive = false
    @Published private(set) var trialDaysRemaining: Int = 0
    
    private let productIdentifier = "com.yourapp.trackio.fullaccess"
    private let trialDuration: TimeInterval = 7 * 24 * 60 * 60 // 7 days in seconds
    
    init() {
        // Load saved access state
        hasFullAccess = UserDefaults.standard.bool(forKey: "hasFullAccess")
        checkTrialStatus()
        
        Task {
            await checkPurchaseStatus()
        }
    }
    
    private func checkTrialStatus() {
        let defaults = UserDefaults.standard
        
        // Check if trial has been started before
        if let trialStartDate = defaults.object(forKey: "trialStartDate") as? Date {
            let currentDate = Date()
            let trialEndDate = trialStartDate.addingTimeInterval(trialDuration)
            
            if currentDate < trialEndDate {
                isTrialActive = true
                trialDaysRemaining = Calendar.current.dateComponents([.day], from: currentDate, to: trialEndDate).day ?? 0
            } else {
                isTrialActive = false
                trialDaysRemaining = 0
            }
        } else {
            // Start trial if it hasn't been started before
            startTrial()
        }
        
        updateAccessStatus()
    }
    
    private func startTrial() {
        let defaults = UserDefaults.standard
        let trialStartDate = Date()
        defaults.set(trialStartDate, forKey: "trialStartDate")
        
        isTrialActive = true
        trialDaysRemaining = 7
        updateAccessStatus()
    }
    
    private func updateAccessStatus() {
        hasFullAccess = UserDefaults.standard.bool(forKey: "hasFullAccess") || isTrialActive
    }
    
    func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.productID == productIdentifier {
                hasFullAccess = true
                UserDefaults.standard.set(true, forKey: "hasFullAccess")
                return
            }
        }
        
        #if !DEBUG
        checkTrialStatus()
        #endif
    }
    
    func loadProducts() async {
        isLoading = true
        do {
            let storeProducts = try await Product.products(for: [productIdentifier])
            products = storeProducts
        } catch {
            purchaseError = "Failed to load products: \(error.localizedDescription)"
        }
        isLoading = false
    }
    
    func purchase() async {
        guard let product = products.first else {
            purchaseError = "Product not found"
            return
        }
        
        do {
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                guard case .verified(let transaction) = verification else {
                    purchaseError = "Invalid transaction"
                    return
                }
                
                await transaction.finish()
                hasFullAccess = true
                UserDefaults.standard.set(true, forKey: "hasFullAccess")
                
            case .userCancelled:
                purchaseError = "Purchase cancelled"
                
            case .pending:
                purchaseError = "Purchase pending"
                
            @unknown default:
                purchaseError = "Unknown error"
            }
            
        } catch {
            purchaseError = error.localizedDescription
        }
    }
    
    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await checkPurchaseStatus()
        } catch {
            purchaseError = "Failed to restore purchases: \(error.localizedDescription)"
        }
    }
    
    func clearError() {
        purchaseError = nil
    }
}
