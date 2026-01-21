//
//  SubscriptionView2.swift
//  storekit-subscribe-unit
//
//  Created by John Xu on 1/20/26.
//

import SwiftUI
import StoreKit

struct SubscriptionView2: View {
    @Environment(StoreViewModel.self) var storeVM
    @State var isPurchased = false
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [.indigo, .black],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            if storeVM.products.isEmpty {
                VStack(spacing: 20) {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    
                    Text("Loading subscriptions...")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .opacity(0.8)
                }
            } else {
                ScrollView {
                    VStack(spacing: 8) {
                        // Header Section
                        VStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 44))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [.yellow, .orange],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .padding(.top, 40)
                            
                            Text("Go Premium")
                                .font(.system(size: 28, weight: .bold))
                                .foregroundStyle(.white)
                            
                            Text("Unlock all features with a free trial (any saved games can be contined)")
                                .font(.subheadline)
                                .foregroundStyle(.white)
                                .opacity(0.7)
                                .multilineTextAlignment(.center)
                            
                        }
                        .padding(.horizontal)
                        
                        // Features Section
                        VStack(spacing: 4) {
                            FeatureRow(icon: "checkmark.circle.fill", text: "Ad-free experience")
                            FeatureRow(icon: "checkmark.circle.fill", text: "Replay and improve chess skills")
                            FeatureRow(icon: "checkmark.circle.fill", text: "Save games and play later")
                            FeatureRow(icon: "checkmark.circle.fill", text: "Cancel anytime")
                        }
                        .padding(.horizontal, 24)
                        
                        // Subscription Plans
                        VStack(spacing: 4) {
                            ForEach(storeVM.products) { product in
                                SubscriptionCard(
                                    product: product,
                                    isPopular: product.displayName.lowercased().contains("yearly"),
                                    action: {
                                        Task {
                                            await buy(product: product)
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 20)
                        
                        // Footer
                        VStack(spacing: 4) {
                            
                            Text("Auto-renewable. Cancel anytime.")
                                .font(.caption2)
                                .foregroundStyle(.white)
                                .opacity(0.5)
                        }
                        .padding(.bottom, 30)
                    }
                }
            }
        }
        .task {
            // Ensure products are loaded when view appears
            if storeVM.products.isEmpty {
                await storeVM.requireProducts()
            }
        }
    }
    
    func buy(product: Product) async {
        do {
            if try await storeVM.purchase(product) != nil {
                isPurchased = true
            }
        } catch {
            print("purchase failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Supporting Views

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(.green)
            
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.white)
            
            Spacer()
        }
    }
}

struct SubscriptionCard: View {
    let product: Product
    let isPopular: Bool
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Popular badge
            if isPopular {
                Text("MOST POPULAR")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.white)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 16)
                    .background(
                        LinearGradient(
                            colors: [.orange, .red],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .clipShape(Capsule())
                    .offset(y: 12)
                    .zIndex(1)
            }
            
            // Card content
            VStack(spacing: 16) {
                VStack(spacing: 8) {
                    Text(product.displayName)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.white)
                    
                    Text(product.description)
                        .font(.subheadline)
                        .foregroundStyle(.white)
                        .opacity(0.7)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, isPopular ? 24 : 20)
                
                // Price
                Text(product.displayPrice)
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
                
                // Subscribe button
                Button(action: action) {
                    Text("Start Free Trial")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(
                            LinearGradient(
                                colors: [.blue, .purple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 20)
            }
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white.opacity(0.1))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .strokeBorder(
                                isPopular ?
                                    LinearGradient(
                                        colors: [.orange, .red],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ) :
                                    LinearGradient(
                                        colors: [.white, .white],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                lineWidth: isPopular ? 2 : 1
                            )
                            .opacity(isPopular ? 1.0 : 0.2)
                    )
            )
        }
    }
}

#Preview {
    SubscriptionView()
}

