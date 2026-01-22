//
//  ShaderParametersView.swift
//  LM_GLSL
//
//  Comprehensive parameter control view for shaders
//  Layout: Preview (top-left), Controls (bottom-left), Sliders (top-right), AI (bottom-right)
//

import SwiftUI
import SwiftData

struct ShaderParametersView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Bindable var shader: ShaderEntity
    @ObservedObject var parametersVM: ShaderParametersViewModel
    // Don't observe automationManager to avoid 60fps view rebuilds - just hold reference
    var automationManager: ParameterAutomationManager
    @StateObject private var aiService = AIShaderService.shared
    
    // Local state for automation UI (updated sparingly, not 60fps)
    @State private var automationState: AutomationState = .idle
    @State private var hasRecording: Bool = false
    @State private var displayPlaybackTime: Double = 0
    
    // AI Generation
    @State private var aiPrompt: String = ""
    @State private var selectedProvider: AIProvider = .groq
    @State private var showAPIKeySheet = false
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 0
    @State private var isFullscreen: Bool = false
    @State private var showSettings: Bool = false
    
    // Control panel selection
    @State private var selectedControlPanel: ControlPanelType = .grid
    
    // Slider page selection (1, 2, 3) - each page shows up to 12 sliders
    @State private var selectedSliderPage: Int = 0
    
    enum ControlPanelType: String, CaseIterable {
        case grid = "Grid"
        case pad = "Pad"
        case knobs = "Knobs"
    }
    
    var body: some View {
        ZStack {
            mainContent
            
            // Fullscreen overlay
            if isFullscreen {
                fullscreenOverlay
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: isFullscreen)
        .sheet(isPresented: $showSettings) {
            ShaderSettingsView(shader: shader)
        }
    }
    
    private var mainContent: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                // Landscape layout (4 quadrants)
                HStack(spacing: 0) {
                    // Left side - Preview (70%)
                    VStack(spacing: 0) {
                        // Top-left: Preview
                        shaderPreviewPanel
                            .frame(height: geometry.size.height * 0.62)
                        
                        // Bottom-left: Control panels (one row of buttons)
                        controlPanelsSection
                            .frame(height: geometry.size.height * 0.38)
                    }
                    .frame(width: geometry.size.width * 0.7)
                    
                    // Right side - Controls (30%)
                    VStack(spacing: 0) {
                        // Top: Sliders (fills remaining space)
                        slidersPanel
                        
                        // Middle: Animation Presets (P1-P16) - fixed height
                        AutomationPresetPanel(
                            automationManager: automationManager,
                            shader: shader,
                            hasRecording: hasRecording
                        )
                        .frame(height: 80)
                        
                        // Bottom: AI Generator - fixed height
                        aiGeneratorPanel
                            .frame(height: 160)
                        
                        // Bottom margin for safe area
                        Spacer()
                            .frame(height: 20)
                    }
                    .frame(width: geometry.size.width * 0.3)
                }
            } else {
                // Portrait layout (scrollable)
                ScrollView {
                    VStack(spacing: 12) {
                        shaderPreviewPanel
                        
                        slidersPanel
                            .frame(minHeight: 200)
                        
                        // Animation Presets Panel (P1-P16)
                        AutomationPresetPanel(
                            automationManager: automationManager,
                            shader: shader,
                            hasRecording: hasRecording
                        )
                        
                        controlPanelsSection
                            .frame(height: 250)
                        
                        aiGeneratorPanel
                            .frame(minHeight: 180)
                    }
                    .padding(10)
                }
            }
        }
        .background(Color.black)
        .navigationTitle(shader.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    saveChanges()
                    dismiss()
                }
                .fontWeight(.semibold)
            }
        }
        .onAppear {
            // Parameters are already loaded in shared parametersVM from ContentView
            // Only parse if empty (first time or shader changed)
            if parametersVM.parameters.isEmpty {
                parametersVM.updateFromCode(shader.fragmentCode)
                
                // Apply saved values from ShaderParameterEntity (SwiftData)
                if let savedParams = shader.parameters {
                    for savedParam in savedParams {
                        if let index = parametersVM.parameters.firstIndex(where: { $0.name == savedParam.name }) {
                            parametersVM.parameters[index].currentValue = savedParam.floatValue
                        }
                    }
                }
            }
            
            // Initialize AI with current shader code as context
            aiService.initializeWithShaderContext(shader.fragmentCode)
            
            // Automation is already loaded and playing via shared automationManager from ContentView
            // Just ensure callback is set (it may have been cleared)
            automationManager.onParameterUpdate = { [weak parametersVM] name, value in
                guard let vm = parametersVM else { return }
                if let index = vm.parameters.firstIndex(where: { $0.name == name }) {
                    vm.parameters[index].currentValue = value
                }
            }
            
            // Load automation presets from shader
            automationManager.importPresetsFromData(shader.automationPresetsData)
            
            // Initialize local UI state from automationManager
            updateAutomationUIState()
        }
        .onDisappear {
            // Save parameters and automation when leaving
            saveChanges()
            shader.automationData = automationManager.exportToData()
            shader.automationPresetsData = automationManager.exportPresetsToData()
            try? modelContext.save()
        }
        .onChange(of: shader.fragmentCode) { _, newCode in
            parametersVM.updateFromCode(newCode)
        }
        // Timer to update automation UI state at low frequency (5fps) to avoid expensive view rebuilds
        .onReceive(Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()) { _ in
            updateAutomationUIState()
        }
        .sheet(isPresented: $showAPIKeySheet) {
            APIKeySettingsSheet(provider: selectedProvider)
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Fullscreen Overlay
    
    private var fullscreenOverlay: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            MetalShaderView(
                shaderCode: shader.fragmentCode,
                isPlaying: $isPlaying,
                currentTime: $currentTime,
                parametersVM: parametersVM
            )
            .ignoresSafeArea()
            .onTapGesture(count: 2) {
                isFullscreen = false
            }
        }
    }
    
    // MARK: - Shader Preview Panel
    
    private var shaderPreviewPanel: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Text(shader.name)
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Settings button
                Button {
                    showSettings = true
                } label: {
                    Image(systemName: "gearshape.fill")
                        .foregroundColor(.white.opacity(0.8))
                }
                
                // Play/Pause
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.fill" : "play.fill")
                        .foregroundColor(.white)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(Color.black.opacity(0.5))
            
            // Preview - landscape shader with 16:9 aspect ratio
            MetalShaderView(
                shaderCode: shader.fragmentCode,
                isPlaying: $isPlaying,
                currentTime: $currentTime,
                parametersVM: parametersVM
            )
            .aspectRatio(16.0/9.0, contentMode: .fit)
            .clipped()
            .contentShape(Rectangle())
            .onTapGesture(count: 2) {
                isFullscreen = true
            }
            .simultaneousGesture(
                DragGesture(minimumDistance: 30)
                    .onEnded { value in
                        // Swipe down to dismiss
                        if value.translation.height > 60 && abs(value.translation.width) < abs(value.translation.height) {
                            saveChanges()
                            dismiss()
                        }
                    }
            )
        }
        .background(Color.black)
    }
    
    // MARK: - Sliders Panel
    
    private var slidersPanel: some View {
        VStack(spacing: 0) {
            // Header with Page buttons, Record and Close buttons
            HStack(spacing: 8) {
                // Page selection buttons (1, 2, 3)
                HStack(spacing: 4) {
                    ForEach(0..<3, id: \.self) { page in
                        Button {
                            selectedSliderPage = page
                        } label: {
                            Text("\(page + 1)")
                                .font(.caption.bold())
                                .foregroundColor(selectedSliderPage == page ? .white : .gray)
                                .frame(width: 24, height: 24)
                                .background(selectedSliderPage == page ? Color(red: 254/255, green: 20/255, blue: 77/255) : Color(white: 0.2))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                }
                
                Spacer()
                
                // Automation status/playback indicator
                if hasRecording {
                    HStack(spacing: 4) {
                        Text(String(format: "%.1fs", displayPlaybackTime))
                            .font(.caption2.monospacedDigit())
                    }
                    .foregroundColor(automationState == .playing || automationState == .playingAndRecording ? .green : .gray)
                }
                
                // Play/Pause button (only when recording exists)
                if hasRecording {
                    playPauseButton
                }
                
                // Record button (always visible) - simple dot
                recordButton
                
                // Clear button (only when recording exists)
                if hasRecording {
                    clearButton
                }
                
                // Close button
                Button {
                    saveChanges()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(6)
                        .background(Color(white: 0.2))
                        .clipShape(Circle())
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            
            // Sliders - paginated, 12 per page
            ScrollView {
                VStack(spacing: 2) {
                    let sliderParams = parametersVM.parameters.filter { $0.type == .slider }
                    let startIndex = selectedSliderPage * 12
                    
                    if sliderParams.isEmpty {
                        Text("No slider parameters")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    } else if startIndex >= sliderParams.count {
                        Text("No parameters on this page")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        let endIndex = min(startIndex + 12, sliderParams.count)
                        let pageParams = Array(sliderParams[startIndex..<endIndex])
                        
                        ForEach(Array(pageParams.enumerated()), id: \.element.id) { localIndex, param in
                            let globalIndex = startIndex + localIndex
                            StyledSliderRow(
                                parameter: param,  // Przekaż wartość, NIE binding!
                                color: sliderColor(for: globalIndex),
                                onValueChanged: { name, value in
                                    // Aktualizuj ViewModel bezpośrednio - BEZ przebudowy widoku!
                                    parametersVM.updateParameter(id: param.id, value: value)
                                    automationManager.recordParameterChange(name: name, value: value)
                                }
                            )
                        }
                    }
                }
            }
        }
        .background(Color(white: 0.1))
    }
    
    private func sliderColor(for index: Int) -> Color {
        // Same colors as XY Pads: #FE144D, #00963C, #0076C0
        let colors: [Color] = [
            Color(red: 254/255, green: 20/255, blue: 77/255),   // #FE144D - Red/Pink
            Color(red: 0/255, green: 150/255, blue: 60/255),    // #00963C - Green
            Color(red: 0/255, green: 118/255, blue: 192/255)    // #0076C0 - Blue
        ]
        return colors[index % colors.count]
    }
    
    // MARK: - Play/Pause Button
    
    private var playPauseButton: some View {
        Button {
            automationManager.togglePlayback()
            updateAutomationUIState()
        } label: {
            Image(systemName: automationState == .playing || automationState == .playingAndRecording ? "pause.fill" : "play.fill")
                .font(.caption)
                .foregroundColor(.green)
                .padding(6)
                .background(Color.green.opacity(0.2))
                .clipShape(Circle())
        }
    }
    
    // MARK: - Record Button (simple dot)
    
    private var recordButton: some View {
        Button {
            handleRecordButtonTap()
            updateAutomationUIState()
        } label: {
            ZStack {
                Circle()
                    .fill(recordButtonColor.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                if case .countdown(let seconds) = automationState {
                    // Show countdown number
                    Text("\(seconds)")
                        .font(.caption.bold())
                        .foregroundColor(.orange)
                } else {
                    // Show record dot
                    let isRecording = automationState == .recording || automationState == .playingAndRecording
                    Circle()
                        .fill(recordButtonColor)
                        .frame(width: isRecording ? 10 : 8, height: isRecording ? 10 : 8)
                }
            }
        }
    }
    
    private var recordButtonColor: Color {
        switch automationState {
        case .recording, .playingAndRecording:
            return .red
        case .countdown:
            return .orange
        case .playing, .idle:
            return .red
        }
    }
    
    private func handleRecordButtonTap() {
        switch automationState {
        case .idle, .playing:
            // Overdub - don't stop playback, start recording on top
            automationManager.startRecordingWithCountdown()
        case .countdown:
            automationManager.cancelCountdown()
        case .recording, .playingAndRecording:
            automationManager.stopRecording()
        }
    }
    
    // MARK: - Update UI State from AutomationManager
    
    private func updateAutomationUIState() {
        automationState = automationManager.state
        hasRecording = automationManager.hasAnyRecording
        displayPlaybackTime = automationManager.playbackTime
    }
    
    // MARK: - Clear Button
    
    private var clearButton: some View {
        Button {
            automationManager.clearAllTracks()
            // Also clear saved automation data from shader
            shader.automationData = nil
            updateAutomationUIState()
        } label: {
            ZStack {
                Circle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 28, height: 28)
                
                Image(systemName: "trash")
                    .font(.system(size: 12))
                    .foregroundColor(.gray)
            }
        }
    }
    
    // MARK: - Control Panels Section
    
    private var controlPanelsSection: some View {
        VStack(spacing: 0) {
            // Tab selector
            HStack(spacing: 0) {
                ForEach(ControlPanelType.allCases, id: \.self) { type in
                    Button {
                        selectedControlPanel = type
                    } label: {
                        Text(type.rawValue)
                            .font(.caption.bold())
                            .foregroundColor(selectedControlPanel == type ? .white : .gray)
                            .padding(.vertical, 8)
                            .frame(maxWidth: .infinity)
                            .background(selectedControlPanel == type ? Color(white: 0.2) : Color.clear)
                    }
                }
            }
            .background(Color(white: 0.1))
            
            // Control panel content
            Group {
                switch selectedControlPanel {
                case .grid:
                    ButtonGridPanel(
                        parameters: parametersVM.parameters,
                        onToggle: { id, value in
                            parametersVM.updateParameter(id: id, value: value)
                        },
                        onValueChanged: { name, value in
                            automationManager.recordParameterChange(name: name, value: value)
                        }
                    )
                case .pad:
                    XYPadPanel(
                        parameters: parametersVM.parameters,
                        onUpdate: { id, value in
                            parametersVM.updateParameter(id: id, value: value)
                        },
                        onValueChanged: { name, value in
                            automationManager.recordParameterChange(name: name, value: value)
                        }
                    )
                case .knobs:
                    KnobsPanel(
                        parameters: parametersVM.parameters,
                        onUpdate: { id, value in
                            parametersVM.updateParameter(id: id, value: value)
                        },
                        onValueChanged: { name, value in
                            automationManager.recordParameterChange(name: name, value: value)
                        }
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
        }
    }
    
    // MARK: - AI Generator Panel
    
    private var aiGeneratorPanel: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Text("AI SHADER")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Provider picker (compact) - Red color matching Modify button #FE144D
                Picker("", selection: $selectedProvider) {
                    ForEach(AIProvider.allCases) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                .pickerStyle(.menu)
                .tint(Color(red: 254/255, green: 20/255, blue: 77/255))  // #FE144D
                
                // API Key button
                if selectedProvider.requiresAPIKey {
                    Button {
                        showAPIKeySheet = true
                    } label: {
                        Image(systemName: hasAPIKey ? "key.fill" : "key")
                            .foregroundColor(hasAPIKey ? .green : .orange)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            
            // Prompt input
            TextField(promptPlaceholder, text: $aiPrompt, axis: .vertical)
                .lineLimit(2...3)
                .padding(8)
                .background(Color(white: 0.15))
                .padding(.horizontal, 12)
            
            // Generate button
            HStack(spacing: 8) {
                Button {
                    generateWithAI()
                } label: {
                    HStack {
                        if aiService.isGenerating {
                            ProgressView()
                                .scaleEffect(0.8)
                                .tint(.white)
                        } else {
                            Image(systemName: "arrow.triangle.2.circlepath")
                        }
                        Text(generateButtonText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                    .background(Color(red: 254/255, green: 20/255, blue: 77/255))
                    .foregroundColor(.white)
                }
                .disabled(aiPrompt.isEmpty || aiService.isGenerating || (selectedProvider.requiresAPIKey && !hasAPIKey))
                .opacity((aiPrompt.isEmpty || aiService.isGenerating || (selectedProvider.requiresAPIKey && !hasAPIKey)) ? 0.5 : 1)
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            // Error message
            if let error = aiService.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal, 12)
            }
        }
        .background(Color(white: 0.08))
    }
    
    // MARK: - Computed Properties
    
    private var hasAPIKey: Bool {
        guard let key = aiService.getAPIKey(for: selectedProvider) else { return false }
        return !key.isEmpty
    }
    
    private var promptPlaceholder: String {
        "Modify: 'slower', 'change color to blue', 'add slider'..."
    }
    
    private var generateButtonText: String {
        if aiService.isGenerating { return "Generating..." }
        return "Modify"
    }
    
    // MARK: - Actions
    
    private func generateWithAI() {
        Task {
            // Always pass current code - we're modifying existing shader
            if let generatedCode = await aiService.generateShader(
                prompt: aiPrompt,
                currentCode: shader.fragmentCode,
                provider: selectedProvider
            ) {
                shader.fragmentCode = generatedCode
                parametersVM.updateFromCode(generatedCode)
                aiPrompt = ""
            }
        }
    }
    
    private func saveChanges() {
        // Save parameter values from parametersVM back to shader.parameters (SwiftData)
        for param in parametersVM.parameters {
            // Find or create matching ShaderParameterEntity
            if let existingParam = shader.parameters?.first(where: { $0.name == param.name }) {
                // Update existing parameter
                existingParam.floatValue = param.currentValue
                existingParam.defaultValue = param.defaultValue
                existingParam.minValue = param.minValue
                existingParam.maxValue = param.maxValue
            } else {
                // Create new parameter entity
                let newEntity = ShaderParameterEntity(
                    name: param.name,
                    displayName: param.displayName,
                    floatValue: param.currentValue,
                    minValue: param.minValue,
                    maxValue: param.maxValue,
                    defaultValue: param.defaultValue
                )
                newEntity.shader = shader
                if shader.parameters == nil {
                    shader.parameters = []
                }
                shader.parameters?.append(newEntity)
            }
        }
        
        try? modelContext.save()
        print("💾 Saved \(parametersVM.parameters.count) parameters to ShaderEntity")
    }
}

// MARK: - Styled Slider Row (like screenshot)
// OPTYMALIZACJA: Używa własnego @State zamiast @Binding - zmiana wartości NIE powoduje przebudowy rodzica!

struct StyledSliderRow: View {
    let parameter: ShaderParameter  // NIE @Binding - tylko odczyt początkowej wartości
    let color: Color
    var onValueChanged: ((String, Float) -> Void)? = nil
    
    // Lokalny stan - zmiana nie propaguje się do rodzica
    @State private var currentValue: Float = 0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color(white: 0.15))
                
                // Filled portion - ensure width is never negative or NaN
                let fillWidth = max(0, geometry.size.width * CGFloat(max(0, min(1, normalizedValue))))
                Rectangle()
                    .fill(color.opacity(0.7))
                    .frame(width: fillWidth.isFinite ? fillWidth : 0)
                
                // Label inside slider
                HStack {
                    Text(parameter.displayName.uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f", currentValue))
                        .font(.system(size: 10, weight: .regular, design: .monospaced))
                        .foregroundColor(.white.opacity(0.6))
                        .padding(.trailing, 10)
                }
            }
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let percentage = max(0, min(1, value.location.x / geometry.size.width))
                        let newValue = parameter.minValue + Float(percentage) * (parameter.maxValue - parameter.minValue)
                        currentValue = newValue
                        // Callback aktualizuje ViewModel bezpośrednio - BEZ przebudowy widoku!
                        onValueChanged?(parameter.name, newValue)
                    }
            )
        }
        .frame(height: 36)
        .onAppear {
            // Zainicjuj lokalny stan z parametru
            currentValue = parameter.currentValue
        }
    }
    
    private var normalizedValue: Float {
        (currentValue - parameter.minValue) / (parameter.maxValue - parameter.minValue)
    }
}

// MARK: - Button Grid Panel
// OPTYMALIZACJA: NIE używa @Binding - zmiana wartości NIE powoduje przebudowy rodzica!

struct ButtonGridPanel: View {
    let parameters: [ShaderParameter]  // NIE @Binding!
    var onToggle: ((UUID, Float) -> Void)? = nil  // Callback do aktualizacji ViewModel
    var onValueChanged: ((String, Float) -> Void)? = nil
    
    // Row colors: Red (top), Green (middle), Blue (bottom) - darker versions for active state
    private let rowColors: [Color] = [
        Color(red: 180/255, green: 14/255, blue: 55/255),   // Dark Red (Row 1 - top)
        Color(red: 0/255, green: 100/255, blue: 40/255),    // Dark Green (Row 2 - middle)
        Color(red: 0/255, green: 80/255, blue: 140/255)     // Dark Blue (Row 3 - bottom)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let toggleParams = parameters.filter { $0.type == .toggle }
            let buttonSpacing: CGFloat = 4
            let horizontalPadding: CGFloat = 8
            let availableWidth = geometry.size.width - (horizontalPadding * 2)
            let buttonWidth = (availableWidth - (buttonSpacing * 7)) / 8
            
            // Calculate row heights: rows 1 & 2 are equal, row 3 is 50% of their height
            let totalHeightRatio: CGFloat = 2.5 // 1 + 1 + 0.5
            let row12Height = (geometry.size.height - (buttonSpacing * 2) - 16) / totalHeightRatio
            let row3Height = row12Height * 0.5
            
            VStack(spacing: buttonSpacing) {
                // Row 1 (buttons 1-8) - Red
                HStack(spacing: buttonSpacing) {
                    ForEach(0..<8, id: \.self) { index in
                        if index < toggleParams.count {
                            ToggleGridButton(
                                param: toggleParams[index],
                                color: rowColors[0],
                                aspectRatio: nil,
                                onToggle: { newValue in
                                    onToggle?(toggleParams[index].id, newValue)
                                    onValueChanged?(toggleParams[index].name, newValue)
                                }
                            )
                            .frame(width: buttonWidth, height: row12Height)
                        } else {
                            GridButton(
                                label: "BTN \(index + 1)",
                                isActive: false,
                                color: rowColors[0],
                                aspectRatio: nil
                            ) {}
                            .frame(width: buttonWidth, height: row12Height)
                        }
                    }
                }
                
                // Row 2 (buttons 9-16) - Green
                HStack(spacing: buttonSpacing) {
                    ForEach(8..<16, id: \.self) { index in
                        if index < toggleParams.count {
                            ToggleGridButton(
                                param: toggleParams[index],
                                color: rowColors[1],
                                aspectRatio: nil,
                                onToggle: { newValue in
                                    onToggle?(toggleParams[index].id, newValue)
                                    onValueChanged?(toggleParams[index].name, newValue)
                                }
                            )
                            .frame(width: buttonWidth, height: row12Height)
                        } else {
                            GridButton(
                                label: "BTN \(index + 1)",
                                isActive: false,
                                color: rowColors[1],
                                aspectRatio: nil
                            ) {}
                            .frame(width: buttonWidth, height: row12Height)
                        }
                    }
                }
                
                // Row 3 (buttons 17-24) - Blue - 50% height
                HStack(spacing: buttonSpacing) {
                    ForEach(16..<24, id: \.self) { index in
                        if index < toggleParams.count {
                            ToggleGridButton(
                                param: toggleParams[index],
                                color: rowColors[2],
                                aspectRatio: nil,
                                onToggle: { newValue in
                                    onToggle?(toggleParams[index].id, newValue)
                                    onValueChanged?(toggleParams[index].name, newValue)
                                }
                            )
                            .frame(width: buttonWidth, height: row3Height)
                        } else {
                            GridButton(
                                label: "BTN \(index + 1)",
                                isActive: false,
                                color: rowColors[2],
                                aspectRatio: nil
                            ) {}
                            .frame(width: buttonWidth, height: row3Height)
                        }
                    }
                }
            }
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, 8)
        }
    }
}

// Toggle button with local state
struct ToggleGridButton: View {
    let param: ShaderParameter
    let color: Color
    var aspectRatio: CGFloat? = 1.0  // nil = fill available space
    let onToggle: (Float) -> Void
    
    // Inactive: very dark gray, barely visible above panel background
    private let inactiveColor = Color(white: 0.06)
    
    @State private var isActive: Bool = false
    
    var body: some View {
        Button {
            isActive.toggle()
            onToggle(isActive ? 1.0 : 0.0)
        } label: {
            Rectangle()
                .fill(inactiveColor)
                .overlay(
                    // Border only when active
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(isActive ? color : Color.clear, lineWidth: 2)
                )
                .overlay(
                    Text(param.displayName)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(isActive ? color : .white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(2)
                )
                .modifier(AspectRatioModifier(ratio: aspectRatio))
        }
        .onAppear {
            isActive = param.currentValue > 0.5
        }
    }
}

// Modifier do opcjonalnego aspect ratio
struct AspectRatioModifier: ViewModifier {
    let ratio: CGFloat?
    
    func body(content: Content) -> some View {
        if let ratio = ratio {
            content.aspectRatio(ratio, contentMode: .fit)
        } else {
            content
        }
    }
}

struct GridButton: View {
    let label: String
    let isActive: Bool
    let color: Color
    var aspectRatio: CGFloat? = 1.0  // nil = fill available space
    let action: () -> Void
    
    // Inactive: very dark gray, barely visible above panel background
    private let inactiveColor = Color(white: 0.06)
    
    var body: some View {
        Button(action: action) {
            Rectangle()
                .fill(inactiveColor)
                .overlay(
                    // Border only when active
                    RoundedRectangle(cornerRadius: 2)
                        .stroke(isActive ? color : Color.clear, lineWidth: 2)
                )
                .overlay(
                    Text(label)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(isActive ? color : .white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(2)
                )
                .modifier(AspectRatioModifier(ratio: aspectRatio))
        }
    }
}

// MARK: - XY Pad Panel
// OPTYMALIZACJA: NIE używa @Binding!

struct XYPadPanel: View {
    let parameters: [ShaderParameter]  // NIE @Binding!
    var onUpdate: ((UUID, Float) -> Void)? = nil  // Callback do aktualizacji ViewModel
    var onValueChanged: ((String, Float) -> Void)? = nil
    
    // Pad colors: #FE144D, #00963C, #0076C0
    private let padColors: [Color] = [
        Color(red: 254/255, green: 20/255, blue: 77/255),   // #FE144D - Red/Pink
        Color(red: 0/255, green: 150/255, blue: 60/255),    // #00963C - Green
        Color(red: 0/255, green: 118/255, blue: 192/255)    // #0076C0 - Blue
    ]
    
    @State private var padPositions: [CGPoint] = [
        CGPoint(x: 0.5, y: 0.5),
        CGPoint(x: 0.5, y: 0.5),
        CGPoint(x: 0.5, y: 0.5)
    ]
    
    var body: some View {
        GeometryReader { geometry in
            let spacing: CGFloat = 8
            let horizontalPadding: CGFloat = 12
            let availableWidth = geometry.size.width - (horizontalPadding * 2) - (spacing * 2)
            let padSize = min(availableWidth / 3, geometry.size.height - 20)
            
            HStack(spacing: spacing) {
                ForEach(0..<3, id: \.self) { padIndex in
                    SingleXYPad(
                        position: $padPositions[padIndex],
                        color: padColors[padIndex],
                        size: padSize,
                        padIndex: padIndex,
                        parameters: parameters,
                        onUpdate: onUpdate,
                        onValueChanged: onValueChanged
                    )
                }
            }
            .padding(.horizontal, horizontalPadding)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// Single XY Pad component
struct SingleXYPad: View {
    @Binding var position: CGPoint
    let color: Color
    let size: CGFloat
    let padIndex: Int
    let parameters: [ShaderParameter]
    var onUpdate: ((UUID, Float) -> Void)?
    var onValueChanged: ((String, Float) -> Void)?
    
    var body: some View {
        ZStack {
            // Background
            Rectangle()
                .stroke(color, lineWidth: 2)
                .background(Color.black)
            
            // Grid lines
            Path { path in
                // Vertical line
                path.move(to: CGPoint(x: size/2, y: 0))
                path.addLine(to: CGPoint(x: size/2, y: size))
                // Horizontal line
                path.move(to: CGPoint(x: 0, y: size/2))
                path.addLine(to: CGPoint(x: size, y: size/2))
            }
            .stroke(color.opacity(0.4), lineWidth: 1)
            
            // Cursor
            Circle()
                .fill(color)
                .frame(width: 16, height: 16)
                .position(
                    x: position.x * size,
                    y: position.y * size
                )
        }
        .frame(width: size, height: size)
        .gesture(
            DragGesture(minimumDistance: 0)
                .onChanged { value in
                    let x = max(0, min(1, value.location.x / size))
                    let y = max(0, min(1, value.location.y / size))
                    position = CGPoint(x: x, y: y)
                    updateParameters(x: x, y: y)
                }
        )
    }
    
    private func updateParameters(x: CGFloat, y: CGFloat) {
        // Each pad controls 2 consecutive slider parameters
        let sliderParams = parameters.filter { $0.type == .slider }
        let baseIndex = padIndex * 2
        
        // X axis parameter
        if baseIndex < sliderParams.count {
            let param = sliderParams[baseIndex]
            let newValue = param.minValue + Float(x) * (param.maxValue - param.minValue)
            onUpdate?(param.id, newValue)
            onValueChanged?(param.name, newValue)
        }
        
        // Y axis parameter
        if baseIndex + 1 < sliderParams.count {
            let param = sliderParams[baseIndex + 1]
            let newValue = param.minValue + Float(1 - y) * (param.maxValue - param.minValue)
            onUpdate?(param.id, newValue)
            onValueChanged?(param.name, newValue)
        }
    }
}

// MARK: - Knobs Panel
// OPTYMALIZACJA: NIE używa @Binding!

struct KnobsPanel: View {
    let parameters: [ShaderParameter]  // NIE @Binding!
    var onUpdate: ((UUID, Float) -> Void)? = nil  // Callback do aktualizacji ViewModel
    var onValueChanged: ((String, Float) -> Void)? = nil
    
    // Fader colors for 8 faders
    private let faderColors: [Color] = [
        Color(red: 254/255, green: 20/255, blue: 77/255),   // #FE144D - Red/Pink
        Color(red: 0/255, green: 150/255, blue: 60/255),    // #00963C - Green
        Color(red: 0/255, green: 118/255, blue: 192/255),   // #0076C0 - Blue
        .orange,
        .cyan,
        .purple,
        .yellow,
        .pink
    ]
    
    // Master opacity color - white/gray
    private let masterOpacityColor = Color.white
    
    // Find masterOpacity parameter from shader
    private var masterOpacityParam: ShaderParameter? {
        parameters.first { $0.name == "masterOpacity" }
    }
    
    // Filter out masterOpacity from slider params for knobs/faders
    private var nonMasterSliderParams: [ShaderParameter] {
        parameters.filter { $0.type == .slider && $0.name != "masterOpacity" }
    }
    
    var body: some View {
        GeometryReader { geometry in
            let sliderParams = nonMasterSliderParams  // Use filtered params (without masterOpacity)
            let faderWidth: CGFloat = 36
            let faderSpacing: CGFloat = 4
            let masterFaderWidth: CGFloat = 44
            // 8 faders + master + spacing + padding
            let fadersWidth = (faderWidth * 8) + (faderSpacing * 7) + masterFaderWidth + faderSpacing + 20
            let knobsWidth = geometry.size.width - fadersWidth
            
            HStack(spacing: 0) {
                // Knobs section (12 knobs in 4 columns x 3 rows)
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 10) {
                        // Show first 12 parameters as knobs (excluding masterOpacity)
                        ForEach(0..<12, id: \.self) { index in
                            if index < sliderParams.count {
                                OptimizedKnobView(
                                    param: sliderParams[index],
                                    color: knobColor(for: index),
                                    onUpdate: { newValue in
                                        onUpdate?(sliderParams[index].id, newValue)
                                        onValueChanged?(sliderParams[index].name, newValue)
                                    }
                                )
                            } else {
                                PlaceholderKnobView(
                                    label: "K\(index + 1)",
                                    color: knobColor(for: index)
                                )
                            }
                        }
                    }
                    .padding(.horizontal, 6)
                    .padding(.top, 32)  // Large top margin for knobs
                    .padding(.bottom, 6)
                }
                .frame(width: knobsWidth)
                
                // Vertical divider
                Rectangle()
                    .fill(Color(white: 0.2))
                    .frame(width: 1)
                
                // Faders section (8 vertical faders + 1 Master Opacity)
                HStack(spacing: faderSpacing) {
                    // 8 parameter faders (params 13-20, excluding masterOpacity)
                    ForEach(0..<8, id: \.self) { faderIndex in
                        let paramIndex = 12 + faderIndex  // Faders use params 13-20 from filtered list
                        if paramIndex < sliderParams.count {
                            VerticalFader(
                                param: sliderParams[paramIndex],
                                color: faderColors[faderIndex],
                                width: faderWidth,
                                onUpdate: { newValue in
                                    onUpdate?(sliderParams[paramIndex].id, newValue)
                                    onValueChanged?(sliderParams[paramIndex].name, newValue)
                                }
                            )
                        } else {
                            PlaceholderFader(
                                label: "F\(faderIndex + 1)",
                                color: faderColors[faderIndex],
                                width: faderWidth
                            )
                        }
                    }
                    
                    // Separator line before Master
                    Rectangle()
                        .fill(Color(white: 0.3))
                        .frame(width: 1)
                    
                    // Master Opacity fader - connected to actual masterOpacity parameter
                    if let masterParam = masterOpacityParam {
                        MasterOpacityFaderConnected(
                            param: masterParam,
                            color: masterOpacityColor,
                            width: masterFaderWidth,
                            onUpdate: { newValue in
                                onUpdate?(masterParam.id, newValue)
                                onValueChanged?(masterParam.name, newValue)
                            }
                        )
                    } else {
                        // Fallback placeholder if no masterOpacity param
                        PlaceholderFader(
                            label: "MASTER",
                            color: masterOpacityColor,
                            width: masterFaderWidth
                        )
                    }
                }
                .padding(.horizontal, 6)
                .padding(.vertical, 6)
            }
        }
    }
    
    private func knobColor(for index: Int) -> Color {
        let colors: [Color] = [.orange, .cyan, .purple, .green, .yellow, .pink]
        return colors[index % colors.count]
    }
}

// Master Opacity Fader - special fader with "MASTER" label
struct MasterOpacityFader: View {
    @Binding var value: Float
    let color: Color
    let width: CGFloat
    let onUpdate: (Float) -> Void
    
    // Dark gray color for Master fader
    private let masterColor = Color(white: 0.5)
    
    var body: some View {
        VStack(spacing: 2) {
            // Master label - same style as other faders
            Text("MASTER")
                .font(.system(size: 6, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(width: width)
            
            // Fader track - no handle, just fill
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Track background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(white: 0.15))
                    
                    // Value fill - dark gray (no handle)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(masterColor.opacity(0.6))
                        .frame(height: geometry.size.height * CGFloat(value))
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let newValue = 1.0 - Float(gesture.location.y / geometry.size.height)
                            value = max(0, min(1, newValue))
                            onUpdate(value)
                        }
                )
            }
            .frame(width: width - 4)
        }
        .frame(width: width)
    }
}

// Master Opacity Fader connected to shader parameter
struct MasterOpacityFaderConnected: View {
    let param: ShaderParameter
    let color: Color
    let width: CGFloat
    let onUpdate: (Float) -> Void
    
    // Dark gray color for Master fader
    private let masterColor = Color(white: 0.5)
    
    // Normalized value (0-1) from parameter
    private var normalizedValue: Float {
        (param.currentValue - param.minValue) / (param.maxValue - param.minValue)
    }
    
    var body: some View {
        VStack(spacing: 2) {
            // Master label - same style as other faders
            Text("MASTER")
                .font(.system(size: 6, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(width: width)
            
            // Fader track - no handle, just fill
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Track background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(white: 0.15))
                    
                    // Value fill - dark gray (no handle)
                    RoundedRectangle(cornerRadius: 4)
                        .fill(masterColor.opacity(0.6))
                        .frame(height: geometry.size.height * CGFloat(normalizedValue))
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { gesture in
                            let y = min(max(gesture.location.y, 0), geometry.size.height)
                            let normalized = 1.0 - Float(y / geometry.size.height)
                            let newValue = param.minValue + normalized * (param.maxValue - param.minValue)
                            onUpdate(newValue)
                        }
                )
            }
            .frame(width: width - 4)
        }
        .frame(width: width)
    }
}

// Vertical Fader component
struct VerticalFader: View {
    let param: ShaderParameter
    let color: Color
    var width: CGFloat = 44
    let onUpdate: (Float) -> Void
    
    @State private var normalizedValue: Float = 0.5
    
    var body: some View {
        VStack(spacing: 2) {
            // Fader label
            Text(param.displayName)
                .font(.system(size: 6, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
                .frame(width: width)
            
            // Fader track
            GeometryReader { geometry in
                ZStack(alignment: .bottom) {
                    // Track background
                    RoundedRectangle(cornerRadius: 4)
                        .fill(Color(white: 0.15))
                    
                    // Value fill
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.6))
                        .frame(height: geometry.size.height * CGFloat(normalizedValue))
                    
                    // Handle
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color)
                        .frame(width: width - 4, height: 10)
                        .offset(y: -geometry.size.height * CGFloat(normalizedValue) + 5)
                }
                .gesture(
                    DragGesture(minimumDistance: 0)
                        .onChanged { value in
                            let newValue = 1.0 - Float(value.location.y / geometry.size.height)
                            normalizedValue = max(0, min(1, newValue))
                            
                            let actualValue = param.minValue + normalizedValue * (param.maxValue - param.minValue)
                            onUpdate(actualValue)
                        }
                )
            }
            .frame(width: width - 4)
        }
        .frame(width: width)
        .onAppear {
            normalizedValue = (param.currentValue - param.minValue) / (param.maxValue - param.minValue)
        }
    }
}

