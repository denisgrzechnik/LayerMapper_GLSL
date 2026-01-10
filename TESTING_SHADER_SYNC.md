# 🧪 Instrukcja Testowania Shader Sync

## Wymagania
- 2 urządzenia w tej samej sieci Wi-Fi
- iPhone z aplikacją LM_GLSL (Source)
- iPad z aplikacją LayerMapper MApp (Receiver)
- Bluetooth włączony na obu urządzeniach

## Krok po kroku:

### 1️⃣ Uruchom LM_GLSL na iPhone

1. Otwórz aplikację LM_GLSL
2. W prawym górnym rogu zobaczysz ikonę anteny 📡
3. Kliknij na ikonę anteny
4. Włącz "Rozgłaszanie aktywne"
5. Wybierz "Indeks źródła" (np. Źródło 1)
6. Poczekaj aż status zmieni się na "Oczekuję na połączenie..."

### 2️⃣ Uruchom LayerMapper MApp na iPad

1. Otwórz aplikację LayerMapper MApp
2. Znajdź przycisk Shader Sync (📡)
3. Kliknij na przycisk
4. Włącz "Automatyczne odbieranie"
5. Poczekaj na wykrycie źródła

### 3️⃣ Połączenie

**Na iPhone (LM_GLSL):**
- Status zmieni się na: "Połączono z 1 odbiornikiem(ami)"
- Zobaczysz zielony kółko przy ikonie anteny

**Na iPad (LayerMapper MApp):**
- W sekcji "Połączone źródła" zobaczysz iPhone'a
- Status: "Połączono z 1 źródłem(ami)"

### 4️⃣ Test synchronizacji shadera

**Na iPhone:**
1. Wybierz dowolny shader z listy
2. Shader powinien automatycznie zostać wysłany do iPada

**Na iPad:**
3. W widoku Shader Sync zobaczysz:
   - Nazwę urządzenia (np. "Denis's iPhone")
   - Nazwę shadera
   - Indeks źródła
4. Przypisz źródło do warstwy (np. Warstwa 1)

### 5️⃣ Weryfikacja

**✅ Co powinieneś zobaczyć:**
- Shader renderuje się na iPadzie na przypisanej warstwie
- Parametry są synchronizowane w czasie rzeczywistym (30 FPS)
- Zmiana shadera na iPhone natychmiast aktualizuje iPad

**❌ Problemy:**

| Problem | Rozwiązanie |
|---------|-------------|
| Urządzenia się nie widzą | Upewnij się, że są w tej samej sieci Wi-Fi i Bluetooth jest włączony |
| "Błąd multicast" | To normalne - multicast wymaga specjalnego uprawnienia od Apple |
| Opóźnienia | Sprawdź jakość sieci Wi-Fi, przybliż urządzenia do routera |
| Brak shaderu na iPadzie | Sprawdź czy shader został przypisany do warstwy |

## 🎮 Test wielu źródeł (8 iPhone'ów)

1. Uruchom LM_GLSL na kolejnych iPhone'ach
2. Ustaw różne indeksy źródeł (1-8)
3. Każdy iPhone wysyła inny shader
4. Na iPadzie możesz przypisać każde źródło do osobnej warstwy
5. Wszystkie shadery renderują się jednocześnie!

## 📊 Sprawdzenie wydajności

### Na iPhone (Source):
- CPU: ~5-10% (głównie rendering shadera)
- Sieć: ~50 KB/s (kod + parametry)
- Brak zauważalnego spadku FPS

### Na iPad (Receiver):
- CPU: ~10-20% na shader (rendering lokalny)
- Sieć: ~50 KB/s na źródło (max 400 KB/s dla 8 źródeł)
- Powinno działać płynnie przy 60 FPS

## 🐛 Debugging

### Włącz logi w Xcode:
```swift
// W ShaderSyncService.swift już są logi
// Szukaj w konsoli:
print("📡 ShaderSync: ...")
```

### Sprawdź status połączenia:
- iPhone: `syncService.connectionStatus`
- iPad: `receiverService.connectionStatus`

### Sprawdź czy shader dotarł:
```swift
// Na iPad
if let shader = receiverService.getShader(sourceIndex: 0) {
    print("Shader: \(shader.shaderName)")
    print("Fragment code: \(shader.fragmentCode.count) chars")
}
```

## 🎉 Gotowe!

Jeśli wszystko działa:
- ✅ iPhone rozgłasza shadery
- ✅ iPad odbiera i renderuje
- ✅ Synchronizacja w czasie rzeczywistym działa
- ✅ Można używać wielu źródeł jednocześnie

**Gratulacje! System Shader Sync działa! 🎨✨**
