//
//  StoreManager.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 12.12.24.
//

// Store/StoreManager.swift

import StoreKit
import SwiftUI

@MainActor
class StoreManager: ObservableObject {
    static let shared = StoreManager()
    
    @Published private(set) var hasFullAccess = false
    @Published private(set) var products: [Product] = []
    @Published var purchaseError: String? // Changed to be publicly writable
    @Published var isLoading = false
    
    private let productIdentifier = "com.yourapp.trackio.fullaccess"
    
    init() {
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
                hasFullAccess = true
                return
            }
        }
        
        hasFullAccess = false
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