// Placeholder Fader
struct PlaceholderFader: View {
    let label: String
    let color: Color
    var width: CGFloat = 44
    
    var body: some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 6, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
            
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(white: 0.15))
                .frame(width: width - 4)
                .overlay(
                    RoundedRectangle(cornerRadius: 3)
                        .fill(color.opacity(0.3))
                        .frame(width: width - 8, height: 10)
                        .offset(y: 30)
                )
        }
        .frame(width: width)
    }
}

// Placeholder knob (no interaction)
struct PlaceholderKnobView: View {
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .stroke(Color(white: 0.3), lineWidth: 3)
                Circle()
                    .fill(Color(white: 0.15))
                    .padding(6)
            }
            .frame(width: 50, height: 50)
            
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}

// Optimized knob with local state
struct OptimizedKnobView: View {
    let param: ShaderParameter
    let color: Color
    let onUpdate: (Float) -> Void
    
    @State private var normalizedValue: Float = 0.5
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color(white: 0.3), lineWidth: 3)
                
                // Value arc
                Circle()
                    .trim(from: 0, to: CGFloat(normalizedValue) * 0.75)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(135))
                
                // Inner circle
                Circle()
                    .fill(Color(white: 0.15))
                    .padding(6)
                
                // Indicator line
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: 15)
                    .offset(y: -12)
                    .rotationEffect(.degrees(Double(normalizedValue) * 270 - 135))
            }
            .frame(width: 50, height: 50)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let vector = CGVector(dx: gesture.location.x - 25, dy: gesture.location.y - 25)
                        let angle = atan2(vector.dy, vector.dx)
                        let newNormalized = max(0, min(1, Float((angle + .pi) / (2 * .pi))))
                        normalizedValue = newNormalized
                        
                        // Convert to actual value and update
                        let actualValue = param.minValue + newNormalized * (param.maxValue - param.minValue)
                        onUpdate(actualValue)
                    }
            )
            
            Text(param.displayName)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
        .onAppear {
            // Initialize from parameter
            normalizedValue = (param.currentValue - param.minValue) / (param.maxValue - param.minValue)
        }
    }
}

