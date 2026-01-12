//
//  PurchaseView.swift
//  LM_GLSL
//
//  Widok zakupów i subskrypcji
//

import SwiftUI
import StoreKit

struct PurchaseView: View {
    @StateObject private var store = StoreManager.shared
    @Environment(\.dismiss) private var dismiss
    @State private var isPurchasing = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var selectedTipProduct: Product?
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 30) {
                    // Products
                    productsSection
                    
                    // Current status
                    if store.hasFullAccess {
                        currentStatusSection
                    }
                    
                    // Restore button
                    restoreButton
                    
                    // Legal
                    legalSection
                }
                .padding()
                .padding(.top, 40)
            }
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .interactiveDismissDisabled(true)
        // DISABLED - Tips feature removed for Apple review
        /*
        .task {
            // Auto-select first tip for better UX
            if selectedTipProduct == nil, let firstTip = store.tipProducts().first {
                selectedTipProduct = firstTip
            }
        }
        */
    }
    
    // MARK: - Products
    
    private var productsSection: some View {
        VStack(spacing: 16) {
            if store.isLoading {
                ProgressView()
                    .scaleEffect(1.5)
                    .frame(height: 200)
            } else if products.isEmpty || products.filter({ !$0.id.contains("tip") }).isEmpty {
                // No products available - show error message
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 50))
                        .foregroundColor(.orange)
                    
                    Text("Unable to load products")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("Please check your internet connection and try again.")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Button(action: {
                        Task {
                            await store.loadProducts()
                        }
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("Retry")
                        }
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 24)
                        .padding(.vertical, 12)
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                }
                .frame(height: 200)
            } else {
                // Show subscription FIRST, then lifetime (NOT tips!)
                let mainProducts = products.filter { product in
                    !product.id.contains("tip")
                }
                
                let sortedProducts = mainProducts.sorted { p1, p2 in
                    // Monthly subscription first
                    if p1.id.contains("monthly") { return true }
                    if p2.id.contains("monthly") { return false }
                    return false
                }
                
                ForEach(sortedProducts, id: \.id) { product in
                    ProductCard(
                        product: product,
                        isPurchased: store.isPurchased(product),
                        isPurchasing: isPurchasing
                    ) {
                        purchaseProduct(product)
                    }
                }
            }
            
            // Custom amount card - DISABLED FOR APPLE REVIEW
            // TODO: Re-enable after resolving StoreKit issues
            // customAmountCard
        }
    }
    
    private var products: [Product] {
        return store.products
    }
    
    // MARK: - Custom Amount Card
    
    // DISABLED FOR APPLE REVIEW - StoreKit consumables causing issues
    // TODO: Re-enable in version 1.1
    /*
    private var customAmountCard: some View {
        VStack(spacing: 12) {
            // Badge
            HStack {
                Spacer()
                Text("💚 SUPPORT US")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 4)
                    .background(Color(hexString: "00963C"))
                    .cornerRadius(20)
            }
            
            // Title
            Text("I LOVE THIS APP")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            // Description
            Text("Choose your amount - get Lifetime License!")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            // Tip amount buttons
            let tipProducts = store.tipProducts()
            if !tipProducts.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.flexible()),
                    GridItem(.flexible())
                ], spacing: 10) {
                    ForEach(tipProducts, id: \.id) { product in
                        TipButton(
                            product: product,
                            isSelected: selectedTipProduct?.id == product.id,
                            isPurchasing: isPurchasing
                        ) {
                            selectedTipProduct = product
                        }
                    }
                }
                .padding(.horizontal)
            }
            
            // Selection hint
            if selectedTipProduct == nil && !store.tipProducts().isEmpty {
                Text("👆 Select an amount above")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.gray)
                    .padding(.top, 4)
            }
            
            // Support button
            Button(action: {
                purchaseTip()
            }) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Image(systemName: "heart.fill")
                        Text("Support Now")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(selectedTipProduct != nil ? Color(hexString: "00963C") : Color.gray)
                .cornerRadius(12)
            }
            .disabled(isPurchasing || selectedTipProduct == nil)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color(hexString: "00963C"), lineWidth: 2)
        )
    }
    */
    
    // DISABLED FOR APPLE REVIEW
    /*
    private func purchaseTip() {
        guard let product = selectedTipProduct else { return }
        
        isPurchasing = true
        
        Task {
            do {
                // Purchase the tip - this will grant LIFETIME license
                try await store.purchase(product)
                // Success! Close the purchase screen
                dismiss()
            } catch PurchaseError.userCancelled {
                // User cancelled, no error
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isPurchasing = false
        }
    }
    */
    
    // MARK: - Current Status
    
    private var currentStatusSection: some View {
        VStack(spacing: 8) {
            HStack {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                Text(store.licenseStatus)
                    .foregroundColor(.white)
            }
            .font(.system(size: 16, weight: .medium))
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
    
    // MARK: - Restore Button
    
    private var restoreButton: some View {
        Button(action: {
            Task {
                await store.restorePurchases()
            }
        }) {
            Text("Restore Purchases")
                .font(.system(size: 14))
                .foregroundColor(.blue)
        }
    }
    
    // MARK: - Legal
    
    private var legalSection: some View {
        VStack(spacing: 8) {
            HStack(spacing: 16) {
                Button("Terms of Service") {
                    if let url = URL(string: "https://layermapper.com/terms") {
                        UIApplication.shared.open(url)
                    }
                }
                .foregroundColor(.gray)
                
                Button("Privacy Policy") {
                    if let url = URL(string: "https://layermapper.com/privacy") {
                        UIApplication.shared.open(url)
                    }
                }
                .foregroundColor(.gray)
            }
            .font(.system(size: 12))
            
            Text("Subscriptions renew automatically. You can cancel anytime in App Store settings.")
                .font(.system(size: 10))
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
        }
        .padding(.top, 20)
    }
    
    // MARK: - Purchase Action
    
    private func purchaseProduct(_ product: Product) {
        isPurchasing = true
        
        Task {
            do {
                try await store.purchase(product)
                dismiss()
            } catch PurchaseError.userCancelled {
                // User cancelled, no error
            } catch {
                errorMessage = error.localizedDescription
                showError = true
            }
            
            isPurchasing = false
        }
    }
}

// MARK: - Product Card

struct ProductCard: View {
    let product: Product
    let isPurchased: Bool
    let isPurchasing: Bool
    let onPurchase: () -> Void
    
    private var isYearly: Bool {
        product.id.contains("yearly")
    }
    
    private var isMonthly: Bool {
        product.id.contains("monthly")
    }
    
    var body: some View {
        VStack(spacing: 16) {
            // Badge
            if isYearly {
                HStack {
                    Spacer()
                    Text("BEST VALUE")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hexString: "FE144D"))
                        .cornerRadius(20)
                }
            } else if isMonthly {
                HStack {
                    Spacer()
                    Text("30 DAYS FREE TRIAL")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 4)
                        .background(Color(hexString: "0076C0"))
                        .cornerRadius(20)
                }
            }
            
            // Title
            Text(isYearly ? "Yearly Subscription" : "Monthly Subscription")
                .font(.system(size: 22, weight: .bold))
                .foregroundColor(.white)
            
            // Price display
            if isMonthly {
                VStack(spacing: 4) {
                    Text("First 30 days FREE")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(Color(hexString: "0076C0"))
                    
                    Text("Then \(product.displayPrice)/month")
                        .font(.system(size: 16))
                        .foregroundColor(.white)
                }
            } else {
                // Yearly subscription price
                VStack(spacing: 4) {
                    Text(product.displayPrice)
                        .font(.system(size: 36, weight: .bold))
                        .foregroundColor(.white)
                    
                    Text("per year")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                    
                    Text("Save 50% vs monthly!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(Color(hexString: "FE144D"))
                }
            }
            
            // Description
            VStack(spacing: 8) {
                Text("Full access to all LM_GLSL features")
                    .font(.system(size: 14))
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
                    .padding(.horizontal)
                
                // Important note for subscription
                Text("Cancel anytime. Renews automatically.")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(.orange)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
            
            // Button
            Button(action: onPurchase) {
                HStack {
                    if isPurchasing {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else if isPurchased {
                        Image(systemName: "checkmark.circle.fill")
                        Text("Subscribed")
                    } else {
                        Text(isMonthly ? "Start Free Trial" : "Subscribe Now")
                    }
                }
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(buttonBackgroundColor)
                .cornerRadius(12)
            }
            .disabled(isPurchased || isPurchasing)
        }
        .padding()
        .background(Color.white.opacity(0.05))
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(isYearly ? Color(hexString: "FE144D") : Color(hexString: "0076C0"), lineWidth: 2)
        )
    }
    
    private var buttonBackgroundColor: Color {
        if isYearly {
            return Color(hexString: "FE144D") // Red for yearly
        } else {
            return Color(hexString: "0076C0") // Blue for monthly
        }
    }
}

// MARK: - Tip Button

struct TipButton: View {
    let product: Product
    let isSelected: Bool
    let isPurchasing: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 4) {
                Text(product.displayPrice)
                    .font(.system(size: 20, weight: .bold))
                    .foregroundColor(.white)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(isSelected ? Color(hexString: "00963C") : Color.white.opacity(0.1))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hexString: "00963C") : Color.clear, lineWidth: 2)
            )
        }
        .disabled(isPurchasing)
    }
}

// MARK: - Preview

struct PurchaseView_Previews: PreviewProvider {
    static var previews: some View {
        PurchaseView()
            .preferredColorScheme(.dark)
    }
}
