//
//  StoreManager.swift
//  LM_GLSL
//
//  System zarządzania zakupami in-app i subskrypcjami
//

import Foundation
import StoreKit

enum PurchaseError: Error {
    case failedVerification
    case systemError(Error)
    case userCancelled
    case pending
    case unknown
    
    var localizedDescription: String {
        switch self {
        case .failedVerification:
            return "Weryfikacja zakupu nie powiodła się"
        case .systemError(let error):
            return error.localizedDescription
        case .userCancelled:
            return "Transakcja została anulowana"
        case .pending:
            return "Transakcja oczekuje na zatwierdzenie"
        case .unknown:
            return "Wystąpił nieznany błąd"
        }
    }
}

enum LicenseType: String, Codable {
    case trial = "trial"
    case monthly = "monthly_subscription"
    
    var displayName: String {
        switch self {
        case .trial: return "30-dniowy Trial"
        case .monthly: return "Subskrypcja miesięczna"
        }
    }
    
    var productID: String {
        switch self {
        case .trial: return "" // Trial nie ma product ID
        case .monthly: return "com.lmglsl.subscription.monthly"
        }
    }
}

@MainActor
class StoreManager: ObservableObject {
    
    static let shared = StoreManager()
    
    // MARK: - Published Properties
    
    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: String?
    @Published private(set) var hasCompletedInitialCheck = false
    
    // License state
    @Published private(set) var hasActiveSubscription = false
    
    // MARK: - Private Properties
    
    private let productIDs: [String] = [
        "com.lmglsl.subscription.monthly"  // 11 USD/miesiąc z 30-dniowym free trial
    ]
    
    private var updateListenerTask: Task<Void, Error>?
    private var transactionListener: Task<Void, Error>?
    
    // MARK: - Initialization
    
    private init() {
        // Start transaction listener
        transactionListener = listenForTransactions()
        
        Task {
            await loadProducts()
            await updateCustomerProductStatus()
            
            // Mark initial check as complete
            DispatchQueue.main.async {
                self.hasCompletedInitialCheck = true
            }
        }
    }
    
    deinit {
        transactionListener?.cancel()
        updateListenerTask?.cancel()
    }
    
    // MARK: - Products Loading
    
    func loadProducts() async {
        isLoading = true
        error = nil
        
        do {
            print("🛒 Loading products: \(productIDs)")
            print("🛒 Requesting products from App Store...")
            
            products = try await Product.products(for: productIDs)
            
            print("✅ Loaded \(products.count) products from App Store")
            
            if products.isEmpty {
                print("⚠️ WARNING: No products returned from App Store! Check App Store Connect configuration.")
                self.error = "No products available. Please check App Store Connect."
            }
            
            for product in products {
                print("📦 Product: \(product.id) - \(product.displayName) - \(product.displayPrice)")
            }
            
            // Log which products are missing
            let loadedIDs = Set(products.map { $0.id })
            let missingIDs = Set(productIDs).subtracting(loadedIDs)
            if !missingIDs.isEmpty {
                print("⚠️ Missing products (not configured in App Store Connect?): \(missingIDs)")
            }
            
        } catch {
            print("❌ Failed to load products: \(error)")
            print("❌ Error details: \(error.localizedDescription)")
            self.error = "Nie udało się załadować produktów: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Functions
    
    func purchase(_ product: Product) async throws {
        print("🛍️ Starting purchase: \(product.displayName) (\(product.id))")
        
        do {
            let result = try await product.purchase()
            
            print("📦 Purchase result received for: \(product.id)")
            
            switch result {
            case .success(let verification):
                print("✅ Purchase successful, verifying...")
                
                let transaction = try checkVerified(verification)
                
                print("✅ Transaction verified: \(transaction.id)")
                print("   Product: \(transaction.productID)")
                print("   Type: \(transaction.productType)")
                print("   Purchase Date: \(transaction.purchaseDate)")
                
                // Update customer status to reflect new purchase
                await updateCustomerProductStatus()
                
                // Finish transaction
                await transaction.finish()
                
                print("✅ Transaction finished successfully")
                
            case .userCancelled:
                print("❌ User cancelled purchase")
                throw PurchaseError.userCancelled
                
            case .pending:
                print("⏳ Purchase pending (awaiting approval)")
                throw PurchaseError.pending
                
            @unknown default:
                print("❌ Unknown purchase result")
                throw PurchaseError.unknown
            }
        } catch let error as PurchaseError {
            // Re-throw our own errors
            throw error
        } catch {
            // Wrap system errors
            print("❌ Purchase failed with system error: \(error)")
            print("   Error type: \(type(of: error))")
            print("   Error description: \(error.localizedDescription)")
            throw PurchaseError.systemError(error)
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
            print("✅ Purchases restored")
        } catch {
            print("Failed to restore purchases: \(error)")
            self.error = "Nie udało się przywrócić zakupów"
        }
        
        isLoading = false
    }
    
    // MARK: - Transaction Listener
    
    private func listenForTransactions() -> Task<Void, Error> {
        return Task {
            for await result in Transaction.updates {
                do {
                    let transaction = try checkVerified(result)
                    
                    await updateCustomerProductStatus()
                    
                    await transaction.finish()
                } catch {
                    print("Transaction verification failed: \(error)")
                }
            }
        }
    }
    
    // MARK: - Customer Status Update
    
    func updateCustomerProductStatus() async {
        var purchasedIDs: Set<String> = []
        
        print("🔄 Checking customer product status...")
        
        // Reset states
        hasActiveSubscription = false
        
        // Check CURRENT ENTITLEMENTS (active subscriptions)
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                print("📋 Processing entitlement: \(transaction.productID) - Type: \(transaction.productType)")
                
                switch transaction.productType {
                case .autoRenewable:
                    // Active subscription (includes free trial)
                    purchasedIDs.insert(transaction.productID)
                    hasActiveSubscription = true
                    print("✅ Active subscription found: \(transaction.productID)")
                    
                    // Log expiration details
                    if let expirationDate = transaction.expirationDate {
                        print("   Expires: \(expirationDate)")
                    }
                    if transaction.revocationDate == nil {
                        print("   Status: Active (not revoked)")
                    }
                    
                default:
                    print("   Other product type: \(transaction.productType)")
                }
            } catch {
                print("❌ Failed to verify transaction: \(error)")
            }
        }
        
        purchasedProductIDs = purchasedIDs
        
        // Final status
        print("📊 Final status - Subscription: \(hasActiveSubscription)")
        print("📊 Purchased IDs: \(purchasedIDs)")
    }
    
    // MARK: - Access Control
    
    var hasFullAccess: Bool {
        return hasActiveSubscription
    }
    
    var needsPurchase: Bool {
        return !hasFullAccess
    }
    
    var licenseStatus: String {
        if hasActiveSubscription {
            return "Active Subscription"
        } else {
            return "No License"
        }
    }
    
    // MARK: - Helper Functions
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
    
    // MARK: - Product Helpers
    
    func product(for licenseType: LicenseType) -> Product? {
        return products.first { $0.id == licenseType.productID }
    }
    
    func isPurchased(_ product: Product) -> Bool {
        return purchasedProductIDs.contains(product.id)
    }
}
