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
    @StateObject private var parametersVM = ShaderParametersViewModel()
    @StateObject private var aiService = AIShaderService.shared
    @StateObject private var automationManager = ParameterAutomationManager()
    
    // AI Generation
    @State private var aiPrompt: String = ""
    @State private var selectedProvider: AIProvider = .groq
    @State private var showAPIKeySheet = false
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 0
    
    // Control panel selection
    @State private var selectedControlPanel: ControlPanelType = .grid
    
    enum ControlPanelType: String, CaseIterable {
        case grid = "Grid"
        case pad = "Pad"
        case knobs = "Knobs"
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isLandscape = geometry.size.width > geometry.size.height
            
            if isLandscape {
                // Landscape layout (4 quadrants)
                HStack(spacing: 0) {
                    // Left side - Preview (70%)
                    VStack(spacing: 0) {
                        // Top-left: Preview
                        shaderPreviewPanel
                            .frame(height: geometry.size.height * 0.55)
                        
                        // Bottom-left: Control panels
                        controlPanelsSection
                            .frame(height: geometry.size.height * 0.45)
                    }
                    .frame(width: geometry.size.width * 0.7)
                    
                    // Right side - Controls (30%)
                    VStack(spacing: 0) {
                        // Top-right: Sliders
                        slidersPanel
                            .frame(height: geometry.size.height * 0.6)
                        
                        // Bottom-right: AI Generator
                        aiGeneratorPanel
                            .frame(height: geometry.size.height * 0.4)
                    }
                    .frame(width: geometry.size.width * 0.3)
                }
            } else {
                // Portrait layout (scrollable)
                ScrollView {
                    VStack(spacing: 12) {
                        shaderPreviewPanel
                            .frame(height: 200)
                        
                        slidersPanel
                            .frame(minHeight: 200)
                        
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
            parametersVM.updateFromCode(shader.fragmentCode)
            // Initialize AI with current shader code as context
            // So AI can modify this shader instead of creating from scratch
            aiService.initializeWithShaderContext(shader.fragmentCode)
            
            // Setup automation playback callback
            automationManager.onParameterUpdate = { [weak parametersVM] name, value in
                guard let vm = parametersVM else { return }
                if let index = vm.parameters.firstIndex(where: { $0.name == name }) {
                    vm.parameters[index].currentValue = value
                }
            }
        }
        .onChange(of: shader.fragmentCode) { _, newCode in
            parametersVM.updateFromCode(newCode)
        }
        .sheet(isPresented: $showAPIKeySheet) {
            APIKeySettingsSheet(provider: selectedProvider)
        }
        .preferredColorScheme(.dark)
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
            
            // Preview
            MetalShaderView(
                shaderCode: shader.fragmentCode,
                isPlaying: $isPlaying,
                currentTime: $currentTime,
                parameters: parametersVM.parameters
            )
        }
        .background(Color.black)
    }
    
    // MARK: - Sliders Panel
    
    private var slidersPanel: some View {
        VStack(spacing: 0) {
            // Header with Record and Close buttons
            HStack {
                Text("GLSL")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Automation status/playback indicator
                if automationManager.hasRecording && !automationManager.isRecording && !automationManager.isCountingDown {
                    HStack(spacing: 4) {
                        Text(String(format: "%.1fs", automationManager.isPlaying ? automationManager.playbackTime : automationManager.recordingDuration))
                            .font(.caption2.monospacedDigit())
                        Text("(\(automationManager.keyframeCount))")
                            .font(.caption2)
                    }
                    .foregroundColor(.gray)
                }
                
                // Play/Pause button (only when recording exists)
                if automationManager.hasRecording && !automationManager.isRecording && !automationManager.isCountingDown {
                    playPauseButton
                }
                
                // Record button (always visible)
                recordButton
                
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
            
            // Sliders
            ScrollView {
                VStack(spacing: 2) {
                    let sliderParams = parametersVM.parameters.filter { $0.type == .slider }
                    
                    if sliderParams.isEmpty {
                        Text("No slider parameters")
                            .font(.caption)
                            .foregroundColor(.gray)
                            .padding()
                    } else {
                        ForEach(Array(sliderParams.enumerated()), id: \.element.id) { index, _ in
                            if let paramIndex = parametersVM.parameters.firstIndex(where: { $0.id == sliderParams[index].id }) {
                                StyledSliderRow(
                                    parameter: $parametersVM.parameters[paramIndex],
                                    color: sliderColor(for: index),
                                    onValueChanged: { name, value in
                                        automationManager.recordParameterChange(name: name, value: value)
                                    }
                                )
                            }
                        }
                    }
                }
            }
        }
        .background(Color(white: 0.1))
    }
    
    private func sliderColor(for index: Int) -> Color {
        let colors: [Color] = [
            Color(red: 0.6, green: 0.6, blue: 0.8),   // Light purple
            Color(red: 0.5, green: 0.7, blue: 0.6),   // Teal
            Color(red: 0.4, green: 0.8, blue: 0.8),   // Cyan
            Color(red: 0.6, green: 0.8, blue: 0.4),   // Lime
            Color(red: 0.8, green: 0.8, blue: 0.3),   // Yellow
            Color(red: 0.8, green: 0.5, blue: 0.3),   // Orange
        ]
        return colors[index % colors.count]
    }
    
    // MARK: - Play/Pause Button
    
    private var playPauseButton: some View {
        Button {
            automationManager.togglePlayback()
        } label: {
            Image(systemName: automationManager.isPlaying ? "pause.fill" : "play.fill")
                .font(.caption)
                .foregroundColor(.green)
                .padding(6)
                .background(Color.green.opacity(0.2))
                .clipShape(Circle())
        }
    }
    
    // MARK: - Record Button
    
    private var recordButton: some View {
        Button {
            handleRecordButtonTap()
        } label: {
            HStack(spacing: 4) {
                Circle()
                    .fill(recordButtonColor)
                    .frame(width: 8, height: 8)
                
                Text(recordButtonLabel)
                    .font(.caption2.bold())
            }
            .foregroundColor(recordButtonColor)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(recordButtonColor.opacity(0.2))
            .cornerRadius(10)
        }
    }
    
    private var recordButtonColor: Color {
        switch automationManager.state {
        case .recording:
            return .red
        case .countdown:
            return .orange
        case .playing, .idle:
            return .red
        }
    }
    
    private var recordButtonLabel: String {
        switch automationManager.state {
        case .recording:
            return "STOP"
        case .countdown(let seconds):
            return "\(seconds)"
        case .playing, .idle:
            return "REC"
        }
    }
    
    private func handleRecordButtonTap() {
        switch automationManager.state {
        case .idle, .playing:
            // Stop playback if playing, then start recording
            if automationManager.isPlaying {
                automationManager.stopPlayback()
            }
            automationManager.startRecordingWithCountdown()
        case .countdown:
            automationManager.cancelRecording()
        case .recording:
            automationManager.stopRecording()
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
                    ButtonGridPanel(parameters: $parametersVM.parameters)
                case .pad:
                    XYPadPanel(parameters: $parametersVM.parameters)
                case .knobs:
                    KnobsPanel(parameters: $parametersVM.parameters)
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
                Text("AI SHADER GENERATOR")
                    .font(.caption.bold())
                    .foregroundColor(.gray)
                
                if aiService.hasConversationContext {
                    Text("• Kontekst aktywny")
                        .font(.caption)
                        .foregroundColor(.green)
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.top, 8)
            
            // Provider + Key
            HStack {
                Text("Provider:")
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Picker("", selection: $selectedProvider) {
                    ForEach(AIProvider.allCases) { provider in
                        Text(provider.rawValue).tag(provider)
                    }
                }
                .pickerStyle(.menu)
                .tint(.cyan)
                
                Spacer()
                
                if aiService.hasConversationContext {
                    Button {
                        aiService.clearConversation()
                    } label: {
                        HStack(spacing: 2) {
                            Image(systemName: "bubble.left.and.bubble.right.fill")
                            Text("\(aiService.conversationHistory.count / 2)")
                            Image(systemName: "xmark.circle.fill")
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                }
                
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
                            Image(systemName: aiService.hasConversationContext ? "arrow.triangle.2.circlepath" : "sparkles")
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
                
                if aiService.hasConversationContext {
                    Button {
                        aiService.clearConversation()
                    } label: {
                        Image(systemName: "plus.circle")
                            .padding(10)
                            .background(Color(white: 0.2))
                    }
                }
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
        "Modyfikuj: 'wolniej', 'zmień kolor na niebieski', 'dodaj slider'..."
    }
    
    private var generateButtonText: String {
        if aiService.isGenerating { return "Generuję..." }
        return "Modyfikuj"
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
        // Save parameter values back to shader if needed
        try? modelContext.save()
    }
}

// MARK: - Styled Slider Row (like screenshot)

struct StyledSliderRow: View {
    @Binding var parameter: ShaderParameter
    let color: Color
    var onValueChanged: ((String, Float) -> Void)? = nil
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Background track
                Rectangle()
                    .fill(Color(white: 0.15))
                
                // Filled portion
                Rectangle()
                    .fill(color.opacity(0.7))
                    .frame(width: geometry.size.width * CGFloat(normalizedValue))
                
                // Label inside slider
                HStack {
                    Text(parameter.displayName.uppercased())
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.leading, 10)
                    
                    Spacer()
                    
                    Text(String(format: "%.2f", parameter.currentValue))
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
                        parameter.currentValue = newValue
                        onValueChanged?(parameter.name, newValue)
                    }
            )
        }
        .frame(height: 36)
    }
    
    private var normalizedValue: Float {
        (parameter.currentValue - parameter.minValue) / (parameter.maxValue - parameter.minValue)
    }
}

// MARK: - Button Grid Panel

struct ButtonGridPanel: View {
    @Binding var parameters: [ShaderParameter]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 4) {
                let toggleParams = parameters.filter { $0.type == .toggle }
                
                if toggleParams.isEmpty {
                    // Show placeholder buttons
                    ForEach(0..<16, id: \.self) { index in
                        GridButton(
                            label: "BTN \(index + 1)",
                            isActive: false,
                            color: gridColor(for: index)
                        ) {}
                    }
                } else {
                    ForEach(Array(toggleParams.enumerated()), id: \.element.id) { index, param in
                        if let paramIndex = parameters.firstIndex(where: { $0.id == param.id }) {
                            GridButton(
                                label: param.displayName,
                                isActive: parameters[paramIndex].currentValue > 0.5,
                                color: gridColor(for: index)
                            ) {
                                parameters[paramIndex].currentValue = parameters[paramIndex].currentValue > 0.5 ? 0.0 : 1.0
                            }
                        }
                    }
                }
            }
            .padding(8)
        }
    }
    
    private func gridColor(for index: Int) -> Color {
        let row = index / 4
        let colors: [Color] = [.green, .yellow, .orange, .red]
        return colors[row % colors.count]
    }
}

