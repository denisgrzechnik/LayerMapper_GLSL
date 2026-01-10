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
    var syncService: ShaderSyncService?
    @ObservedObject var parametersVM: ShaderParametersViewModel
    
    // HDMI output aspect ratio (16:9)
    private let hdmiAspectRatio: CGFloat = 16.0 / 9.0
    
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 0
    @State private var showInfo: Bool = false
    @State private var showOverlay: Bool = false
    @State private var shaderStartTime: Date = Date()
    @State private var lastSyncTime: Date = Date.distantPast
    
    // Automation & Parameters
    @StateObject private var automationManager = ParameterAutomationManager()
    
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
                            parameters: parametersVM.parameters
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
        .onChange(of: currentTime) { _, newTime in
            // Send current parameters to sync service during rendering
            sendParametersToSync()
        }
        .onAppear {
            loadShaderData()
            shaderStartTime = Date()
        }
    }
    
    // MARK: - Send Parameters to Sync
    
    private func sendParametersToSync() {
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
        
        // Send to sync service
        syncService.updateParameters(paramValues, time: elapsed)
    }
    
    // MARK: - Load Shader Data & Automation
    
    private func loadShaderData() {
        guard let shader = shader else {
            automationManager.clearAllTracks()
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
        
        // Load and play automation
        automationManager.loadAndPlay(from: shader.automationData)
        
        // Setup automation callback
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

struct MetalShaderView: UIViewRepresentable {
    let shaderCode: String
    @Binding var isPlaying: Bool
    @Binding var currentTime: Double
    var parameters: [ShaderParameter] = []
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        mtkView.preferredFramesPerSecond = 60
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.framebufferOnly = false
        
        if let device = MTLCreateSystemDefaultDevice() {
            mtkView.device = device
            context.coordinator.setupMetal(device: device, shaderCode: shaderCode)
        }
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        uiView.isPaused = !isPlaying
        context.coordinator.updateShader(shaderCode)
        context.coordinator.updateParameters(parameters)
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MTKViewDelegate {
        var parent: MetalShaderView
        var device: MTLDevice?
        var commandQueue: MTLCommandQueue?
        var pipelineState: MTLRenderPipelineState?
        var startTime: Date = Date()
        var currentShaderCode: String = ""
        var currentParameters: [ShaderParameter] = []
        var shaderExpectsParams: Bool = false  // Track if compiled shader expects params
        
        init(_ parent: MetalShaderView) {
            self.parent = parent
        }
        
        func setupMetal(device: MTLDevice, shaderCode: String) {
            self.device = device
            self.commandQueue = device.makeCommandQueue()
            self.currentShaderCode = shaderCode
            
            createPipelineState(shaderCode: shaderCode)
        }
        
        func updateShader(_ shaderCode: String) {
            guard shaderCode != currentShaderCode else { return }
            currentShaderCode = shaderCode
            createPipelineState(shaderCode: shaderCode)
        }
        
        func updateParameters(_ parameters: [ShaderParameter]) {
            currentParameters = parameters
        }
        
        func createPipelineState(shaderCode: String) {
            guard let device = device else { return }
            
            // Build full Metal shader
            let fullShader = buildMetalShader(from: shaderCode)
            
            do {
                let library = try device.makeLibrary(source: fullShader, options: nil)
                let vertexFunction = library.makeFunction(name: "vertexShader")
                let fragmentFunction = library.makeFunction(name: "fragmentShader")
                
                let pipelineDescriptor = MTLRenderPipelineDescriptor()
                pipelineDescriptor.vertexFunction = vertexFunction
                pipelineDescriptor.fragmentFunction = fragmentFunction
                pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
                
                pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
            } catch {
                print("Failed to create pipeline state: \(error)")
                // Create fallback shader
                createFallbackPipeline()
            }
        }
        
        func createFallbackPipeline() {
            guard let device = device else { return }
            
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
        
        func buildMetalShader(from fragmentBody: String) -> String {
            // Parse parameters from code
            let parameters = ShaderParameterParser.parseParameters(from: fragmentBody)
            
            // Track if this shader expects parameters
            shaderExpectsParams = !parameters.isEmpty
            
            // Build parameter declarations for fragment shader
            var paramDeclarations = ""
            var paramBufferArg = ""
            
            if !parameters.isEmpty {
                // Create struct for parameters
                paramDeclarations = """
                
                struct ShaderParams {
                \(parameters.map { "    float \($0.name);" }.joined(separator: "\n"))
                };
                
                """
                paramBufferArg = ", constant ShaderParams &params [[buffer(1)]]"
            }
            
            // Strip @param and @toggle comments from the body for cleaner code
            let cleanBody = fragmentBody
                .components(separatedBy: "\n")
                .filter { !$0.contains("@param") && !$0.contains("@toggle") }
                .joined(separator: "\n")
            
            // Replace parameter names with params.name
            var processedBody = cleanBody
            for param in parameters {
                // Replace standalone parameter names (not part of other words)
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
                out.uv.y = 1.0 - out.uv.y; // Flip Y
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
            DispatchQueue.main.async {
                self.parent.currentTime = elapsed
            }
            
            var time = Float(elapsed)
            
            encoder.setRenderPipelineState(pipelineState)
            encoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
            
            // Pass parameters to shader only if shader expects them
            if shaderExpectsParams {
                // Get parameters from code to ensure correct order
                let codeParams = ShaderParameterParser.parseParameters(from: currentShaderCode)
                
                // Build values array matching the order in code
                var paramValues: [Float] = []
                for codeParam in codeParams {
                    // Find matching parameter from UI (by name)
                    if let uiParam = currentParameters.first(where: { $0.name == codeParam.name }) {
                        paramValues.append(uiParam.currentValue)
                    } else {
                        // Use default value if not found in UI
                        paramValues.append(codeParam.defaultValue)
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
        parametersVM: ShaderParametersViewModel()
    )
}
