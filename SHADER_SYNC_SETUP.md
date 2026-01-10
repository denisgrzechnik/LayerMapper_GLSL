# GLSL Shader Sync - Instrukcja Konfiguracji

## Przegląd

System synchronizacji shaderów między aplikacją **LM_GLSL** (Source) a **LayerMapper MApp** (Receiver) wykorzystuje `MultipeerConnectivity` do przesyłania kodu shaderów i parametrów w czasie rzeczywistym.

## Architektura

```
┌─────────────────┐         ┌─────────────────────┐
│   LM_GLSL       │         │  LayerMapper MApp   │
│   (iPhone)      │ ──────► │  (iPad)             │
│                 │         │                     │
│   SOURCE        │   P2P   │   RECEIVER          │
│   Źródło 1-8    │ Network │   Odbiera shadery   │
└─────────────────┘         └─────────────────────┘
```

### Co jest przesyłane?
- **Kod GLSL** (~2-10 KB) - przy zmianie shadera
- **Parametry** (~200 bajtów) - 30x na sekundę
- **Thumbnails** (~10-50 KB) - opcjonalnie
- **Timing/BPM** (~50 bajtów) - w każdej wiadomości

## Konfiguracja Xcode

### 1. Info.plist - Bonjour Services

Dodaj do Info.plist (lub w ustawieniach targetu):

```xml
<key>NSBonjourServices</key>
<array>
    <string>_lm-shader-sync._tcp</string>
    <string>_lm-shader-sync._udp</string>
</array>
```

### 2. Info.plist - Opisy dostępu do sieci

```xml
<key>NSLocalNetworkUsageDescription</key>
<string>LM GLSL używa sieci lokalnej do synchronizacji shaderów z LayerMapper MApp.</string>
```

### 3. Entitlements - Multicast Networking

Dodaj do pliku `.entitlements`:

```xml
<key>com.apple.developer.networking.multicast</key>
<true/>
```

**UWAGA:** To uprawnienie wymaga specjalnego zatwierdzenia od Apple. Musisz:
1. Złożyć wniosek przez Apple Developer portal
2. Poczekać na zatwierdzenie
3. Wygenerować nowy Provisioning Profile z tym uprawnieniem

### 4. Dodanie plików do projektu w Xcode

Pliki do dodania do LM_GLSL:
- `LM_GLSL/Sync/ShaderSyncModels.swift`
- `LM_GLSL/Sync/ShaderSyncService.swift`
- `LM_GLSL/Views/ShaderSyncSettingsView.swift`

Pliki do dodania do LayerMapperLaser:
- `LayerMapperLaser/Managers/ShaderSync/ShaderSyncModels.swift`
- `LayerMapperLaser/Managers/ShaderSync/ShaderSyncReceiverService.swift`
- `LayerMapperLaser/Views/ShaderSync/ShaderSyncReceiverView.swift`

## Jak to działa?

### Na iPhone (LM_GLSL - Source):

1. Aplikacja startuje `ShaderSyncService` przy uruchomieniu
2. Serwis rozgłasza się jako "Źródło \(index)" przez Bonjour
3. Gdy użytkownik wybierze shader, jest on broadcastowany do wszystkich połączonych odbiorników
4. Parametry są aktualizowane 30x/s podczas odtwarzania

### Na iPad (LayerMapper MApp - Receiver):

1. `ShaderSyncReceiverService` szuka dostępnych źródeł shaderów
2. Automatycznie łączy się z odkrytymi źródłami
3. Odbiera kod shaderów i renderuje je lokalnie
4. Można przypisać źródła do konkretnych warstw

## Użycie w kodzie

### LM_GLSL - Broadcast shadera:

```swift
@StateObject private var syncService = ShaderSyncService()

// Przy zmianie shadera:
syncService.broadcastShader(
    shaderId: shader.id,
    shaderName: shader.name,
    shaderCategory: shader.category.rawValue,
    fragmentCode: shader.fragmentCode,
    parameters: syncParams
)

// Aktualizacja parametrów w pętli renderowania:
syncService.updateParameters(paramValues, time: currentTime, beat: currentBeat)
```

### LayerMapper MApp - Odbieranie:

```swift
@StateObject private var shaderReceiver = ShaderSyncReceiverService()

// Callback przy odbiorze shadera:
shaderReceiver.onShaderReceived = { broadcast, sourceIndex in
    // Utwórz MediaAsset z shaderem
    let asset = MediaAsset.shader(code: broadcast.fragmentCode, name: broadcast.shaderName)
    // Przypisz do warstwy
}

// Callback przy aktualizacji parametrów:
shaderReceiver.onParametersUpdated = { sourceIndex, values, time in
    // Zaktualizuj uniformy shadera
}
```

## Obsługa wielu źródeł (8 iPhone'ów)

System obsługuje do 8 jednoczesnych źródeł shaderów:

| Źródło | iPhone | Warstwa na iPadzie |
|--------|--------|-------------------|
| 1      | Denis's iPhone | Warstwa 1 |
| 2      | iPhone Anna | Warstwa 2 |
| 3      | iPhone Piotr | Warstwa 3 |
| ...    | ...    | ... |
| 8      | iPhone 8 | Warstwa 8 |

Każdy iPhone ustawia swój indeks źródła (1-8) w ustawieniach synchronizacji.

## Rozwiązywanie problemów

### Urządzenia się nie widzą:
1. Upewnij się, że oba są w tej samej sieci Wi-Fi
2. Sprawdź, czy Bluetooth jest włączony
3. Restart obu aplikacji

### Brak uprawnień multicast:
- Skontaktuj się z Apple Developer Support
- Alternatywnie: użyj tylko TCP/UDP bez multicast

### Duże opóźnienia:
- Zmniejsz częstotliwość aktualizacji parametrów
- Upewnij się, że sieć Wi-Fi jest stabilna

## Przyszłe rozszerzenia

- [ ] Streaming thumbnail'i w czasie rzeczywistym
- [ ] Kontrola zdalna parametrów z iPada
- [ ] Synchronizacja z Ableton Link BPM
- [ ] Zapisywanie odebranych shaderów lokalnie
- [ ] Grupowanie źródeł w zestawy
