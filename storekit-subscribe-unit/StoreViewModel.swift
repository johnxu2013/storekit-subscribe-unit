//
//  StoreViewModel.swift
//  storekit-subscribe-unit
//
//  Created by John Xu on 1/18/26.
//

import Foundation
import StoreKit
import Observation

typealias RenewalState = StoreKit.Product.SubscriptionInfo.RenewalState

@Observable
class StoreViewModel {
    var products: [Product] = []
    var purchasedSubscriptions: [Product] = []
    var subscriptionGroupStatus: RenewalState?
    
    private let productIds: [String] = ["com.jackson.store.yearly", "com.jackson.store.monthly"]
    
    var updateListenerTask: Task<Void, Error>? = nil
    
    init() {
        
        updateListenerTask = listenerForPurchasedSubscriptions()
        
        Task {
            await self.requireProducts()
            
            await updateCustomerProductStatus()
        }
    }
    
    deinit {
        updateListenerTask?.cancel()
    }
    
    func listenerForPurchasedSubscriptions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    while true {
                        let transaction = try await self.checkVerified(result)
                        //Deliver products to the user
                        await self.updateCustomerProductStatus()
                        await transaction.finish()
                    }
                } catch {
                    print("transaction error: \(error)")
                }
            }
        }
    }
    
    func requireProducts() async {
        do {
            products = try await Product.products(for: self.productIds)
            print(products)
        } catch {
            print("Failed product request from app store server: \(error)")
        }
    }
    
    func purchase(_ product: Product) async throws-> Transaction? {
        let result = try await product.purchase()
        
        switch result {
        case .success(let verification):
            let transaction = try checkVerified(verification)
            
            //The transaction is verified. Deliver content to the user.
//            await self.purchasedSubscriptions.append(product)
            
            await updateCustomerProductStatus()
            
            //Always finish a transaction
            await transaction.finish()
            
            return transaction
        case .userCancelled, .pending:
            return nil
        @unknown default:
            return nil
        }
//        return try await PurchaseManager.shared.purchase(product: product)
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
    
    @MainActor
    func updateCustomerProductStatus() async {
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                switch transaction.productType {
                case .autoRenewable:
                    if let subscription = products.first(where: { $0.id == transaction.productID} ) {
                        purchasedSubscriptions.append(subscription)
                    }
                default:
                    break
                }
                
                await transaction.finish()
            } catch {
                print("failed updating products: \(error)")
            }
        }
    }
    
}
