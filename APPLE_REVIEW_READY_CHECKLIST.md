# ✅ APPLE REVIEW - OSTATECZNA WERYFIKACJA

**Data:** 13 stycznia 2026  
**Status:** 🟢 READY TO TEST & SUBMIT

---

## 🎯 PODSUMOWANIE - CO MAM W APP STORE CONNECT

### Introductory Offers (UTWORZONE ✅):

1. **Monthly Subscription with Free Trial**
   - Product ID: `com.layermapper.glsl.subscription.monthly` ✅
   - Start Date: `13.01.2026` (lub `15.01.2026` jak sugerowałem)
   - End Date: `No End Date` ✅
   - Type: Free Trial ✅
   - Duration: 1 Month (30 days) ✅
   - Price: $0.00 ✅

2. **Yearly Subscription with Free Trial**
   - Product ID: `com.layermapper.glsl.subscription.yearly` ✅
   - Start Date: `13.01.2026` (lub `15.01.2026` jak sugerowałem)
   - End Date: `No End Date` ✅
   - Type: Free Trial ✅
   - Duration: 1 Month (30 days) ✅
   - Price: $0.00 ✅

---

## ✅ WERYFIKACJA 1: Product IDs w KODZIE

### StoreManager.swift (linie 76-77):
```swift
private let productIDs: [String] = [
    "com.layermapper.glsl.subscription.monthly",  ✅
    "com.layermapper.glsl.subscription.yearly",   ✅
    "com.layermapper.glsl.tip.88",
    "com.layermapper.glsl.tip.111",
    "com.layermapper.glsl.tip.222",
    "com.layermapper.glsl.tip.444"
]
```

### LicenseType enum (linie 49-52):
```swift
var productID: String {
    switch self {
    case .trial: return ""
    case .monthly: return "com.layermapper.glsl.subscription.monthly"  ✅
    case .yearly: return "com.layermapper.glsl.subscription.yearly"    ✅
    }
}
```

**Wynik:** ✅ **ZGADZA SIĘ W 100%!**

---

## ✅ WERYFIKACJA 2: StoreKit Configuration File

### LM_GLSL.storekit:

#### Monthly Subscription:
```json
{
  "productID" : "com.layermapper.glsl.subscription.monthly",  ✅
  "displayPrice" : "11.00",
  "introductoryOffer" : {
    "displayPrice" : "0.00",           ✅
    "numberOfPeriods" : 1,             ✅
    "paymentMode" : "free",            ✅
    "subscriptionPeriod" : "P1M"       ✅
  },
  "recurringSubscriptionPeriod" : "P1M"
}
```

#### Yearly Subscription:
```json
{
  "productID" : "com.layermapper.glsl.subscription.yearly",   ✅
  "displayPrice" : "66.00",
  "introductoryOffer" : {
    "displayPrice" : "0.00",           ✅
    "numberOfPeriods" : 1,             ✅
    "paymentMode" : "free",            ✅
    "subscriptionPeriod" : "P1M"       ✅
  },
  "recurringSubscriptionPeriod" : "P1Y"
}
```

**Wynik:** ✅ **ZGADZA SIĘ W 100%!**

---

## ✅ WERYFIKACJA 3: App Store Connect vs Kod

### Tabela zgodności:

| Lokalizacja | Monthly | Yearly | Status |
|------------|---------|--------|--------|
| **App Store Connect** | `com.layermapper.glsl.subscription.monthly` | `com.layermapper.glsl.subscription.yearly` | ✅ |
| **StoreManager.swift** | `com.layermapper.glsl.subscription.monthly` | `com.layermapper.glsl.subscription.yearly` | ✅ |
| **LM_GLSL.storekit** | `com.layermapper.glsl.subscription.monthly` | `com.layermapper.glsl.subscription.yearly` | ✅ |
| **Introductory Offers** | Free Trial: 30 days, $0.00 | Free Trial: 30 days, $0.00 | ✅ |

### 🎉 **WSZYSTKO ZGADZA SIĘ!**

---

## ✅ WERYFIKACJA 4: Introductory Offer Configuration

### ✅ Sprawdź w App Store Connect:

- [ ] **Status:** "Ready to Submit" (NIE "Draft"!)
- [ ] **Type:** Free Trial ✅
- [ ] **Duration:** 1 Month (30 days) ✅
- [ ] **Price:** $0.00 ✅
- [ ] **Start Date:** Ustawiona (13.01 lub 15.01.2026) ✅
- [ ] **End Date:** "No End Date" lub daleko w przyszłość ✅
- [ ] **Apply to:** Oba (Monthly + Yearly) ✅

---

## 🧪 TERAZ: TEST W SANDBOX (KRYTYCZNY!)

### Dlaczego test jest OBOWIĄZKOWY?

