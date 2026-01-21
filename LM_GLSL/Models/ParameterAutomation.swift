//
//  ParameterAutomation.swift
//  LM_GLSL
//
//  Model for recording and playing back parameter automation
//  Each parameter has its own automation track (overdub support)
//

import Foundation
import SwiftUI
import Combine

// MARK: - Automation Keyframe

struct AutomationKeyframe: Codable {
    let time: Double           // Time in seconds from start
    let value: Float           // Value at this time
}

// MARK: - Parameter Automation Track

struct ParameterAutomationTrack: Codable, Identifiable {
    let id: UUID
    let parameterName: String
    var keyframes: [AutomationKeyframe]
    
    init(parameterName: String) {
        self.id = UUID()
        self.parameterName = parameterName
        self.keyframes = []
    }
    
    var duration: Double {
        keyframes.last?.time ?? 0
    }
    
    var isEmpty: Bool {
        keyframes.isEmpty
    }
    
    /// Get interpolated value at time
    func valueAt(time: Double) -> Float? {
        guard !keyframes.isEmpty else { return nil }
        
        let sorted = keyframes.sorted { $0.time < $1.time }
        
        // Find surrounding keyframes
        var before: AutomationKeyframe?
        var after: AutomationKeyframe?
        
        for kf in sorted {
            if kf.time <= time {
                before = kf
            } else {
                after = kf
                break
            }
        }
        
        // Interpolate
        if let b = before, let a = after {
            let t = Float((time - b.time) / (a.time - b.time))
            return b.value + (a.value - b.value) * t
        } else if let b = before {
            return b.value
        } else if let a = after {
            return a.value
        }
        
        return nil
    }
}

// MARK: - Automation State

enum AutomationState: Equatable {
    case idle
    case countdown(Int)
    case recording
    case playing
    case playingAndRecording  // Overdub mode
}

// MARK: - Automation Manager
// NOTE: NOT ObservableObject - no SwiftUI observation to avoid expensive rebuilds
// UI reads state directly via timer/polling

@MainActor
class ParameterAutomationManager {
    // State - NOT @Published to avoid view rebuilds
    var state: AutomationState = .idle
    var tracks: [String: ParameterAutomationTrack] = [:]  // parameterName -> track
    var playbackTime: Double = 0
    var loopDuration: Double = 0  // Max duration of all tracks
    var isLooping: Bool = true
    
    private var recordingStartTime: Date?
    private var playbackStartTime: Date?
    private var playbackTimer: Timer?
    private var countdownTimer: Timer?
    private var lastRecordedValues: [String: Float] = [:]
    
    // Callback to update parameters during playback
    var onParameterUpdate: ((String, Float) -> Void)?
    
    // MARK: - Recording Controls (Overdub)
    
