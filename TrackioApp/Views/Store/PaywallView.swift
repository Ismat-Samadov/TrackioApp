//
//  PaywallView.swift
//  TrackioApp
//
//  Created by Ismat Samadov on 12.12.24.
//

// Views/Store/PaywallView.swift
import SwiftUI
import StoreKit

struct PaywallView: View {
    @StateObject private var storeManager = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 24) {
            // Header
            VStack(spacing: 16) {
                Image(systemName: "star.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.blue)
                
                Text("Unlock Trackio")
                    .font(.title)
                    .fontWeight(.bold)
                
                Text("One-time purchase to unlock all features")
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
            }
            .padding(.top, 40)
            
            // Features
            VStack(alignment: .leading, spacing: 16) {
                FeatureRow(icon: "infinity", title: "Unlimited Habits", description: "Track as many habits as you want")
                FeatureRow(icon: "chart.bar.fill", title: "Detailed Analytics", description: "Get insights into your progress")
                FeatureRow(icon: "icloud.fill", title: "Data Backup", description: "Keep your data safe")
                FeatureRow(icon: "bell.fill", title: "Reminders", description: "Set custom reminders for your habits")
                FeatureRow(icon: "square.and.arrow.up", title: "Export Data", description: "Export your data anytime")
            }
            .padding(.horizontal)
            
            Spacer()
            
            // Purchase Button
            if let product = storeManager.products.first {
                Button {
                    Task {
                        await storeManager.purchase()
                    }
                } label: {
                    Text("Buy Now - \(product.displayPrice)")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            } else {
                ProgressView()
            }
            
            // Restore Purchases
            Button("Restore Previous Purchase") {
                Task {
                    await storeManager.restorePurchases()
                }
            }
            .font(.footnote)
            .padding(.bottom)
        }
        .alert("Purchase Error", isPresented: Binding(
            get: { storeManager.purchaseError != nil },
            set: { if !$0 { storeManager.clearError() } }
        )) {
            Button("OK", role: .cancel) {
                storeManager.clearError()
            }
        } message: {
            if let error = storeManager.purchaseError {
                Text(error)
            }
        }
        .onAppear {
            Task {
                await storeManager.loadProducts()
            }
        }
        .onChange(of: storeManager.isPurchased) { _, isPurchased in
            if isPurchased {
                dismiss()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundColor(.blue)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
}
