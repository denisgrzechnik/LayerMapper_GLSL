//
//  ResourceManager.swift
//  LM_GLSL
//
//  Centralny manager zasobów GPU - cache pipeline'ów Metal i kontrola timerów.
//  Singleton umożliwiający zwalnianie pamięci z dowolnego miejsca w aplikacji.
//  Współdzielone zasoby Metal dla wszystkich miniaturek (device, commandQueue).
//
//  Created: January 2026
//

import Foundation
import Metal
import MetalKit
import SwiftUI
import Combine

// MARK: - Resource Notifications (poza @MainActor dla dostępu z dowolnego kontekstu)

enum ResourceNotifications {
    static let clearThumbnails = Notification.Name("ResourceManager.clearThumbnails")
    static let pauseTimers = Notification.Name("ResourceManager.pauseTimers")
    static let resumeTimers = Notification.Name("ResourceManager.resumeTimers")
}

// MARK: - Shared Metal Resources (poza @MainActor - dostępne z MTKViewDelegate)

/// Współdzielone zasoby Metal i cache - całkowicie poza MainActor dla dostępu z draw()
enum SharedMetalResources {
    
    /// Współdzielone urządzenie Metal - jeden dla całej aplikacji
    nonisolated(unsafe) static var device: MTLDevice? = MTLCreateSystemDefaultDevice()
    
    /// Współdzielona kolejka komend - jedna dla wszystkich miniaturek
    nonisolated(unsafe) static var commandQueue: MTLCommandQueue? = {
        device?.makeCommandQueue()
    }()
    
    /// Lock dla thread-safe dostępu do cache'ów
    private static let cacheLock = NSLock()
    
    /// Statyczny cache pipeline'ów (thread-safe)
    nonisolated(unsafe) private static var pipelineCache: [Int: MTLRenderPipelineState] = [:]
    
    /// Statyczny cache parametrów (thread-safe)
    nonisolated(unsafe) private static var parametersCache: [Int: (names: [String], defaults: [String: Float])] = [:]
    
    /// Pobierz pipeline z cache (thread-safe, nonisolated)
    static func getCachedPipeline(for shaderCode: String) -> MTLRenderPipelineState? {
        let hash = shaderCode.hashValue
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return pipelineCache[hash]
    }
    
    /// Zapisz pipeline do cache (thread-safe, nonisolated)
    static func setCachedPipeline(_ pipeline: MTLRenderPipelineState, for shaderCode: String) {
        let hash = shaderCode.hashValue
        cacheLock.lock()
        pipelineCache[hash] = pipeline
        cacheLock.unlock()
    }
    
    /// Pobierz parametry z cache (thread-safe, nonisolated)
    static func getCachedParameters(for shaderCode: String) -> (names: [String], defaults: [String: Float])? {
        let hash = shaderCode.hashValue
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return parametersCache[hash]
    }
    
    /// Zapisz parametry do cache (thread-safe, nonisolated)
    static func setCachedParameters(_ params: (names: [String], defaults: [String: Float]), for shaderCode: String) {
        let hash = shaderCode.hashValue
        cacheLock.lock()
        parametersCache[hash] = params
        cacheLock.unlock()
    }
    
    /// Wyczyść wszystkie cache'e (thread-safe)
    static func clearAllCaches() {
        cacheLock.lock()
        pipelineCache.removeAll()
        parametersCache.removeAll()
        cacheLock.unlock()
    }
    
    /// Liczba pipeline'ów w cache
    static var pipelineCount: Int {
        cacheLock.lock()
        defer { cacheLock.unlock() }
        return pipelineCache.count
    }
}

// MARK: - Resource Manager

/// Singleton zarządzający zasobami GPU i pamięcią
@MainActor
class ResourceManager: ObservableObject {
    
    // MARK: - Singleton
    
    static let shared = ResourceManager()
    
    // MARK: - Published State
    
    /// Liczba aktywnych pipeline'ów w cache
    @Published var cachedPipelineCount: Int = 0
    
    /// Czy timer parametrów jest aktywny
    @Published var isParameterTimerActive: Bool = true
    
    /// Czy automatyzacja jest globalnie zablokowana (po użyciu przycisku FREE)
    @Published var isAutomationBlocked: Bool = false
    
    // MARK: - Shared Metal Resources (aliasy dla wygody)
    
    /// Współdzielone urządzenie Metal (alias)
    var sharedDevice: MTLDevice? { SharedMetalResources.device }
    
    /// Współdzielona kolejka komend (alias)
    var sharedCommandQueue: MTLCommandQueue? { SharedMetalResources.commandQueue }
    
    /// Statyczne aliasy dla kompatybilności
    nonisolated static var sharedDeviceStatic: MTLDevice? { SharedMetalResources.device }
    nonisolated static var sharedCommandQueueStatic: MTLCommandQueue? { SharedMetalResources.commandQueue }
    
    // MARK: - Cache Storage (MainActor)
    
    /// Cache pipeline'ów Metal (klucz = hash kodu shadera)
    private var pipelineCache: [Int: MTLRenderPipelineState] = [:]
    
    /// Cache sparsowanych parametrów shadera (klucz = hash kodu)
    private var parsedParametersCache: [Int: (names: [String], defaults: [String: Float])] = [:]
    
