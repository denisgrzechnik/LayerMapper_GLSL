//
//  ShaderPreviewView.swift
//  LM_GLSL
//
//  Metal-based shader preview with real-time rendering
//

import SwiftUI
import MetalKit

struct ShaderPreviewView: View {
    let shader: ShaderEntity?
    @Binding var isFullscreen: Bool
    @Binding var showingParametersView: Bool
    @Binding var viewMode: ViewMode
    var syncService: ShaderSyncService?
    @ObservedObject var parametersVM: ShaderParametersViewModel
    // Don't observe automationManager to avoid 60fps view rebuilds - just hold reference
    var automationManager: ParameterAutomationManager
    
    // HDMI output aspect ratio (16:9)
    private let hdmiAspectRatio: CGFloat = 16.0 / 9.0
    
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 0
    @State private var showInfo: Bool = false
    @State private var showOverlay: Bool = false
    @State private var shaderStartTime: Date = Date()
    @State private var lastSyncTime: Date = Date.distantPast
    
    var body: some View {
        GeometryReader { geometry in
            // Calculate size to maintain 16:9 aspect ratio, full width
            let containerSize = geometry.size
            let previewSize = calculatePreviewSize(containerSize: containerSize)
            
            ZStack {
                // Background
                Color.black
                
                // Normal preview with aspect ratio
                ZStack {
                    // Metal rendering view
                    if let shader = shader {
                        MetalShaderView(
                            shaderCode: shader.fragmentCode,
                            isPlaying: $isPlaying,
                            currentTime: $currentTime,
                            parametersVM: parametersVM
                        )
                        .frame(width: previewSize.width, height: previewSize.height)
                    } else {
                        // Placeholder when no shader selected
                        VStack(spacing: 20) {
                            Image(systemName: "sparkles.rectangle.stack")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            
                            Text("Select a shader to preview")
                                .font(.title2)
                                .foregroundColor(.gray)
                        }
                        .frame(width: previewSize.width, height: previewSize.height)
                        .background(Color(white: 0.1))
                    }
                    
                    // Overlay controls - only visible when showOverlay is true
                    if showOverlay, shader != nil {
                        overlayControls
                            .frame(width: previewSize.width, height: previewSize.height)
                            .transition(.opacity)
                    }
                    
                    // Info panel overlay
                    if showInfo, let shader = shader {
                        ShaderInfoPanel(shader: shader, isPresented: $showInfo)
                    }
                }
                .frame(width: previewSize.width, height: previewSize.height)
                .contentShape(Rectangle())
                .gesture(
                    DragGesture(minimumDistance: 50, coordinateSpace: .local)
                        .onEnded { value in
                            // Swipe up to open parameters view
                            if value.translation.height < -100 && abs(value.translation.width) < abs(value.translation.height) {
                                if shader != nil {
                                    showingParametersView = true
                                }
                            }
                            // Swipe left to switch to Grid view
                            if value.translation.width < -100 && abs(value.translation.height) < abs(value.translation.width) {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    viewMode = .grid
                                }
                            }
                        }
                )
                .onTapGesture(count: 2) {
                    // Double tap to toggle fullscreen with zoom animation
                    withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                        isFullscreen = true
                    }
                }
                .onTapGesture(count: 1) {
                    // Single tap to toggle overlay
                    withAnimation(.easeInOut(duration: 0.25)) {
                        showOverlay.toggle()
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .onChange(of: shader?.id) { _, _ in
            loadShaderData()
            shaderStartTime = Date()
        }
        // OPTYMALIZACJA: Usunięto onChange(of: currentTime) który wywoływał się 60x/sek
        // Synchronizacja parametrów jest teraz obsługiwana przez timer w ContentView @ 30fps
        .onAppear {
            loadShaderData()
            shaderStartTime = Date()
        }
    }
    
    // MARK: - Send Parameters to Sync (wywoływane tylko gdy potrzebne)
    
    private func sendParametersToSync() {
        // Debug: always log first to confirm function is called
        let debugNow = Date()
        if Int(debugNow.timeIntervalSince1970 * 10) % 50 == 0 {
            print("🔍 sendParametersToSync called - syncService: \(syncService != nil ? "EXISTS" : "NIL"), isAdvertising: \(syncService?.isAdvertising ?? false)")
        }
        
        guard let syncService = syncService,
              syncService.isAdvertising else { return }
        
        // Throttle to 30fps max (every ~33ms)
        let now = Date()
        guard now.timeIntervalSince(lastSyncTime) >= 0.033 else { return }
        
        // Update lastSyncTime using dispatch to avoid state mutation in view body
        DispatchQueue.main.async {
            self.lastSyncTime = now
        }
        
        // Build parameter values dictionary
        var paramValues: [String: Float] = [:]
        for param in parametersVM.parameters {
            paramValues[param.name] = param.currentValue
        }
        
        // Calculate time since shader started
        let elapsed = now.timeIntervalSince(shaderStartTime)
        
        // Debug: log every 2 seconds
        if Int(elapsed * 10) % 20 == 0 {
            print("📤 GLSL sending: params=\(paramValues), time=\(String(format: "%.2f", elapsed))")
        }
        
        // Send to sync service
        syncService.updateParameters(paramValues, time: elapsed)
    }
    
    // MARK: - Load Shader Data
    
    private func loadShaderData() {
        guard let shader = shader else {
            // Clear parameters when no shader selected
            parametersVM.parameters = []
            return
        }
        
        // Parse parameters from shader code
        parametersVM.updateFromCode(shader.fragmentCode)
        
        // Apply saved values from ShaderParameterEntity (SwiftData)
        if let savedParams = shader.parameters {
            for savedParam in savedParams {
                if let index = parametersVM.parameters.firstIndex(where: { $0.name == savedParam.name }) {
                    parametersVM.parameters[index].currentValue = savedParam.floatValue
                }
            }
        }
        
        // Note: Automation is now loaded and managed by ContentView's shared automationManager
        // Ensure callback is set for this view as well
        automationManager.onParameterUpdate = { [weak parametersVM] name, value in
            guard let vm = parametersVM else { return }
            if let index = vm.parameters.firstIndex(where: { $0.name == name }) {
                vm.parameters[index].currentValue = value
            }
        }
    }
    
    // MARK: - Calculate Preview Size (16:9 aspect ratio, full width)
    
    private func calculatePreviewSize(containerSize: CGSize) -> CGSize {
        // Use full width of container
        let availableWidth = containerSize.width
        var height = availableWidth / hdmiAspectRatio
        
        // If height exceeds available height, calculate based on height instead
        if height > containerSize.height {
            height = containerSize.height
            let width = height * hdmiAspectRatio
            return CGSize(width: width, height: height)
        }
        
        return CGSize(width: availableWidth, height: height)
    }
    
    // MARK: - Overlay Controls
    
    @ViewBuilder
    private var overlayControls: some View {
        VStack {
            // Top bar with shader info
            if let shader = shader {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(shader.name)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                        
                        HStack(spacing: 12) {
                            Label(shader.category.rawValue, systemImage: shader.category.icon)
                                .font(.caption)
                                .foregroundColor(.gray)
                            
                            if shader.isFavorite {
                                Image(systemName: "heart.fill")
                                    .foregroundColor(.red)
                            }
                            
                            Text("by \(shader.author)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                    
                    Spacer()
                    
                    // Info button
                    Button {
                        withAnimation {
                            showInfo.toggle()
                        }
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.white.opacity(0.8))
                    }
                }
                .padding()
                .background(
                    LinearGradient(
                        colors: [.black.opacity(0.7), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
            }
            
            Spacer()
            
            // Bottom playback controls
            HStack(spacing: 20) {
                // Play/Pause
                Button {
                    isPlaying.toggle()
                } label: {
                    Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 44))
                        .foregroundColor(.white)
                }
                
                // Reset time
                Button {
                    currentTime = 0
                } label: {
                    Image(systemName: "arrow.counterclockwise")
                        .font(.title2)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                // Time display
                Text(String(format: "%.1fs", currentTime))
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.white.opacity(0.8))
            }
            .padding()
            .background(
                LinearGradient(
                    colors: [.clear, .black.opacity(0.7)],
                    startPoint: .top,
                    endPoint: .bottom
                )
            )
        }
        .cornerRadius(8)
    }
}

// MARK: - Shader Info Panel

struct ShaderInfoPanel: View {
    let shader: ShaderEntity
    @Binding var isPresented: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Shader Info")
                    .font(.headline)
                
                Spacer()
                
                Button {
                    isPresented = false
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
            
            Divider()
            
            Group {
                InfoRow(label: "Name", value: shader.name)
                InfoRow(label: "Category", value: shader.category.rawValue)
                InfoRow(label: "Author", value: shader.author)
                InfoRow(label: "Version", value: shader.version)
                InfoRow(label: "Views", value: "\(shader.viewCount)")
                InfoRow(label: "Created", value: shader.dateCreated.formatted(date: .abbreviated, time: .omitted))
                
                if !shader.shaderDescription.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Description")
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text(shader.shaderDescription)
                            .font(.body)
                    }
                }
                
                if !shader.tags.isEmpty {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Tags")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        FlowLayout(spacing: 4) {
                            ForEach(shader.tags, id: \.self) { tag in
                                Text(tag)
                                    .font(.caption)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.blue.opacity(0.2))
                                    .cornerRadius(4)
                            }
                        }
                    }
                }
            }
        }
        .padding()
        .frame(width: 300)
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .shadow(radius: 20)
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.body)
        }
    }
}

