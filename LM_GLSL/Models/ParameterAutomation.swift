//
//  ParameterAutomation.swift
//  LM_GLSL
//
//  Model for recording and playing back parameter automation
//

import Foundation
import SwiftUI
import Combine

// MARK: - Automation Keyframe

struct AutomationKeyframe: Codable {
    let time: Double           // Time in seconds from start
    let parameterName: String  // Which parameter
    let value: Float           // Value at this time
}

// MARK: - Automation Recording

struct AutomationRecording: Codable, Identifiable {
    let id: UUID
    var keyframes: [AutomationKeyframe]
    var duration: Double       // Total recording duration
    var recordedAt: Date
    
    init() {
        self.id = UUID()
        self.keyframes = []
        self.duration = 0
        self.recordedAt = Date()
    }
}

// MARK: - Automation State

enum AutomationState {
    case idle
    case countdown(Int)        // Countdown seconds remaining
    case recording
    case playing
}

// MARK: - Automation Manager

@MainActor
class ParameterAutomationManager: ObservableObject {
    @Published var state: AutomationState = .idle
    @Published var currentRecording: AutomationRecording?
    @Published var playbackTime: Double = 0
    @Published var isLooping: Bool = true
    
    private var recordingStartTime: Date?
    private var playbackTimer: Timer?
    private var countdownTimer: Timer?
    private var lastRecordedValues: [String: Float] = [:]
    
    // Callback to update parameters during playback
    var onParameterUpdate: ((String, Float) -> Void)?
    
    // MARK: - Recording Controls
    
    func startRecordingWithCountdown() {
        guard case .idle = state else { return }
        
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
                    self.startRecording()
                }
            }
        }
    }
    
    private func startRecording() {
        currentRecording = AutomationRecording()
        recordingStartTime = Date()
        lastRecordedValues = [:]
        state = .recording
    }
    
    func stopRecording() {
        guard case .recording = state else { return }
        
        if var recording = currentRecording, let startTime = recordingStartTime {
            recording.duration = Date().timeIntervalSince(startTime)
            currentRecording = recording
        }
        
        recordingStartTime = nil
        state = .idle
        
        // Auto-start playback if we have keyframes
        if let recording = currentRecording, !recording.keyframes.isEmpty {
            startPlayback()
        }
    }
    
    func cancelRecording() {
        countdownTimer?.invalidate()
        countdownTimer = nil
        recordingStartTime = nil
        state = .idle
    }
    
    // MARK: - Record Parameter Change
    
    func recordParameterChange(name: String, value: Float) {
        guard case .recording = state,
              let startTime = recordingStartTime else { return }
        
        // Only record if value actually changed
        if let lastValue = lastRecordedValues[name], abs(lastValue - value) < 0.001 {
            return
        }
        
        lastRecordedValues[name] = value
        
        let time = Date().timeIntervalSince(startTime)
        let keyframe = AutomationKeyframe(time: time, parameterName: name, value: value)
        currentRecording?.keyframes.append(keyframe)
    }
    
    // MARK: - Playback Controls
    
    func startPlayback() {
        guard let recording = currentRecording,
              !recording.keyframes.isEmpty,
              recording.duration > 0 else { return }
        
        playbackTime = 0
        state = .playing
        
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
        state = .idle
    }
    
    func togglePlayback() {
        if case .playing = state {
            stopPlayback()
        } else if currentRecording != nil {
            startPlayback()
        }
    }
    
    private func updatePlayback() {
        guard let recording = currentRecording else {
            stopPlayback()
            return
        }
        
        playbackTime += 1.0 / 60.0
        
        // Loop or stop at end
        if playbackTime >= recording.duration {
            if isLooping {
                playbackTime = 0
            } else {
                stopPlayback()
                return
            }
        }
        
        // Find and apply interpolated values for each parameter
        applyKeyframesAtTime(playbackTime, recording: recording)
    }
    
    private func applyKeyframesAtTime(_ time: Double, recording: AutomationRecording) {
        // Group keyframes by parameter
        let parameterNames = Set(recording.keyframes.map { $0.parameterName })
        
        for paramName in parameterNames {
            let paramKeyframes = recording.keyframes
                .filter { $0.parameterName == paramName }
                .sorted { $0.time < $1.time }
            
            guard !paramKeyframes.isEmpty else { continue }
            
            // Find surrounding keyframes for interpolation
            var beforeKeyframe: AutomationKeyframe?
            var afterKeyframe: AutomationKeyframe?
            
            for kf in paramKeyframes {
                if kf.time <= time {
                    beforeKeyframe = kf
                } else {
                    afterKeyframe = kf
                    break
                }
            }
            
            // Calculate interpolated value
            let value: Float
            if let before = beforeKeyframe, let after = afterKeyframe {
                // Linear interpolation
                let t = Float((time - before.time) / (after.time - before.time))
                value = before.value + (after.value - before.value) * t
            } else if let before = beforeKeyframe {
                value = before.value
            } else if let after = afterKeyframe {
                value = after.value
            } else {
                continue
            }
            
            onParameterUpdate?(paramName, value)
        }
    }
    
    // MARK: - Clear Recording
    
    func clearRecording() {
        stopPlayback()
        currentRecording = nil
        state = .idle
    }
    
    // MARK: - State Helpers
    
    var isRecording: Bool {
        if case .recording = state { return true }
        return false
    }
    
    var isPlaying: Bool {
        if case .playing = state { return true }
        return false
    }
    
    var isCountingDown: Bool {
        if case .countdown = state { return true }
        return false
    }
    
    var hasRecording: Bool {
        guard let recording = currentRecording else { return false }
        return !recording.keyframes.isEmpty
    }
    
    var recordingDuration: Double {
        currentRecording?.duration ?? 0
    }
    
    var keyframeCount: Int {
        currentRecording?.keyframes.count ?? 0
    }
}
