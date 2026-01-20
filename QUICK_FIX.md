# 🚨 SZYBKIE ROZWIĄZANIE - Apple Review Problem

## Problem
Apple odrzuciło aplikację bo **Free Trial (30 dni) nie był widoczny** w oknie zakupu.

---

## ❌ Co Jest Nie Tak

### Główny Problem: Niezgodność Product ID

**W kodzie (`StoreManager.swift`):**
```swift
"com.lmglsl.subscription.monthly"
```

**W App Store Connect:**
Prawdopodobnie: `"com.layermapper.glsl.subscription.monthly"` (INNY!)

**To powoduje:** Apple nie może znaleźć produktu → nie pokazuje Free Trial

---

## ✅ Rozwiązanie (2 opcje)

### OPCJA 1: Zmień Product ID w App Store Connect (ZALECANE)

1. Usuń stary product w App Store Connect
2. Utwórz nowy z ID: `com.lmglsl.subscription.monthly`
3. Skonfiguruj Free Trial:
   - Type: **Free Trial**
   - Duration: **30 days**
   - Price: **$0.00**
4. Status: **Ready to Submit** (nie Draft!)

### OPCJA 2: Zmień kod (jeśli nie możesz zmienić ASC)

W `StoreManager.swift` zmień:
```swift
// Linia ~80
"com.lmglsl.subscription.monthly"
→
"com.layermapper.glsl.subscription.monthly"
```

---

## 🔧 Co Już Zrobiłem

✅ Naprawiłem plik `LM_GLSL.storekit`:
- Usunąłem Tips products
- Usunąłem Yearly subscription
- Poprawiłem Product ID
- Dodałem `displayPrice: "0.00"` do Free Trial

---

## 📋 Kroki Do Wykonania

### 1. Sprawdź Product ID w App Store Connect
```
App Store Connect → Subscriptions → Zobacz Product ID
```

### 2. Jeśli niezgodność - wybierz Opcję 1 lub 2 powyżej

### 3. Sprawdź Introductory Offer w ASC
**MUSI BYĆ:**
- Type: Free Trial
- Duration: 1 Month (30 days)
- Price: $0.00
- Status: **Ready to Submit**

### 4. Test w Sandbox
```
1. Wyczyść Purchase History dla Sandbox Tester
2. Usuń app z urządzenia
3. Settings → App Store → Sign Out
4. Build & Run z Xcode
5. Kup subskrypcję
6. SPRAWDŹ czy prompt pokazuje "30 Days Free"
```

### 5. Zrób Screenshot
Zrób screenshot Apple promptu pokazującego "30 Days Free"

### 6. Zwiększ Build Number
```
Xcode → Target → General → Build: 1 → 2
```

### 7. Archive & Upload
```
Product → Archive → Distribute to App Store Connect
```

### 8. Reply to Apple
W App Store Connect → App Review → Reply:

```
Hello,

Fixed the issue:
- Product ID corrected
- Introductory Offer properly configured (30 days FREE)
- Tested in Sandbox - Free Trial now displays correctly
- Screenshot attached

Ready for review.
Build: 2

Best regards
```

### 9. Submit for Review
App Store Connect → Submit nowy build

---

## 🎯 Kluczowe Punkty

### Free Trial MUSI być widoczny w Apple prompt:
```
┌─────────────────────────┐
│ Monthly Subscription    │
│                         │
│ ✅ 30 Days Free        │ ← TO!
│ Then $11/month         │
│                         │
│ [Subscribe] [Cancel]   │
└─────────────────────────┘
```

**Jeśli tego nie widzisz w teście → coś źle!**

---

## ⚠️ Najczęstsze Błędy

1. **Introductory Offer ma status "Draft"**
   → Edit → Fill fields → Save

2. **Payment Mode = "Pay As You Go"**
   → Change to "Free"

3. **Product ID się nie zgadza**
   → Fix w kodzie LUB App Store Connect

4. **Duration = 0 lub puste**
   → Set to "1 Month"

---

## 📞 Jeśli Masz Problem

### Sprawdź Console Logs (Xcode)
Filter: `STORE`
Powinno być: `✅ Loaded 1 products`

### Test Nie Działa?
1. Wyloguj się z prawdziwego Apple ID
2. Usuń app
3. Wyczyść Purchase History
4. Fresh install
5. Try again

---

## ⏱️ Ile To Zajmie

- **Fix + Test**: 1 godzina
- **Upload + Reply**: 30 minut
- **Apple Re-review**: 12-24 godziny

**Total: ~2 dni** do approval (jeśli wszystko OK)

---

## 📄 Dokumentacja

Więcej szczegółów w:
- **FIX_INSTRUCTIONS.md** - Pełna instrukcja krok po kroku
- **APPLE_REVIEW_FIX.md** - Analiza problemu

---

**Status:** 🔴 WYMAGA NAPRAWY  
**Priority:** HIGH  
**Data:** 13 stycznia 2026

---

**Powodzenia! 🚀**