// MARK: - Flow Layout for Tags

struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []
        
        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0
            
            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)
                
                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }
                
                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing
                
                self.size.width = max(self.size.width, x)
            }
            
            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Metal Shader View
// RADYKALNA OPTYMALIZACJA: Całkowite odłączenie parametrów od SwiftUI diff
// - Coordinator przechowuje WŁASNĄ referencję do ViewModel
// - updateUIView NIGDY nie przekazuje parametrów
// - Parametry są pobierane bezpośrednio w draw() przez zapisaną referencję

struct MetalShaderView: UIViewRepresentable {
    let shaderCode: String
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    
    // Referencja do ViewModel - przekazywana do Coordinatora w makeCoordinator
    var parametersVM: ShaderParametersViewModel?
    
    // OPTYMALIZACJA: Czy używać współdzielonego device (dla preview zachowujemy własny @ 60fps)
    var useSharedResources: Bool = false
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60  // Główny preview @ 60fps
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.framebufferOnly = false
        
        // OPTYMALIZACJA: Użyj współdzielonego device lub utwórz własny
        if let device = useSharedResources ? SharedMetalResources.device : MTLCreateSystemDefaultDevice() {
            mtkView.device = device
            context.coordinator.setupMetal(device: device, shaderCode: shaderCode, useSharedQueue: useSharedResources)
        }
        
