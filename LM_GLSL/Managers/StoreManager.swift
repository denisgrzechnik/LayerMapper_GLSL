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
    case yearly = "yearly_subscription"
    
    var displayName: String {
        switch self {
        case .trial: return "30-dniowy Trial"
        case .monthly: return "Subskrypcja miesięczna"
        case .yearly: return "Subskrypcja roczna"
        }
    }
    
    var productID: String {
        switch self {
        case .trial: return "" // Trial nie ma product ID
        case .monthly: return "com.layermapper.glsl.subscription.monthly"
        case .yearly: return "com.layermapper.glsl.subscription.yearly"
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
    @Published private(set) var hasYearlySubscription = false
    
    // MARK: - Private Properties
    
    private let productIDs: [String] = [
        "com.layermapper.glsl.subscription.monthly",  // 11 EUR/miesiąc
        "com.layermapper.glsl.subscription.yearly",   // Roczna subskrypcja
        "com.layermapper.glsl.tip.88",                // Tip $100
        "com.layermapper.glsl.tip.111",               // Tip $150
        "com.layermapper.glsl.tip.222",               // Tip $200
        "com.layermapper.glsl.tip.444"                // Tip $400
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
            logDebug("🛒 Loading products: \(productIDs)", category: "STORE")
            logDebug("🛒 Requesting products from App Store...", category: "STORE")
            
            products = try await Product.products(for: productIDs)
            
            logDebug("✅ Loaded \(products.count) products from App Store", category: "STORE")
            
            if products.isEmpty {
                logError("⚠️ WARNING: No products returned from App Store! Check App Store Connect configuration.", category: "STORE")
                self.error = "No products available. Please check App Store Connect."
            }
            
            for product in products {
                logDebug("📦 Product: \(product.id) - \(product.displayName) - \(product.displayPrice)", category: "STORE")
            }
            
            // Log which products are missing
            let loadedIDs = Set(products.map { $0.id })
            let missingIDs = Set(productIDs).subtracting(loadedIDs)
            if !missingIDs.isEmpty {
                logError("⚠️ Missing products (not configured in App Store Connect?): \(missingIDs)", category: "STORE")
            }
            
        } catch {
            logError("❌ Failed to load products: \(error)", category: "STORE")
            logError("❌ Error details: \(error.localizedDescription)", category: "STORE")
            self.error = "Nie udało się załadować produktów: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    // MARK: - Purchase Functions
    
    func purchase(_ product: Product) async throws {
        logDebug("🛍️ Starting purchase: \(product.displayName) (\(product.id))", category: "STORE")
        
        do {
            let result = try await product.purchase()
            
            logDebug("📦 Purchase result received for: \(product.id)", category: "STORE")
            
            switch result {
            case .success(let verification):
                logDebug("✅ Purchase successful, verifying...", category: "STORE")
                
                let transaction = try checkVerified(verification)
                
                logDebug("✅ Transaction verified: \(transaction.id)", category: "STORE")
                logDebug("   Product: \(transaction.productID)", category: "STORE")
                logDebug("   Type: \(transaction.productType)", category: "STORE")
                logDebug("   Purchase Date: \(transaction.purchaseDate)", category: "STORE")
                
                // Update customer status to reflect new purchase
                await updateCustomerProductStatus()
                
                // Finish transaction
                await transaction.finish()
                
                logDebug("✅ Transaction finished successfully", category: "STORE")
                
            case .userCancelled:
                logDebug("❌ User cancelled purchase", category: "STORE")
                throw PurchaseError.userCancelled
                
            case .pending:
                logDebug("⏳ Purchase pending (awaiting approval)", category: "STORE")
                throw PurchaseError.pending
                
            @unknown default:
                logError("❌ Unknown purchase result", category: "STORE")
                throw PurchaseError.unknown
            }
        } catch let error as PurchaseError {
            // Re-throw our own errors
            throw error
        } catch {
            // Wrap system errors
            logError("❌ Purchase failed with system error: \(error)", category: "STORE")
            logError("   Error type: \(type(of: error))", category: "STORE")
            logError("   Error description: \(error.localizedDescription)", category: "STORE")
            throw PurchaseError.systemError(error)
        }
    }
    
    func restorePurchases() async {
        isLoading = true
        
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
            logDebug("✅ Purchases restored", category: "STORE")
        } catch {
            logError("Failed to restore purchases: \(error)", category: "STORE")
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
                    logError("Transaction verification failed: \(error)", category: "STORE")
                }
            }
        }
    }
    
    // MARK: - Customer Status Update
    
    func updateCustomerProductStatus() async {
        var purchasedIDs: Set<String> = []
        var hasPurchasedTip = false
        
        logDebug("🔄 Checking customer product status...", category: "STORE")
        
        // Reset states
        hasActiveSubscription = false
        hasYearlySubscription = false
        
        // Check CURRENT ENTITLEMENTS (active subscriptions and non-consumables)
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                
                logDebug("📋 Processing entitlement: \(transaction.productID) - Type: \(transaction.productType)", category: "STORE")
                
                switch transaction.productType {
                case .autoRenewable:
                    // Active subscription (includes free trial)
                    purchasedIDs.insert(transaction.productID)
                    hasActiveSubscription = true
                    
                    // Check if it's yearly subscription
                    if transaction.productID.contains("yearly") {
                        hasYearlySubscription = true
                        logDebug("✅ Yearly subscription found: \(transaction.productID)", category: "STORE")
                    } else {
                        logDebug("✅ Monthly subscription found: \(transaction.productID)", category: "STORE")
                    }
                    
                    // Log expiration details
                    if let expirationDate = transaction.expirationDate {
                        logDebug("   Expires: \(expirationDate)", category: "STORE")
                    }
                    if transaction.revocationDate == nil {
                        logDebug("   Status: Active (not revoked)", category: "STORE")
                    }
                    
                default:
                    logDebug("   Other product type: \(transaction.productType)", category: "STORE")
                }
            } catch {
                logError("❌ Failed to verify transaction: \(error)", category: "STORE")
            }
        }
        
        // Check ALL transactions for consumables (tips) - tips grant full access
        for await result in Transaction.all {
            do {
                let transaction = try checkVerified(result)
                
                if transaction.productType == .consumable && transaction.productID.contains("tip") {
                    hasPurchasedTip = true
                    logDebug("✅ Tip purchased (grants full access): \(transaction.productID)", category: "STORE")
                    break // Found tip, no need to continue
                }
            } catch {
                // Already logged in currentEntitlements loop
            }
        }
        
        // If user purchased a tip, grant full access (treat as yearly subscription)
        if hasPurchasedTip {
            hasYearlySubscription = true
            hasActiveSubscription = true
        }
        
        purchasedProductIDs = purchasedIDs
        
        // Final status
        logDebug("📊 Final status - Subscription: \(hasActiveSubscription), Yearly: \(hasYearlySubscription)", category: "STORE")
        logDebug("📊 Purchased IDs: \(purchasedIDs)", category: "STORE")
    }
    
    // MARK: - Access Control
    
    var hasFullAccess: Bool {
        return hasActiveSubscription
    }
    
    var needsPurchase: Bool {
        return !hasFullAccess
    }
    
    var licenseStatus: String {
        if hasYearlySubscription {
            return "Yearly Subscription"
        } else if hasActiveSubscription {
            return "Monthly Subscription"
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
    
    // MARK: - Tip Products Helper
    
    func tipProducts() -> [Product] {
        return products.filter { $0.id.contains("tip") }
            .sorted { p1, p2 in
                // Sort by price ascending
                return p1.price < p2.price
            }
    }
}