Apple odrzuciło app bo:
> "The free trial was not reflected on the purchase prompt"

Musisz POTWIERDZIĆ że teraz **Apple prompt POKAZUJE "30 Days Free"**!

---

## 📱 KROK PO KROKU: Sandbox Testing

### 1️⃣ Przygotowanie Sandbox Testera

#### W App Store Connect:
```
Users and Access → Sandbox Testers
→ Wybierz swojego testera
→ Clear Purchase History
→ Save
```

**Czemu?** Stary history może ukryć Free Trial!

---

### 2️⃣ Przygotowanie Urządzenia (iPad)

#### Na iPad:
```
Settings → App Store
→ Sign Out (wyloguj prawdziwe Apple ID!)
→ Delete LayerMapper GLSL app (hold icon → Delete)
→ Restart iPad (Power Off → Power On)
```

**Czemu?** Świeża instalacja = symulacja nowego użytkownika

---

### 3️⃣ Build & Run z Xcode

#### W Xcode:
```bash
1. Clean Build Folder (⌘⇧K)
2. Select Target: LayerMapper GLSL
3. Select Device: Twój iPad
4. Run (⌘R)
```

App się zainstaluje i uruchomi automatycznie.

---

### 4️⃣ Trigger Purchase Flow

#### W App:
```
1. Otwórz app
2. Tap Settings (⚙️) icon
3. Tap "Subscribe to Premium" lub "Start Free Trial"
```

---

### 5️⃣ Login Sandbox Tester

#### Prompt się pojawi:
```
"Sign in with your Apple ID"

Username: [twój sandbox tester email]
Password: [hasło sandbox testera]

[ Sign In ]
```

**Czemu?** Sandbox nie używa prawdziwego Apple ID!

---

### 6️⃣ SPRAWDŹ APPLE PROMPT!

#### ✅ MUSI wyglądać tak:

```
╔═══════════════════════════════════════════════╗
║         Confirm Your Subscription             ║
║                                               ║
║  LayerMapper GLSL                            ║
║  Monthly Subscription                         ║
║                                               ║
║  ┌─────────────────────────────────────────┐ ║
║  │ ✅ First month FREE                     │ ║  ← TO!
║  │ Then $11.00 per month                   │ ║
║  │                                         │ ║
║  │ • Renews automatically                  │ ║
║  │ • Cancel anytime                        │ ║
║  │ • Free for 30 days                      │ ║  ← I TO!
║  └─────────────────────────────────────────┘ ║
║                                               ║
║         [ Subscribe ]    [ Cancel ]          ║
╚═══════════════════════════════════════════════╝
```

**Kluczowe teksty:**
- ✅ "First month FREE" lub "First 30 days FREE"
- ✅ "Then $11.00 per month" (po trial)
- ✅ "Free for 30 days"

---

### 7️⃣ SCREENSHOT!

#### iPad: Power Button + Volume Up

**Zapisz jako:** `apple_prompt_with_free_trial.png`

**Czemu?** To dowód dla Apple że naprawiłeś problem!

---

### 8️⃣ Test Purchase Flow

#### Kliknij "Subscribe":
```
✅ "Purchase successful" (w Sandbox nie płacisz!)
✅ App pokazuje "Premium Active"
✅ Settings pokazuje "Manage Subscription"
```

---

### 9️⃣ Test Yearly Subscription (opcjonalnie)

Powtórz kroki 2-8 ale wybierz Yearly zamiast Monthly.

**Czemu?** Upewnić się że oba plany mają Free Trial!

---

## 🚨 CO JEŚLI NIE DZIAŁA?

### ❌ Problem: Prompt NIE pokazuje "Free Trial"

**Możliwe przyczyny:**

1. **Status = "Draft"**
   - **Fix:** App Store Connect → Introductory Offer → SAVE → Sprawdź status
   
2. **Start Date jeszcze nie nastąpiła**
   - **Fix:** Jeśli ustawiłeś 15.01.2026 a jest 13.01 → może nie być aktywna
   - **Rozwiązanie:** Zmień na 13.01.2026 (dzisiaj) lub 14.01.2026 (jutro)
   
3. **Sandbox Cache**
   - **Fix:** Clear Purchase History dla testera → Restart iPad → Reinstall app
   
4. **StoreKit Config nie jest selected w Xcode**
   - **Fix:** Xcode → Product → Scheme → Edit Scheme → Run → Options
   - **StoreKit Configuration:** LM_GLSL.storekit ✅
   
5. **Wrong Product ID in Code**
   - **Fix:** Sprawdź StoreManager.swift linie 76-77 (ale już sprawdziliśmy - jest OK!)

---

### ❌ Problem: "Cannot connect to App Store"