        // WAŻNE: Zapisz referencję do VM w Coordinatorze - to jednorazowe!
        context.coordinator.parametersVM = parametersVM
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        // TYLKO isPaused i shader code - NIGDY parametry!
        uiView.isPaused = !isPlaying
        context.coordinator.updateShader(shaderCode)
        // Coordinator już ma referencję do VM - nie musimy nic przekazywać
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalShaderView
        var device: MTLDevice?
        var commandQueue: MTLCommandQueue?
        var useSharedQueue: Bool = false
        var pipelineState: MTLRenderPipelineState?
        var startTime: Date = Date()
        var currentShaderCode: String = ""
        
        // WŁASNA referencja do ViewModel - NIE przez parent!
        var parametersVM: ShaderParametersViewModel?
        
        // Parametry sparsowane jednorazowo przy tworzeniu pipeline
        var parameterNames: [String] = []
        var parameterDefaults: [String: Float] = [:]
        
        // Obserwator notyfikacji czyszczenia
        private var clearObserver: NSObjectProtocol?
        
        init(_ parent: MetalShaderView) {
            self.parent = parent
            super.init()
            
            // Nasłuchuj na notyfikację czyszczenia (używamy ResourceNotifications - poza MainActor)
            clearObserver = NotificationCenter.default.addObserver(
                forName: ResourceNotifications.clearThumbnails,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.clearResources()
            }
        }
        