struct GridButton: View {
    let label: String
    let isActive: Bool
    let color: Color
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Rectangle()
                .fill(isActive ? color : color.opacity(0.3))
                .overlay(
                    Text(label)
                        .font(.system(size: 8, weight: .medium))
                        .foregroundColor(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(2)
                )
                .aspectRatio(1, contentMode: .fit)
        }
    }
}

// MARK: - XY Pad Panel

struct XYPadPanel: View {
    @Binding var parameters: [ShaderParameter]
    
    @State private var padPosition: CGPoint = CGPoint(x: 0.5, y: 0.5)
    
    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height) - 20
            
            ZStack {
                // Background
                Rectangle()
                    .stroke(Color.yellow, lineWidth: 2)
                    .background(Color.black)
                    .frame(width: size, height: size)
                
                // Grid lines
                Path { path in
                    // Vertical line
                    path.move(to: CGPoint(x: size/2, y: 0))
                    path.addLine(to: CGPoint(x: size/2, y: size))
                    // Horizontal line
                    path.move(to: CGPoint(x: 0, y: size/2))
                    path.addLine(to: CGPoint(x: size, y: size/2))
                }
                .stroke(Color.yellow.opacity(0.5), lineWidth: 1)
                .frame(width: size, height: size)
                
                // Cursor
                Circle()
                    .fill(Color.yellow)
                    .frame(width: 20, height: 20)
                    .position(
                        x: padPosition.x * size,
                        y: padPosition.y * size
                    )
            }
            .frame(width: size, height: size)
            .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        let x = max(0, min(1, value.location.x / size))
                        let y = max(0, min(1, value.location.y / size))
                        padPosition = CGPoint(x: x, y: y)
                        updateXYParameters()
                    }
            )
        }
    }
    
    private func updateXYParameters() {
        // Map pad X to first slider parameter, Y to second
        let sliderParams = parameters.filter { $0.type == .slider }
        if sliderParams.count >= 1,
           let index = parameters.firstIndex(where: { $0.id == sliderParams[0].id }) {
            parameters[index].currentValue = parameters[index].minValue + Float(padPosition.x) * (parameters[index].maxValue - parameters[index].minValue)
        }
        if sliderParams.count >= 2,
           let index = parameters.firstIndex(where: { $0.id == sliderParams[1].id }) {
            parameters[index].currentValue = parameters[index].minValue + Float(1 - padPosition.y) * (parameters[index].maxValue - parameters[index].minValue)
        }
    }
}