struct KnobView: View {
    let label: String
    @Binding var value: Float
    let color: Color
    
    @State private var lastAngle: Double = 0
    
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                // Outer ring
                Circle()
                    .stroke(Color(white: 0.3), lineWidth: 3)
                
                // Value arc
                Circle()
                    .trim(from: 0, to: CGFloat(value) * 0.75)
                    .stroke(color, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                    .rotationEffect(.degrees(135))
                
                // Inner circle
                Circle()
                    .fill(Color(white: 0.15))
                    .padding(6)
                
                // Indicator line
                Rectangle()
                    .fill(color)
                    .frame(width: 2, height: 15)
                    .offset(y: -12)
                    .rotationEffect(.degrees(Double(value) * 270 - 135))
            }
            .frame(width: 50, height: 50)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        let vector = CGVector(dx: gesture.location.x - 25, dy: gesture.location.y - 25)
                        let angle = atan2(vector.dy, vector.dx)
                        let normalizedAngle = (angle + .pi) / (2 * .pi)
                        value = max(0, min(1, Float(normalizedAngle)))
                    }
            )
            
            Text(label)
                .font(.system(size: 8, weight: .medium))
                .foregroundColor(.gray)
                .lineLimit(1)
        }
    }
}

// MARK: - Automation Preset Panel (P1-P16)
// Panel presetów automatyzacji parametrów - wzorowany na LM_MApp