        deinit {
            // Usuń obserwatora - NIE używaj weak self w deinit!
            if let observer = clearObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
        /// Czyści zasoby GPU tego koordynatora
        func clearResources() {
            pipelineState = nil
            // Nie czyść commandQueue jeśli używamy współdzielonej
            if !useSharedQueue {
                commandQueue = nil
            }
            parameterNames = []
            parameterDefaults = [:]
        }
        
        func setupMetal(device: MTLDevice, shaderCode: String, useSharedQueue: Bool = false) {
            self.device = device
            self.useSharedQueue = useSharedQueue
            
            // OPTYMALIZACJA: Użyj współdzielonej kolejki (SharedMetalResources - nonisolated)
            if useSharedQueue {
                self.commandQueue = SharedMetalResources.commandQueue
            } else {
                self.commandQueue = device.makeCommandQueue()
            }
            
            self.currentShaderCode = shaderCode
            createPipelineState(shaderCode: shaderCode)
        }
        
        func updateShader(_ shaderCode: String) {
            guard shaderCode != currentShaderCode else { return }
            currentShaderCode = shaderCode
            createPipelineState(shaderCode: shaderCode)
        }
        
        func createPipelineState(shaderCode: String) {
            guard let device = device else { return }
            
            // OPTYMALIZACJA: Pobierz cache'owane parametry (SharedMetalResources - thread-safe)
            if let cachedParams = SharedMetalResources.getCachedParameters(for: shaderCode) {
                parameterNames = cachedParams.names
                parameterDefaults = cachedParams.defaults
            } else {
                // Parsuj i cache'uj
                let parsed = ShaderParameterParser.parseParameters(from: shaderCode)
                let params = (
                    names: parsed.map { $0.name },
                    defaults: parsed.reduce(into: [:]) { $0[$1.name] = $1.defaultValue }
                )
                parameterNames = params.names
                parameterDefaults = params.defaults
                SharedMetalResources.setCachedParameters(params, for: shaderCode)
            }
            
            // OPTYMALIZACJA: Sprawdź cache pipeline'ów (SharedMetalResources - thread-safe)
            if let cachedPipeline = SharedMetalResources.getCachedPipeline(for: shaderCode) {
                self.pipelineState = cachedPipeline
                return
            }
            
            // Parsuj parametry do budowy shadera
            let parsedParams = ShaderParameterParser.parseParameters(from: shaderCode)
            
            // Build full Metal shader
            let fullShader = buildMetalShader(from: shaderCode, parameters: parsedParams)
            
            do {
                let library = try device.makeLibrary(source: fullShader, options: nil)
                let vertexFunction = library.makeFunction(name: "vertexShader")
                let fragmentFunction = library.makeFunction(name: "fragmentShader")
                
                let pipelineDescriptor = MTLRenderPipelineDescriptor()
                pipelineDescriptor.vertexFunction = vertexFunction
                pipelineDescriptor.fragmentFunction = fragmentFunction
                pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
                
                let newPipeline = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
                pipelineState = newPipeline
                
                // OPTYMALIZACJA: Cache'uj nowy pipeline (SharedMetalResources - thread-safe)
                SharedMetalResources.setCachedPipeline(newPipeline, for: shaderCode)
            } catch {
                print("Failed to create pipeline state: \(error)")
                createFallbackPipeline()
            }
        }
        
        func createFallbackPipeline() {
            guard let device = device else { return }
            
            parameterNames = []
            parameterDefaults = [:]
            
            let fallbackShader = """
            #include <metal_stdlib>
            using namespace metal;
            
            struct VertexOut {
                float4 position [[position]];
                float2 uv;
            };
            
            vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
                float2 positions[6] = {
                    float2(-1, -1), float2(1, -1), float2(-1, 1),
                    float2(-1, 1), float2(1, -1), float2(1, 1)
                };
                
                VertexOut out;
                out.position = float4(positions[vertexID], 0, 1);
                out.uv = positions[vertexID] * 0.5 + 0.5;
                return out;
            }
            
            fragment float4 fragmentShader(VertexOut in [[stage_in]], constant float &time [[buffer(0)]]) {
                float2 uv = in.uv;
                float3 col = 0.5 + 0.5 * cos(time + uv.xyx + float3(0, 2, 4));
                return float4(col, 1.0);
            }
            """
            
            do {
                let library = try device.makeLibrary(source: fallbackShader, options: nil)
                let vertexFunction = library.makeFunction(name: "vertexShader")
                let fragmentFunction = library.makeFunction(name: "fragmentShader")
                
                let pipelineDescriptor = MTLRenderPipelineDescriptor()
                pipelineDescriptor.vertexFunction = vertexFunction
                pipelineDescriptor.fragmentFunction = fragmentFunction
                pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
                
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("Failed to create fallback pipeline: \(error)")
            }
        }
        
        func buildMetalShader(from fragmentBody: String, parameters: [ShaderParameter]) -> String {
            var paramDeclarations = ""
            var paramBufferArg = ""
            
            if !parameters.isEmpty {
                paramDeclarations = """
                
                struct ShaderParams {
                \(parameters.map { "    float \($0.name);" }.joined(separator: "\n"))
                };
                
                """
                paramBufferArg = ", constant ShaderParams &params [[buffer(1)]]"
            }
            
            let cleanBody = fragmentBody
                .components(separatedBy: "\n")
                .filter { !$0.contains("@param") && !$0.contains("@toggle") }
                .joined(separator: "\n")
            
            var processedBody = cleanBody
            for param in parameters {
                let pattern = "\\b\(param.name)\\b"
                if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
                    processedBody = regex.stringByReplacingMatches(
                        in: processedBody,
                        options: [],
                        range: NSRange(processedBody.startIndex..., in: processedBody),
                        withTemplate: "params.\(param.name)"
                    )
                }
            }
            
            return """
            #include <metal_stdlib>
            using namespace metal;
            
            struct VertexOut {
                float4 position [[position]];
                float2 uv;
            };
            \(paramDeclarations)
            vertex VertexOut vertexShader(uint vertexID [[vertex_id]]) {
                float2 positions[6] = {
                    float2(-1, -1), float2(1, -1), float2(-1, 1),
                    float2(-1, 1), float2(1, -1), float2(1, 1)
                };
                
                VertexOut out;
                out.position = float4(positions[vertexID], 0, 1);
                out.uv = positions[vertexID] * 0.5 + 0.5;
                out.uv.y = 1.0 - out.uv.y;
                return out;
            }
            
            fragment float4 fragmentShader(VertexOut in [[stage_in]], constant float &iTime [[buffer(0)]]\(paramBufferArg)) {
                float2 uv = in.uv;
                \(processedBody)
            }
            """
        }
        