// MARK: - Knobs Panel

struct KnobsPanel: View {
    @Binding var parameters: [ShaderParameter]
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                let sliderParams = parameters.filter { $0.type == .slider }
                
                if sliderParams.isEmpty {
                    ForEach(0..<8, id: \.self) { index in
                        KnobView(
                            label: "KNOB \(index + 1)",
                            value: .constant(0.5),
                            color: knobColor(for: index)
                        )
                    }
                } else {
                    ForEach(Array(sliderParams.enumerated()), id: \.element.id) { index, param in
                        if let paramIndex = parameters.firstIndex(where: { $0.id == param.id }) {
                            KnobView(
                                label: param.displayName,
                                value: Binding(
                                    get: { 
                                        (parameters[paramIndex].currentValue - parameters[paramIndex].minValue) / 
                                        (parameters[paramIndex].maxValue - parameters[paramIndex].minValue)
                                    },
                                    set: { newValue in
                                        parameters[paramIndex].currentValue = parameters[paramIndex].minValue + 
                                            newValue * (parameters[paramIndex].maxValue - parameters[paramIndex].minValue)
                                    }
                                ),
                                color: knobColor(for: index)
                            )
                        }
                    }
                }
            }
            .padding()
        }
    }
    
    private func knobColor(for index: Int) -> Color {
        let colors: [Color] = [.orange, .cyan, .purple, .green, .yellow, .pink]
        return colors[index % colors.count]
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
            )
        )
    }
}
