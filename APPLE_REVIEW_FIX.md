# 🚨 Apple Review Issue - Free Trial Not Displayed

## Problem Report

**Date:** 13 stycznia 2026  
**Submission ID:** e42ad634-536e-44f5-ba0e-14115f53cf14  
**Guideline:** 2.1 - Performance - App Completeness

**Issue:** 
> "The free trial was not reflected on the purchase prompt"

---

## 🔍 Zidentyfikowane Problemy

### 1. **Błędny Product ID w StoreKit Config**

**Znaleziono:**
```
LM_GLSL.storekit: "com.layermapper.glsl.subscription.monthly"
```

**Powinno być (zgodnie z kodem):**
```
StoreManager.swift: "com.lmglsl.subscription.monthly"
```

❌ **NIEZGODNOŚĆ!** Product ID w `.storekit` ≠ Product ID w kodzie

### 2. **Dodatkowe Produkty Nie Używane w Kodzie**

Plik `.storekit` zawiera:
- ❌ Tips (com.layermapper.glsl.tip.*)
- ❌ Yearly subscription (com.layermapper.glsl.subscription.yearly)

Kod (`StoreManager.swift`) używa tylko:
- ✅ Monthly subscription: `com.lmglsl.subscription.monthly`

### 3. **Brak `displayPrice` w introductoryOffer**

W `.storekit`:
```json
"introductoryOffer" : {
  "internalID" : "GLSL_INTRO001",
  "numberOfPeriods" : 1,
  "paymentMode" : "free",
  "subscriptionPeriod" : "P1M"
  // ❌ BRAK "displayPrice": "0.00"
}
```

---

## ✅ Rozwiązanie

### Krok 1: Napraw Product ID

Masz **dwie opcje**:

#### Opcja A: Zmień kod (łatwiejsze)
W `StoreManager.swift` zmień:
```swift
// PRZED:
private let productIDs: [String] = [
    "com.lmglsl.subscription.monthly"
]

// PO:
private let productIDs: [String] = [
    "com.layermapper.glsl.subscription.monthly"
]
```

I zmień wszystkie wystąpienia w kodzie.

#### Opcja B: Zmień StoreKit config (zalecane)
Napraw `LM_GLSL.storekit` aby zgadzał się z kodem.

**ZALECAM OPCJĘ B** - kod jest poprawny, config nie.

### Krok 2: Napraw StoreKit Configuration File

Użyj poprawionej wersji która będzie stworzona poniżej.

### Krok 3: Sprawdź App Store Connect

W App Store Connect dla produktu `com.lmglsl.subscription.monthly`:

1. **Subscription Group:**
   - ✅ Musi istnieć i być aktywna

2. **Introductory Offer:**
   - ✅ Type: Free Trial
   - ✅ Duration: 1 Month (30 days)
   - ✅ Price: $0.00
   - ✅ Status: **Ready to Submit** (nie Draft!)

3. **Review Information:**
   - ✅ Dodaj screenshot pokazujący Free Trial info
   - ✅ W Notes for Review napisz: "30-day free trial is configured"

### Krok 4: Test w Sandbox

Przed resubmission:
1. Usuń app z urządzenia testowego
2. Wyczyść Purchase History dla Sandbox Tester
3. Zainstaluj fresh build
4. Sprawdź czy prompt pokazuje "Free Trial"

---

## 📝 Poprawiony Plik StoreKit

Stworzę teraz poprawiony plik `LM_GLSL.storekit`...

---

## 🎯 Checklist Przed Resubmission

- [ ] Product ID w kodzie = Product ID w App Store Connect
- [ ] Introductory Offer jest **Active** w App Store Connect
- [ ] StoreKit config jest poprawny
- [ ] Przetestowano w Sandbox - Free Trial jest widoczny
- [ ] Screenshot pokazujący Free Trial dodany do Review Info
- [ ] Notes for Review zaktualizowane

---

## 📧 Odpowiedź do Apple Review Team

**Template odpowiedzi:**

```
Hello Apple Review Team,

Thank you for your feedback regarding the free trial not being displayed.

We have identified and fixed the issue:
1. Corrected the Product ID configuration
2. Verified the Introductory Offer is properly configured in App Store Connect
3. Tested in Sandbox - the free trial now displays correctly in the purchase prompt

The 30-day free trial is configured as follows:
- Product ID: com.lmglsl.subscription.monthly
- Introductory Offer Type: Free Trial
- Duration: 1 Month (30 days)
- Price during trial: $0.00

We have attached a screenshot showing the free trial being properly displayed in the purchase prompt.

Thank you for your patience, and we look forward to your approval.

Best regards,
LayerMapper Team
```

---

## ⏭️ Next Steps

1. **Napraw Product ID** - Wybierz opcję A lub B
2. **Zamień StoreKit config** - Użyj poprawionej wersji
3. **Test w Sandbox** - Upewnij się że działa
4. **Upload nowy build** - Bump build number
5. **Reply to Review Team** - Użyj template powyżej
6. **Submit for Review** - Ponownie wyślij

---

**Status:** 🔧 REQUIRES FIX  
**Priority:** 🔴 HIGH  
**ETA:** 2-4 godziny (fix + test + resubmit)