        func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {}
        
        func draw(in view: MTKView) {
            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandBuffer = commandQueue?.makeCommandBuffer(),
                  let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
                  let pipelineState = pipelineState else {
                return
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            
            // Throttled time update - tylko gdy różnica > 0.1s (dla UI display)
            if abs(parent.currentTime - elapsed) > 0.1 {
                DispatchQueue.main.async { [weak self] in
                    self?.parent.currentTime = elapsed
                }
            }
            
            var time = Float(elapsed)
            
            encoder.setRenderPipelineState(pipelineState)
            encoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
            
            // BEZPOŚREDNI dostęp do parametrów przez WŁASNĄ referencję do ViewModel
            if !parameterNames.isEmpty {
                var paramValues: [Float] = []
                
                // Pobierz wartości - MTKViewDelegate.draw() jest ZAWSZE wywoływany na main thread
                // więc możemy bezpiecznie użyć MainActor.assumeIsolated
                MainActor.assumeIsolated { [self] in
                    if let vm = self.parametersVM {
                        for name in self.parameterNames {
                            if let param = vm.parameters.first(where: { $0.name == name }) {
                                paramValues.append(param.currentValue)
                            } else {
                                paramValues.append(self.parameterDefaults[name] ?? 0.5)
                            }
                        }
                    } else {
                        // Fallback: użyj domyślnych wartości
                        for name in self.parameterNames {
                            paramValues.append(self.parameterDefaults[name] ?? 0.5)
                        }
                    }
                }
                
                if !paramValues.isEmpty {
                    encoder.setFragmentBytes(&paramValues, length: MemoryLayout<Float>.size * paramValues.count, index: 1)
                }
            }
            
            encoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 6)
            encoder.endEncoding()
            
            commandBuffer.present(drawable)
            commandBuffer.commit()
        }
    }
}

