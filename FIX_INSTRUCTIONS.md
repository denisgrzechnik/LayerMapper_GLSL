# 🔧 Instrukcja Naprawy - Apple Review Issue

## ⚠️ KRYTYCZNE ZMIANY DO WPROWADZENIA

---

## 📋 Podsumowanie Problemu

**Apple odrzuciło app bo:**
Free Trial (30 dni) **nie był widoczny** w natywnym oknie zakupu Apple.

**Przyczyna:**
Niezgodność między Product ID w kodzie a Product ID w App Store Connect.

---

## ✅ CO ZOSTAŁO JUŻ NAPRAWIONE

### 1. StoreKit Configuration File ✅
Plik `LM_GLSL.storekit` został naprawiony:
- ✅ Usunięto Tips products
- ✅ Usunięto Yearly subscription  
- ✅ Pozostawiono tylko Monthly subscription
- ✅ Poprawiono Product ID na: `com.lmglsl.subscription.monthly`
- ✅ Dodano `displayPrice: "0.00"` do introductoryOffer

---

## 🔴 CO MUSISZ JESZCZE ZROBIĆ

### Krok 1: Sprawdź Product ID w App Store Connect

1. Przejdź do [App Store Connect](https://appstoreconnect.apple.com)
2. Wybierz app: **LayerMapper GLSL**
3. Przejdź do: **Features** → **Subscriptions**
4. Sprawdź **Product ID**

**Masz 2 scenariusze:**

#### Scenariusz A: Product ID w ASC = `com.lmglsl.subscription.monthly`
✅ **SUPER!** Nic nie rób, ID jest poprawne.

#### Scenariusz B: Product ID w ASC = `com.layermapper.glsl.subscription.monthly`
⚠️ **PROBLEM!** Musisz zmienić kod.

---

### Krok 2A: Jeśli Product ID = `com.lmglsl.subscription.monthly` (POPRAWNY)

**NIE ZMIENIAJ KODU!** Przejdź do Kroku 3.

---

### Krok 2B: Jeśli Product ID = `com.layermapper.glsl.subscription.monthly` (BŁĘDNY)

**OPCJA 1: Zmień Product ID w App Store Connect (ZALECANE)**

⚠️ **UWAGA:** Możesz zmienić Product ID tylko jeśli subskrypcja nie ma jeszcze żadnych subskrybentów!

1. App Store Connect → Subscriptions
2. Usuń stary product (jeśli możliwe)
3. Utwórz nowy z ID: `com.lmglsl.subscription.monthly`
4. Skonfiguruj Free Trial (30 days, FREE)

**OPCJA 2: Zmień kod (jeśli nie możesz zmienić ASC)**

Edytuj `StoreManager.swift`:

```swift
// LINIA ~80
// PRZED:
private let productIDs: [String] = [
    "com.lmglsl.subscription.monthly"
]

// PO:
private let productIDs: [String] = [
    "com.layermapper.glsl.subscription.monthly"
]
```

I zmień w `LicenseType`:
```swift
// LINIA ~48
case monthly = "monthly_subscription"

var productID: String {
    switch self {
    case .trial: return ""
    case .monthly: return "com.layermapper.glsl.subscription.monthly" // ZMIEŃ!
    }
}
```

**ORAZ** napraw `LM_GLSL.storekit` z powrotem (użyj starego Product ID).

---

### Krok 3: Sprawdź Introductory Offer w App Store Connect

1. App Store Connect → Subscriptions → Monthly
2. Sprawdź **Introductory Offer** sekcję

**MUSI BYĆ:**
- ✅ Type: **Free Trial** (nie Pay As You Go!)
- ✅ Duration: **1 Month** (30 days)
- ✅ Price: **$0.00**
- ✅ Status: **Ready to Submit** (NIE Draft!)

**Jeśli jest Draft:**
1. Kliknij **Edit**
2. Wypełnij wszystkie pola
3. **Save**
4. Status zmieni się na **Ready to Submit**

---

### Krok 4: Test w Sandbox

**KRYTYCZNE:** Musisz przetestować że Free Trial jest widoczny!

#### A. Wyczyść Previous Purchases
```
1. App Store Connect → Users and Access → Sandbox Testers
2. Wybierz testera
3. Kliknij "Clear Purchase History"
4. Confirm
```

#### B. Test na Urządzeniu
```
1. Usuń app z urządzenia testowego (hold & delete)
2. Settings → App Store → Sign Out
3. Build & Run from Xcode
4. Tap "Start Free Trial" button
5. Login with Sandbox Tester credentials
```

#### C. Sprawdź Apple Prompt
**Apple native prompt MUSI pokazać:**
```
┌─────────────────────────────┐
│ Monthly Subscription        │
│                             │
│ ✅ 30 Days Free             │ ← TO MUSI BYĆ WIDOCZNE!
│ Then $11.00/month          │
│                             │
│ [Subscribe]  [Cancel]      │
└─────────────────────────────┘
```

**Jeśli NIE widzisz "30 Days Free"** → coś jest źle skonfigurowane!

---

### Krok 5: Screenshot dla Review Team

1. **Zrób screenshot** Apple prompt pokazującego Free Trial
2. Zapisz jako `free_trial_proof.png`
3. Użyjesz w odpowiedzi do Review Team

---

### Krok 6: Bump Build Number

W Xcode:
```
Target → General → Identity
Build: 1 → 2 (lub następny numer)
```

---

### Krok 7: Archive & Upload

```bash
1. Product → Archive
2. Distribute App → App Store Connect
3. Upload
4. Wait for processing (~5-10 min)
```

---

### Krok 8: Reply to Review Team

W App Store Connect:

1. Przejdź do: **App Review** → **In Review** (lub Rejected)
2. Kliknij **Reply to App Review Team**
3. Wklej ten tekst:

```
Hello Apple Review Team,

Thank you for identifying the free trial display issue.

We have fixed the problem:

1. ✅ Verified Product ID matches between code and App Store Connect
2. ✅ Confirmed Introductory Offer is properly configured:
   - Type: Free Trial
   - Duration: 30 days (1 month)
   - Price: $0.00 during trial
   - Status: Ready to Submit

3. ✅ Tested in Sandbox environment
4. ✅ Confirmed the native Apple prompt now displays "30 Days Free"

Attached screenshot shows the free trial being properly displayed in the purchase prompt (taken from iPad sandbox testing).

Build Information:
- Version: 1.0
- Build: 2 (updated)
- Product ID: com.lmglsl.subscription.monthly

The issue has been resolved and tested. Ready for review.

Best regards,
LayerMapper Team
```

4. **Attach Screenshot**: `free_trial_proof.png`
5. Kliknij **Submit**

---

### Krok 9: Submit for Review (Again)

1. App Store Connect → App Details
2. Wybierz nowy build (Build 2)
3. **Submit for Review**

---

## 📸 Przykład Poprawnego Promptu

Tak powinien wyglądać natywny prompt Apple:

```
╔═════════════════════════════════════╗
║  🎨 LM_GLSL                         ║
║                                     ║
║  Monthly Subscription               ║
║                                     ║
║  ┌─────────────────────────────┐  ║
║  │ ✅ First 30 days FREE       │  ║  ← KLUCZOWE!
║  │ Then $11.00/month           │  ║
║  │ Automatically renews        │  ║
║  │ Cancel anytime              │  ║
║  └─────────────────────────────┘  ║
║                                     ║
║  Full access to all features        ║
║                                     ║
║  [ Subscribe ]  [ Cancel ]         ║
╚═════════════════════════════════════╝
```

**Jeśli nie widzisz "First 30 days FREE"** → problem!

---

## ⚡ Quick Checklist

Przed resubmission upewnij się:

- [ ] Product ID w kodzie = Product ID w App Store Connect
- [ ] Introductory Offer ma status "Ready to Submit" (nie Draft)
- [ ] Free Trial: 30 days, $0.00, Type: Free
- [ ] Przetestowano w Sandbox - prompt pokazuje "30 Days Free"
- [ ] Screenshot dodany do odpowiedzi
- [ ] Build number zwiększony
- [ ] Nowy build uploaded do App Store Connect
- [ ] Reply to Review Team wysłane
- [ ] Resubmitted for review

---

## 🚨 Najczęstsze Błędy

### Błąd 1: Introductory Offer jest Draft
**Rozwiązanie:** Edit → Fill all fields → Save

### Błąd 2: Payment Mode = "Pay As You Go"
**Rozwiązanie:** Change to "Free"

### Błąd 3: Duration = 0 or blank
**Rozwiązanie:** Set to "1 Month"

### Błąd 4: Product nie ma Introductory Offer w ogóle
**Rozwiązanie:** Add Introductory Offer → Free Trial → 1 Month → $0.00

---

## 📞 Potrzebujesz Pomocy?

### Console Logs
Przy testowaniu w Sandbox, sprawdź console:
```bash
Filter: "STORE"
Should see: "✅ Loaded 1 products"
Should see product with Introductory Offer info
```

### Sandbox Not Working?
```bash
1. Sign out from real Apple ID
2. Delete app
3. Clear Purchase History for Sandbox Tester
4. Fresh install
5. Try again
```

---

## ⏱️ Timeline

**Expected time to fix:**
- Review configuration: 15 min
- Fix code (if needed): 10 min
- Test in Sandbox: 20 min
- Upload new build: 15 min
- Reply to Review: 10 min
- **Total: ~70 minutes**

**Apple Review time:**
- Resubmission usually faster: 12-24 hours
- With fix + explanation: Higher chance of approval

---

## ✅ Success Criteria

**You'll know it's fixed when:**
1. ✅ Sandbox test shows "30 Days Free" in Apple prompt
2. ✅ No errors in console logs
3. ✅ Purchase flow completes successfully
4. ✅ After trial, subscription status = Active

---

**Good luck! 🍀**

*Last updated: 13 stycznia 2026*
