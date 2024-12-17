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
    
    @Published private(set) var isPurchased = false
    @Published private(set) var products: [Product] = []
    @Published var purchaseError: String?
    @Published private(set) var isLoading = false
    
    private let productIdentifier = "com.yourapp.trackio.fullaccess"
    
    private init() {
        // Load saved purchase state
        isPurchased = UserDefaults.standard.bool(forKey: "isPurchased")
        
        Task {
            await checkPurchaseStatus()
        }
    }
    
    func checkPurchaseStatus() async {
        for await result in Transaction.currentEntitlements {
            guard case .verified(let transaction) = result else {
                continue
            }
            
            if transaction.productID == productIdentifier {
                isPurchased = true
                UserDefaults.standard.set(true, forKey: "isPurchased")
                return
            }
        }
        
        #if !DEBUG
        isPurchased = false
        UserDefaults.standard.set(false, forKey: "isPurchased")
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
            purchaseError = "Product not available"
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
                isPurchased = true
                UserDefaults.standard.set(true, forKey: "isPurchased")
                
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