// MARK: - Fullscreen Shader Overlay (with zoom animation)

struct FullscreenShaderOverlay: View {
    let shader: ShaderEntity?
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    @Binding var isPresented: Bool
    var animation: Namespace.ID
    
    @State private var showControls: Bool = false
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            if let shader = shader {
                MetalShaderView(
                    shaderCode: shader.fragmentCode,
                    isPlaying: $isPlaying,
                    currentTime: $currentTime
                )
                .matchedGeometryEffect(id: "shaderView", in: animation)
                .ignoresSafeArea()
            }
            
            // Controls overlay
            if showControls {
                VStack {
                    // Top bar with close button
                    HStack {
                        Spacer()
                        
                        Button {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isPresented = false
                            }
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                    }
                    .background(
                        LinearGradient(
                            colors: [.black.opacity(0.5), .clear],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    
                    Spacer()
                    
                    // Bottom playback controls
                    HStack(spacing: 20) {
                        Button {
                            isPlaying.toggle()
                        } label: {
                            Image(systemName: isPlaying ? "pause.circle.fill" : "play.circle.fill")
                                .font(.system(size: 44))
                                .foregroundColor(.white)
                        }
                        
                        Button {
                            currentTime = 0
                        } label: {
                            Image(systemName: "arrow.counterclockwise")
                                .font(.title2)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        
                        Spacer()
                        
                        Text(String(format: "%.1fs", currentTime))
                            .font(.system(.body, design: .monospaced))
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [.clear, .black.opacity(0.5)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                }
                .transition(.opacity)
            }
        }
        .statusBarHidden(true)
        .persistentSystemOverlays(.hidden)
        .contentShape(Rectangle())
        .onTapGesture(count: 2) {
            // Double tap to exit fullscreen with zoom animation
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                isPresented = false
            }
        }
        .onTapGesture(count: 1) {
            // Single tap to toggle controls
            withAnimation(.easeInOut(duration: 0.25)) {
                showControls.toggle()
            }
        }
    }
}

#Preview {
    ShaderPreviewView(
        shader: nil,
        isFullscreen: .constant(false),
        showingParametersView: .constant(false),
        viewMode: .constant(.preview),
        parametersVM: ShaderParametersViewModel(),
        automationManager: ParameterAutomationManager()
    )
}