struct AutomationPresetPanel: View {
    var automationManager: ParameterAutomationManager
    @Bindable var shader: ShaderEntity
    var hasRecording: Bool
    
    // State do śledzenia presetów (odświeżane przy każdym dostępie)
    @State private var presetStates: [Bool] = Array(repeating: false, count: 16)
    
    var body: some View {
        VStack(spacing: 4) {
            // Header
            HStack {
                Text("PRESETS")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Info - pokaż liczbę zapisanych presetów
                let savedCount = presetStates.filter { $0 }.count
                if savedCount > 0 {
                    Text("\(savedCount)/16")
                        .font(.system(size: 9))
                        .foregroundColor(.gray.opacity(0.7))
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 6)
            
            // Preset Grid (2 rzędy po 8 przycisków)
            VStack(spacing: 4) {
                // Górny rząd (P1-P8)
                HStack(spacing: 4) {
                    ForEach(0..<8, id: \.self) { index in
                        AutomationPresetCell(
                            index: index,
                            hasPreset: presetStates[index],
                            hasRecording: hasRecording,
                            onTap: { loadPreset(index) },
                            onLongPressSave: { savePreset(index) },
                            onLongPressDelete: { deletePreset(index) }
                        )
                    }
                }
                
                // Dolny rząd (P9-P16)
                HStack(spacing: 4) {
                    ForEach(8..<16, id: \.self) { index in
                        AutomationPresetCell(
                            index: index,
                            hasPreset: presetStates[index],
                            hasRecording: hasRecording,
                            onTap: { loadPreset(index) },
                            onLongPressSave: { savePreset(index) },
                            onLongPressDelete: { deletePreset(index) }
                        )
                    }
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 8)
        }
        .background(Color(white: 0.08))
        .onAppear {
            // Załaduj presety z shadera przy starcie
            automationManager.importPresetsFromData(shader.automationPresetsData)
            updatePresetStates()
        }
    }
    
    private func updatePresetStates() {
        for i in 0..<16 {
            presetStates[i] = automationManager.hasPreset(at: i)
        }
    }
    
    private func loadPreset(_ index: Int) {
        automationManager.loadPresetFromSlot(index: index)
        print("📂 Loaded preset P\(index + 1)")
    }
    
    private func savePreset(_ index: Int) {
        guard hasRecording else {
            print("⚠️ No automation to save - record first")
            return
        }
        
        automationManager.savePresetToSlot(index: index)
        
        // Zapisz do shadera (SwiftData)
        shader.automationPresetsData = automationManager.exportPresetsToData()
        
        // Odśwież UI
        updatePresetStates()
        
        print("💾 Saved preset P\(index + 1)")
    }
    
    private func deletePreset(_ index: Int) {
        automationManager.deletePresetFromSlot(index: index)
        
        // Zapisz do shadera (SwiftData)
        shader.automationPresetsData = automationManager.exportPresetsToData()
        
        // Odśwież UI
        updatePresetStates()
        
        print("🗑 Deleted preset P\(index + 1)")
    }
}

// MARK: - Automation Preset Cell (pojedynczy przycisk P1-P16)

struct AutomationPresetCell: View {
    let index: Int
    let hasPreset: Bool
    let hasRecording: Bool
    let onTap: () -> Void
    let onLongPressSave: () -> Void
    let onLongPressDelete: () -> Void
    
    // Kolor akcentu (taki jak w LM_MApp)
    private let accentColor = Color(red: 0xFE/255, green: 0x14/255, blue: 0x4D/255)
    
    var body: some View {
        ZStack {
            // Tło
            Rectangle()
                .fill(hasPreset ? accentColor : Color.gray.opacity(0.2))
                .overlay(
                    Rectangle()
                        .stroke(Color.white.opacity(0.3), lineWidth: 1)
                )
            
            // Label
            if hasPreset {
                VStack(spacing: 1) {
                    Text("P\(index + 1)")
                        .font(.system(size: 9, weight: .bold))
                        .foregroundColor(.white)
                }
            } else {
                Text("P\(index + 1)")
                    .font(.system(size: 9))
                    .foregroundColor(.white.opacity(0.4))
            }
        }
        .frame(height: 26)
        .contentShape(Rectangle())
        .onTapGesture {
            if hasPreset {
                onTap()
            }
        }
        .onLongPressGesture(minimumDuration: 0.5) {
            if hasPreset {
                // Jeśli preset istnieje - usuń go
                onLongPressDelete()
            } else if hasRecording {
                // Jeśli nie ma presetu ale jest nagranie - zapisz
                onLongPressSave()
            }
        }
    }
}

// MARK: - Array Safe Range Extension

extension Array {
    subscript(safe range: Range<Int>) -> ArraySlice<Element> {
        let safeStart = Swift.max(0, range.lowerBound)
        let safeEnd = Swift.min(count, range.upperBound)
        guard safeStart < safeEnd else { return [] }
        return self[safeStart..<safeEnd]
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ShaderParametersView(
            shader: ShaderEntity(
                name: "Test Shader",
                fragmentCode: """
                // @param speed "Speed" range(0.0, 5.0) default(1.0)
                // @param scale "Scale" range(0.1, 10.0) default(1.0)
                // @toggle invert "Invert" default(false)
                float3 col = float3(uv.x, uv.y, 0.5);
                return float4(col, 1.0);
                """,
                category: .custom,
                author: "Test"
            ),
            parametersVM: ShaderParametersViewModel(),
            automationManager: ParameterAutomationManager()
        )
    }
}