**Fix:**
```
Settings → App Store
→ Sign Out
→ Restart iPad
→ Run app again z Xcode
→ Login Sandbox Tester gdy prompt się pojawi
```

---

### ❌ Problem: "Purchase failed"

**Fix:**
```
1. Clear Purchase History (ASC)
2. Delete app
3. Restart iPad
4. Run again
```

---

## 📦 JEŚLI TEST PRZESZEDŁ: Przygotuj Build

### 1️⃣ Zwiększ Build Number

```
Xcode → Target: LayerMapper GLSL
→ General → Identity
→ Build: 1 → 2
```

---

### 2️⃣ Archive

```bash
Product → Archive

# Po zakończeniu Organizer się otworzy
```

---

### 3️⃣ Validate

```
Organizer → Validate App
→ App Store Connect
→ Next → Validate

# Czekaj 2-3 minuty
```

**Sprawdź:**
- ✅ No errors
- ✅ Może być warnings (ignoruj)

---

### 4️⃣ Upload

```
Organizer → Distribute App
→ App Store Connect
→ Upload
→ Next → Upload

# Czekaj 5-10 minut na processing
```

---

### 5️⃣ Sprawdź Processing

```
App Store Connect → Apps → LayerMapper GLSL
→ TestFlight → iOS Builds

Status: "Processing" → "Ready to Submit" (5-10 min)
```

---

## 📧 ODPOWIEDŹ DO APPLE REVIEW TEAM

### W App Store Connect:

```
App Store Connect → Apps → LayerMapper GLSL
→ App Review (sidebar)
→ Find rejected submission
→ Reply to App Review Team
```

### Wklej ten tekst:

```
Hello Apple Review Team,

Thank you for your thorough review and for identifying the free trial configuration issue.

ISSUE RESOLVED:
✅ Introductory Offers have been properly configured in App Store Connect
✅ Monthly Subscription: 30-day free trial activated
✅ Yearly Subscription: 30-day free trial activated
✅ Both offers have Status: "Ready to Submit"
✅ Start Date: January 13, 2026 (active globally)
✅ End Date: No expiration (permanent offer)

TESTING COMPLETED:
✅ Tested in Sandbox environment on iPad Air 11-inch (M3)
✅ Confirmed the native Apple purchase prompt correctly displays:
   - "First month FREE" text
   - "Then $11.00 per month" after trial
   - "Free for 30 days" description
✅ Screenshot attached showing the free trial properly displayed in the native Apple prompt

BUILD INFORMATION:
- App Name: LayerMapper GLSL
- Version: 1.0
- Build: 2 (updated)
- Product IDs:
  * com.layermapper.glsl.subscription.monthly (with 30-day free trial)
  * com.layermapper.glsl.subscription.yearly (with 30-day free trial)

CONFIGURATION DETAILS:
- Introductory Offer Type: Free Trial
- Duration: 1 Month (30 days)
- Price During Trial: $0.00
- Price After Trial: $11.00/month (Monthly) or $66.00/year (Yearly)
- Payment Mode: Free

ROOT CAUSE:
The introductory offers were not configured in App Store Connect during the initial submission. 
They are now properly configured with the correct dates, durations, and pricing.

The free trial is now clearly visible in the native Apple purchase prompt, meeting all App Store guidelines.

We apologize for the initial oversight and appreciate your detailed feedback.

Ready for re-review.

Best regards,
LayerMapper Team
```

---

### Dodaj Screenshot:

**File:** `apple_prompt_with_free_trial.png`

**Caption:** "Native Apple purchase prompt showing 30-day free trial"

---

## 🚀 SUBMIT FOR REVIEW

### W App Store Connect:

```
Apps → LayerMapper GLSL → App Store (tab)

1. Version 1.0
2. Build: Select Build 2 ✅
3. Sprawdź wszystkie metadata:
   - Screenshots ✅
   - Description ✅
   - Keywords ✅
   - Privacy Policy URL ✅
   - Support URL ✅
   - Pricing: $11/month ✅

4. [ Submit for Review ]
```

---

## ✅ FINAL CHECKLIST PRZED SUBMIT

### App Store Connect:

- [ ] **Introductory Offers:** Ready to Submit ✅
- [ ] **Monthly:** 30 days FREE, Start: 13.01.2026, End: None ✅
- [ ] **Yearly:** 30 days FREE, Start: 13.01.2026, End: None ✅
- [ ] **Build 2:** Uploaded & Processed ✅
- [ ] **Reply to Review Team:** Wysłane ✅
- [ ] **Screenshot:** Attached ✅

### Xcode:

- [ ] **StoreKit Config:** LM_GLSL.storekit selected ✅
- [ ] **Product IDs:** Match App Store Connect ✅
- [ ] **Build Number:** 2 ✅
- [ ] **Scheme:** StoreKit Configuration = LM_GLSL.storekit ✅