    func startRecordingWithCountdown() {
        // Can start recording while playing (overdub)
        guard state == .idle || state == .playing else { return }
        
        let wasPlaying = state == .playing
        
        state = .countdown(3)
        
        var countdown = 3
        countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            Task { @MainActor in
                guard let self = self else {
                    timer.invalidate()
                    return
                }
                
                countdown -= 1
                if countdown > 0 {
                    self.state = .countdown(countdown)
                } else {
                    timer.invalidate()
                    self.startRecording(wasPlaying: wasPlaying)
                }
            }
        }
    }
    
    private func startRecording(wasPlaying: Bool) {
        if wasPlaying {
            // Overdub - continue playback, sync recording to playback time
            recordingStartTime = Date().addingTimeInterval(-playbackTime)
            state = .playingAndRecording
        } else {
            // Fresh recording
            recordingStartTime = Date()
            playbackTime = 0
            state = .recording
            
            // Start playback timer for time tracking
            startPlaybackTimer()
        }
        
        lastRecordedValues = [:]
    }
    
    func stopRecording() {
        guard state == .recording || state == .playingAndRecording else { return }
        
        let wasOverdub = state == .playingAndRecording
        
        // Update loop duration
        updateLoopDuration()
        
        recordingStartTime = nil
        
        if wasOverdub || hasAnyRecording {
            // Continue playing
            state = .playing
        } else {
            stopPlayback()
            state = .idle
        }
        
        // Auto-start playback if we have recordings
        if hasAnyRecording && state == .idle {
            startPlayback()
        }
    }
    
    func cancelCountdown() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        
        if hasAnyRecording {
            state = .playing
            if playbackTimer == nil {
                startPlayback()
            }
        } else {
            state = .idle
        }
    }
    
    // MARK: - Record Parameter Change
    
    func recordParameterChange(name: String, value: Float) {
        guard state == .recording || state == .playingAndRecording else { return }
        
        // Only record if value actually changed significantly
        if let lastValue = lastRecordedValues[name], abs(lastValue - value) < 0.001 {
            return
        }
        
        lastRecordedValues[name] = value
        
        let time = playbackTime
        let keyframe = AutomationKeyframe(time: time, value: value)
        
        // Get or create track for this parameter
        if tracks[name] == nil {
            tracks[name] = ParameterAutomationTrack(parameterName: name)
        }
        
        // In overdub, remove old keyframes near this time for this parameter
        if state == .playingAndRecording {
            tracks[name]?.keyframes.removeAll { abs($0.time - time) < 0.05 }
        }
        
        tracks[name]?.keyframes.append(keyframe)
    }
    
    // MARK: - Playback Controls
    
    func startPlayback() {
        guard hasAnyRecording else { return }
        
        updateLoopDuration()
        playbackTime = 0
        playbackStartTime = Date()
        state = .playing
        
        startPlaybackTimer()
    }
    
    private func startPlaybackTimer() {
        playbackTimer?.invalidate()
        
        let interval: TimeInterval = 1.0 / 60.0  // 60 FPS
        playbackTimer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.updatePlayback()
            }
        }
    }
    
    func stopPlayback() {
        playbackTimer?.invalidate()
        playbackTimer = nil
        playbackStartTime = nil
        
        if state != .recording {
            state = .idle
        }
    }
    
    func togglePlayback() {
        switch state {
        case .playing, .playingAndRecording:
            if state == .playingAndRecording {
                stopRecording()
            }
            stopPlayback()
        case .idle:
            if hasAnyRecording {
                startPlayback()
            }
        default:
            break
        }
    }
    
    private func updatePlayback() {
        playbackTime += 1.0 / 60.0
        
        // Loop
        if loopDuration > 0 && playbackTime >= loopDuration {
            if isLooping {
                playbackTime = 0
            } else if state == .playing {
                stopPlayback()
                return
            }
        }
        
        // Apply automation for parameters not currently being recorded
        applyAutomation()
    }
    
    private func applyAutomation() {
        for (paramName, track) in tracks {
            // Skip if we're actively recording this parameter (user is touching slider)
            if (state == .recording || state == .playingAndRecording),
               lastRecordedValues[paramName] != nil {
                continue
            }
            
            if let value = track.valueAt(time: playbackTime) {
                onParameterUpdate?(paramName, value)
            }
        }
    }
    
    private func updateLoopDuration() {
        loopDuration = tracks.values.map { $0.duration }.max() ?? 0
    }
    
    // MARK: - Clear
    
    func clearAllTracks() {
        stopPlayback()
        tracks.removeAll()
        loopDuration = 0
        state = .idle
    }
    
    func clearTrack(parameterName: String) {
        tracks.removeValue(forKey: parameterName)
        updateLoopDuration()
        
        if !hasAnyRecording {
            stopPlayback()
        }
    }
    
    // MARK: - State Helpers
    
    var isRecording: Bool {
        state == .recording || state == .playingAndRecording
    }
    
    var isPlaying: Bool {
        state == .playing || state == .playingAndRecording
    }
    
    var isCountingDown: Bool {
        if case .countdown = state { return true }
        return false
    }
    
    var hasAnyRecording: Bool {
        tracks.values.contains { !$0.isEmpty }
    }
    
    var totalKeyframeCount: Int {
        tracks.values.reduce(0) { $0 + $1.keyframes.count }
    }
    
    func hasAutomation(for parameterName: String) -> Bool {
        guard let track = tracks[parameterName] else { return false }
        return !track.isEmpty
    }
    
    func keyframeCount(for parameterName: String) -> Int {
        tracks[parameterName]?.keyframes.count ?? 0
    }
    
    // MARK: - Serialization (Save/Load)
    
    /// Export tracks to Data for saving
    func exportToData() -> Data? {
        guard hasAnyRecording else { return nil }
        
        let tracksArray = Array(tracks.values)
        return try? JSONEncoder().encode(tracksArray)
    }
    
    /// Import tracks from Data
    func importFromData(_ data: Data?) {
        guard let data = data else { return }
        
        do {
            let tracksArray = try JSONDecoder().decode([ParameterAutomationTrack].self, from: data)
            tracks = Dictionary(uniqueKeysWithValues: tracksArray.map { ($0.parameterName, $0) })
            updateLoopDuration()
        } catch {
            print("Failed to decode automation data: \(error)")
        }
    }
    
    /// Load and auto-start playback if there's automation
    func loadAndPlay(from data: Data?) {
        importFromData(data)
        if hasAnyRecording {
            startPlayback()
        }
    }
    
    // MARK: - Preset Management (P1-P16)
    
    /// Pojedynczy preset automatyzacji - zawiera stan tracków
    struct AutomationPreset: Codable {
        let index: Int  // 0-15 (P1-P16)
        let tracks: [ParameterAutomationTrack]
        let loopDuration: Double
        let createdAt: Date
    }
    
    /// 16 slotów presetów (nil = pusty slot)
    var presets: [Int: AutomationPreset] = [:]
    
    /// Zapisz aktualną automatyzację do slotu
    func savePresetToSlot(index: Int) {
        guard hasAnyRecording else { return }
        
        let preset = AutomationPreset(
            index: index,
            tracks: Array(tracks.values),
            loopDuration: loopDuration,
            createdAt: Date()
        )
        presets[index] = preset
        print("💾 Saved automation preset to slot P\(index + 1) (\(tracks.count) tracks)")
    }
    
    /// Wczytaj preset ze slotu
    func loadPresetFromSlot(index: Int) {
        guard let preset = presets[index] else {
            print("⚠️ No preset in slot P\(index + 1)")
            return
        }
        
        // Zastąp aktualne tracki presetem
        tracks = Dictionary(uniqueKeysWithValues: preset.tracks.map { ($0.parameterName, $0) })
        loopDuration = preset.loopDuration
        
        print("📂 Loaded automation preset from P\(index + 1) (\(tracks.count) tracks)")
        
        // Auto-start playback
        if hasAnyRecording {
            startPlayback()
        }
    }
    
    /// Usuń preset ze slotu
    func deletePresetFromSlot(index: Int) {
        guard presets[index] != nil else {
            print("⚠️ No preset to delete in slot P\(index + 1)")
            return
        }
        
        presets.removeValue(forKey: index)
        print("🗑 Deleted automation preset from slot P\(index + 1)")
    }
    
    /// Sprawdź czy slot ma preset
    func hasPreset(at index: Int) -> Bool {
        return presets[index] != nil
    }
    
    /// Pobierz liczbę tracków w presecie
    func trackCount(at index: Int) -> Int {
        return presets[index]?.tracks.count ?? 0
    }
    
    /// Eksportuj presety do Data
    func exportPresetsToData() -> Data? {
        guard !presets.isEmpty else { return nil }
        let presetsArray = Array(presets.values)
        return try? JSONEncoder().encode(presetsArray)
    }
    
    /// Importuj presety z Data
    func importPresetsFromData(_ data: Data?) {
        // Najpierw wyczyść stare presety
        presets.removeAll()
        
        guard let data = data else {
            print("📥 Cleared automation presets (no data)")
            return
        }
        
        do {
            let presetsArray = try JSONDecoder().decode([AutomationPreset].self, from: data)
            presets = Dictionary(uniqueKeysWithValues: presetsArray.map { ($0.index, $0) })
            print("📥 Imported \(presets.count) automation presets")
        } catch {
            print("Failed to decode automation presets: \(error)")
        }
    }
}
