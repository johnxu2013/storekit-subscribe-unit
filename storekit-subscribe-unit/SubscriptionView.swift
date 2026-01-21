//
//  SubscriptionView.swift
//  storekit-subscribe-unit
//
//  Created by John Xu on 1/20/26.
//

import SwiftUI
import StoreKit

struct SubscriptionView: View {
    @Environment(StoreViewModel.self) var storeVM
    @State var isPurchased = false
    
    var body: some View {
        Group {
            Section("Upgrade to Premium") {
                if storeVM.products.isEmpty {
                    ProgressView("Loading subscriptions...")
                        .padding()
                    
                    // Debug information
                    Text("Products count: \(storeVM.products.count)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(storeVM.products) { product in
                        Button(action: {
                            Task {
                                await buy(product: product)
                            }
                        })
                        {
                            VStack {
                                HStack {
                                    Text(product.displayName)
                                    Text(product.displayPrice)
                                }
                                Text(product.description)
                            }.padding()
                        }
                        .foregroundStyle(.white)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(15.0)
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

#Preview {
    SubscriptionView()
}