### Testing:

- [ ] **Sandbox Test:** Passed ✅
- [ ] **Apple Prompt:** Shows "30 Days Free" ✅
- [ ] **Screenshot:** Saved & Attached ✅
- [ ] **Both Plans:** Monthly + Yearly tested ✅

---

## 📊 EXPECTED TIMELINE

### Today (13.01.2026):
- ✅ Introductory Offers configured
- ✅ Product IDs verified
- ✅ Sandbox testing
- ✅ Screenshot taken

### Tomorrow (14.01.2026):
- Build 2 upload
- Reply to Review Team
- Submit for review

### 15-16.01.2026:
- Apple re-review (12-48h for resubmissions)

### Expected Approval:
- **16-17 stycznia 2026** 🎉

---

## 🎯 CZY WSZYSTKO JEST GOTOWE?

### ✅ TAK, jeśli:

1. ✅ **Product IDs w kodzie = Product IDs w ASC** (ZGADZA SIĘ!)
2. ✅ **Introductory Offers utworzone** (Monthly + Yearly)
3. ✅ **Status = "Ready to Submit"** (NIE Draft!)
4. ✅ **StoreKit config ma introductoryOffer** (ZGADZA SIĘ!)
5. ✅ **Sandbox test pokazał "30 Days Free"** (DO ZROBIENIA!)
6. ✅ **Screenshot zapisany** (DO ZROBIENIA!)

---

## 🚨 JEDYNE CO MUSISZ JESZCZE ZROBIĆ:

### 1. ✅ Sprawdź Status w ASC
Upewnij się że oba Introductory Offers mają status **"Ready to Submit"**, nie "Draft"!

### 2. 🧪 TEST W SANDBOX (15-30 minut)
To jest **NAJBARDZIEJ KRYTYCZNE**!
- Bez tego nie wiesz czy naprawione!
- Apple może znowu odrzucić jeśli prompt nie pokazuje Free Trial!

### 3. 📸 Screenshot
Dowód że działa!

### 4. 📦 Build 2 + Submit
Standardowa procedura.

---

## 💡 ODPOWIEDŹ NA TWOJE PYTANIA:

### ❓ "Czy to wystarczy?"
✅ **TAK!** Introductory Offers Monthly + Yearly = wystarczające!

### ❓ "Czy wszystkie inne problemy rozwiązane?"
✅ **TAK!** Product IDs zgadzają się w 100%:
- Kod: `com.layermapper.glsl.subscription.monthly/yearly` ✅
- ASC: `com.layermapper.glsl.subscription.monthly/yearly` ✅
- StoreKit: `com.layermapper.glsl.subscription.monthly/yearly` ✅

### ❓ "Czy w kodzie zgadzają się Product IDs?"
✅ **TAK!** Sprawdziłem:
- `StoreManager.swift` linie 76-77 ✅
- `LicenseType` enum linie 49-52 ✅
- `LM_GLSL.storekit` ✅

---

## 🎉 PODSUMOWANIE

### ✅ CO JEST GOTOWE:

| Element | Status |
|---------|--------|
| Product IDs w Code | ✅ ZGADZA SIĘ |
| Product IDs w ASC | ✅ ZGADZA SIĘ |
| StoreKit Config | ✅ ZGADZA SIĘ |
| Introductory Offers | ✅ UTWORZONE |
| Monthly Free Trial | ✅ 30 days, $0.00 |
| Yearly Free Trial | ✅ 30 days, $0.00 |
| Start Date | ✅ 13.01.2026 |
| End Date | ✅ No End Date |

### ⏳ CO MUSISZ ZROBIĆ:

1. ⏳ **Sprawdź Status** = "Ready to Submit" w ASC
2. ⏳ **TEST W SANDBOX** (15-30 min)
3. ⏳ **Screenshot** Apple prompt z "30 Days Free"
4. ⏳ **Build 2 → Upload**
5. ⏳ **Reply to Review Team**
6. ⏳ **Submit for Review**

---

## 📞 POTRZEBUJESZ POMOCY?

### Jeśli coś nie działa podczas testu:

1. **Clear Sandbox History**
2. **Restart iPad**
3. **Clean Build (⌘⇧K)**
4. **Run again (⌘R)**

### Jeśli nadal nie działa:

Pokaż mi:
- Screenshot Apple prompt (co widzisz?)
- Console logs (Debug Area w Xcode)
- Status Introductory Offers w ASC

---

**🎯 TERAZ: Idź do Sandbox Testing!**

*To jedyny sposób żeby potwierdzić że Apple zaakceptuje app!*

---

**Status:** 🟢 READY FOR SANDBOX TESTING  
**Priority:** 🔴 CRITICAL - Test przed submit!  
**ETA:** 16-17 stycznia 2026 (approval)

