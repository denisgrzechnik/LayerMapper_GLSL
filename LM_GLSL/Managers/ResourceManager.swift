//
//  ResourceManager.swift
//  LM_GLSL
//
//  Centralny manager zasobów GPU - cache pipeline'ów Metal i kontrola timerów.
//  Singleton umożliwiający zwalnianie pamięci z dowolnego miejsca w aplikacji.
//
//  Created: January 2026
//

import Foundation
import Metal
import MetalKit
import SwiftUI
import Combine

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
    
    // MARK: - Cache Storage
    
    /// Cache pipeline'ów Metal (klucz = hash kodu shadera)
    private var pipelineCache: [Int: MTLRenderPipelineState] = [:]
    
    /// Notyfikacja do odświeżenia thumbnailów
    static let clearThumbnailsNotification = Notification.Name("ResourceManager.clearThumbnails")
    
    /// Notyfikacja do zatrzymania timerów
    static let pauseTimersNotification = Notification.Name("ResourceManager.pauseTimers")
    
    /// Notyfikacja do wznowienia timerów
    static let resumeTimersNotification = Notification.Name("ResourceManager.resumeTimers")
    
    // MARK: - Initialization
    
    private init() {
        // Inicjalizacja bez logów
    }
    
    // MARK: - Pipeline Cache
    
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
    
    /// Zapisz pipeline do cache
    func cachePipeline(_ pipeline: MTLRenderPipelineState, for shaderCode: String) {
        let hash = shaderCode.hashValue
        pipelineCache[hash] = pipeline
        cachedPipelineCount = pipelineCache.count
    }
    
    /// Wyczyść całą pamięć podręczną pipeline'ów
    func clearPipelineCache() {
        pipelineCache.removeAll()
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
    static let clearShaderThumbnails = ResourceManager.clearThumbnailsNotification
    static let pauseShaderTimers = ResourceManager.pauseTimersNotification
    static let resumeShaderTimers = ResourceManager.resumeTimersNotification
}
