# 💰 In-App Purchases Implementation - LM_GLSL

## Przegląd Systemu

LM_GLSL używa **StoreKit 2** (nowoczesny API Apple) do zarządzania zakupami i subskrypcjami.

### Produkty:

1. **Subskrypcja miesięczna** - `com.layermapper.glsl.subscription.monthly`
   - Cena: €11.00/miesiąc
   - Auto-renewable subscription
   - 30-dniowy bezpłatny trial
   - Odnawia się automatycznie

2. **Licencja Lifetime** - `com.layermapper.glsl.lifetime`
   - Cena: €44.00 jednorazowo
   - Non-consumable purchase
   - Kupujesz raz, masz na zawsze

3. **Tipy** (opcjonalne):
   - `com.layermapper.glsl.tip.88` - $100
   - `com.layermapper.glsl.tip.111` - $150
   - `com.layermapper.glsl.tip.222` - $200
   - `com.layermapper.glsl.tip.444` - $400
   - Dają Lifetime License

---

## 🏗️ Architektura

### Klasy i Pliki:

```
Managers/
  └── StoreManager.swift          # Główny manager zakupów (Singleton)

Views/
  └── PurchaseView.swift          # Interfejs zakupów
  └── ContentView.swift           # Integracja z paywall

Utilities/
  └── Logger.swift                # System logowania

Extensions/
  └── Color+Hex.swift             # Rozszerzenie kolorów
```

### Flow Użytkownika:

```
App Launch
    ↓
StoreManager inicjalizacja
    ↓
Sprawdź status licencji
    ↓
┌─────────────────────────────┐
│ Czy ma Lifetime lub Active  │
│ Subscription?               │
└─────────────────────────────┘
    ↓ NIE
Pokaż PurchaseView (paywall)
    ↓
Użytkownik kupuje licencję
    ↓
Pełny dostęp ✅
```

---

## 🔑 Kluczowe Właściwości StoreManager

### Published Properties (Observable):

```swift
@Published var hasActiveSubscription: Bool     // Czy subskrypcja jest aktywna
@Published var hasLifetimeLicense: Bool        // Czy ma lifetime
@Published var products: [Product]             // Produkty z App Store
@Published var isLoading: Bool                 // Loading state
@Published var hasCompletedInitialCheck: Bool  // Czy zakończono początkowe sprawdzenie
```

### Computed Properties:

```swift
var hasFullAccess: Bool           // Czy ma dostęp (license/subscription)
var needsPurchase: Bool           // Czy musi kupić
var licenseStatus: String         // Status licencji (dla UI)
```

---

## 💻 Użycie w Kodzie

### Sprawdzanie Dostępu:

```swift
import SwiftUI

struct MyFeatureView: View {
    @StateObject private var store = StoreManager.shared
    
    var body: some View {
        if store.hasFullAccess {
            // Pokaż pełną funkcjonalność
            FullFeatureView()
        } else {
            // Pokaż paywall
            PurchaseView()
        }
    }
}
```

### Wykonywanie Zakupu:

```swift
Button("Kup Lifetime") {
    Task {
        if let product = store.product(for: .lifetime) {
            try await store.purchase(product)
        }
    }
}
```

### Przywracanie Zakupów:

```swift
Button("Przywróć zakupy") {
    Task {
        await store.restorePurchases()
    }
}
```

---

## 🧪 Testowanie

### StoreKit Configuration:
1. Otwórz `LM_GLSL.storekit` w Xcode
2. Włącz "Enable StoreKit Testing" w scheme
3. Testuj zakupy w symulatorze

### Resetowanie zakupów:
- W symulatorze: Features → Reset Content and Settings
- Lub użyj StoreKit Testing Dashboard w Xcode

---

## 📱 Wymagania App Store Connect

Przed publikacją upewnij się, że:
1. Produkty są skonfigurowane w App Store Connect z tymi samymi ID
2. Podpisane umowy dla płatnych aplikacji
3. Informacje bankowe są wypełnione
4. Testy sandbox działają poprawnie

---

## 🔗 Linki prawne

- Terms of Service: https://layermapper.com/terms
- Privacy Policy: https://layermapper.com/privacy