    /// Notyfikacje - aliasy dla kompatybilności wstecznej
    nonisolated static var clearThumbnailsNotification: Notification.Name { ResourceNotifications.clearThumbnails }
    nonisolated static var pauseTimersNotification: Notification.Name { ResourceNotifications.pauseTimers }
    nonisolated static var resumeTimersNotification: Notification.Name { ResourceNotifications.resumeTimers }
    
    // MARK: - Initialization
    
    private init() {
        // Zasoby Metal są zainicjalizowane w SharedMetalResources
    }
    
    // MARK: - Pipeline Cache (MainActor)
    
    /// Pobierz lub stwórz pipeline state dla danego kodu shadera
    func getPipelineState(for shaderCode: String, device: MTLDevice, createIfNeeded: (() -> MTLRenderPipelineState?)? = nil) -> MTLRenderPipelineState? {
        let hash = shaderCode.hashValue
        
        if let cached = pipelineCache[hash] {
            return cached
        }
        
        if let creator = createIfNeeded, let newPipeline = creator() {
            pipelineCache[hash] = newPipeline
            cachedPipelineCount = pipelineCache.count
            return newPipeline
        }
        
        return nil
    }
    
    /// Pobierz pipeline używając współdzielonego device
    func getSharedPipelineState(for shaderCode: String, createIfNeeded: (() -> MTLRenderPipelineState?)? = nil) -> MTLRenderPipelineState? {
        guard let device = sharedDevice else { return nil }
        return getPipelineState(for: shaderCode, device: device, createIfNeeded: createIfNeeded)
    }
    
    /// Zapisz pipeline do cache
    func cachePipeline(_ pipeline: MTLRenderPipelineState, for shaderCode: String) {
        let hash = shaderCode.hashValue
        pipelineCache[hash] = pipeline
        cachedPipelineCount = pipelineCache.count
        // Zapisz też do statycznego cache (SharedMetalResources)
        SharedMetalResources.setCachedPipeline(pipeline, for: shaderCode)
    }
    
    /// Pobierz lub cache'uj sparsowane parametry shadera
    func getParsedParameters(for shaderCode: String, parser: () -> (names: [String], defaults: [String: Float])) -> (names: [String], defaults: [String: Float]) {
        let hash = shaderCode.hashValue
        
        if let cached = parsedParametersCache[hash] {
            return cached
        }
        
        let parsed = parser()
        parsedParametersCache[hash] = parsed
        // Zapisz też do statycznego cache (SharedMetalResources)
        SharedMetalResources.setCachedParameters(parsed, for: shaderCode)
        return parsed
    }
    
    /// Wyczyść całą pamięć podręczną pipeline'ów
    func clearPipelineCache() {
        pipelineCache.removeAll()
        parsedParametersCache.removeAll()
        SharedMetalResources.clearAllCaches()
        cachedPipelineCount = 0
    }
    
    /// Usuń konkretny pipeline z cache
    func removePipeline(for shaderCode: String) {
        let hash = shaderCode.hashValue
        pipelineCache.removeValue(forKey: hash)
        cachedPipelineCount = pipelineCache.count
    }
    
    // MARK: - Thumbnail Management
    
    /// Wyczyść wszystkie thumbnails - wyślij notyfikację do wszystkich ShaderThumbnailView
    func clearThumbnails() {
        NotificationCenter.default.post(name: Self.clearThumbnailsNotification, object: nil)
    }
    
    // MARK: - Automation Control
    
    /// Zablokuj automatyczne ładowanie automatyzacji (do momentu ręcznego odblokowania)
    func blockAutomation() {
        isAutomationBlocked = true
    }
    
    /// Odblokuj automatyczne ładowanie automatyzacji
    func unblockAutomation() {
        isAutomationBlocked = false
    }
    
    // MARK: - Timer Control
    
    /// Zatrzymaj timer synchronizacji parametrów (30fps)
    func pauseParameterTimer() {
        isParameterTimerActive = false
        NotificationCenter.default.post(name: Self.pauseTimersNotification, object: nil)
    }
    
    /// Wznów timer synchronizacji parametrów
    func resumeParameterTimer() {
        isParameterTimerActive = true
        NotificationCenter.default.post(name: Self.resumeTimersNotification, object: nil)
    }
    
    // MARK: - Full Cleanup
    
    /// Zwolnij wszystkie zasoby - pipeline cache, thumbnails, timery, zablokuj automatyzację
    func releaseAllResources() {
        // 1. Wyczyść cache pipeline'ów
        clearPipelineCache()
        
        // 2. Wyczyść thumbnails (wyślij notyfikację)
        clearThumbnails()
        
        // 3. Zatrzymaj timer parametrów (zostanie wznowiony gdy broadcast będzie potrzebny)
        pauseParameterTimer()
        
        // 4. Zablokuj automatyczne ładowanie automatyzacji
        blockAutomation()
    }
    
    // MARK: - Statistics
    
    /// Przybliżone użycie pamięci (szacunkowe)
    var estimatedMemoryUsageMB: Double {
        // Każdy pipeline ~1-5MB
        return Double(cachedPipelineCount) * 3.0
    }
    
    /// Opis stanu zasobów
    var resourcesDescription: String {
        return "Pipelines: \(cachedPipelineCount), Timer: \(isParameterTimerActive ? "ON" : "OFF")"
    }
}

// MARK: - Convenience Extensions

extension Notification.Name {
    static let clearShaderThumbnails = ResourceNotifications.clearThumbnails
    static let pauseShaderTimers = ResourceNotifications.pauseTimers
    static let resumeShaderTimers = ResourceNotifications.resumeTimers
}
