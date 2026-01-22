//
//  ShaderListView.swift
//  LM_GLSL
//
//  List of available shaders - grid layout with thumbnails
//

import SwiftUI
import SwiftData
import MetalKit

struct ShaderListView: View {
    @Environment(\.modelContext) private var modelContext
    
    let shaders: [ShaderEntity]
    @Binding var selectedShader: ShaderEntity?
    @Binding var selectedCategory: ShaderCategory
    @Binding var searchText: String
    @Binding var isCustomizing: Bool
    @Binding var showingNewShaderSheet: Bool
    @Binding var showingParametersView: Bool
    @Binding var viewMode: ViewMode
    
    // Shader sync service
    @ObservedObject var syncService: ShaderSyncService
    
    @State private var showingFavorites: Bool = false
    
    // Filtered shaders based on favorites
    private var displayedShaders: [ShaderEntity] {
        if showingFavorites {
            return shaders.filter { $0.isFavorite }
        }
        return shaders
    }
    
    // Grid layout: 2 columns for shaders
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    // Grid layout: 3 columns for empty slots
    private let slotColumns = [
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6),
        GridItem(.flexible(), spacing: 6)
    ]
    
    var body: some View {
        VStack(spacing: 0) {
            // Title row
            Text("GLSL Shaders")
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 12)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            // Buttons row: <3 and +
            HStack(spacing: 8) {
                // Favorites toggle button
                Button(action: {
                    showingFavorites.toggle()
                }) {
                    Image(systemName: showingFavorites ? "heart.fill" : "heart")
                        .font(.body)
                        .foregroundColor(showingFavorites ? .black : Color(white: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(showingFavorites ? Color.white.opacity(0.9) : Color(white: 0.15))
                        .cornerRadius(6)
                }
                
                // Add Custom button
                Button(action: { showingNewShaderSheet = true }) {
                    Image(systemName: "plus")
                        .font(.body)
                        .foregroundColor(Color(white: 0.6))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color(white: 0.15))
                        .cornerRadius(6)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            // 6 slots - first one is broadcast toggle, rest are empty
            LazyVGrid(columns: slotColumns, spacing: 6) {
                // Broadcast toggle button (first slot)
                Button(action: {
                    if syncService.isAdvertising {
                        syncService.stop()
                    } else {
                        syncService.start()
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .fill(Color(white: 0.1))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(white: 0.2), lineWidth: 1)
                            )
                            .cornerRadius(6)
                        
                        VStack(spacing: 4) {
                            Image(systemName: syncService.isAdvertising ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash")
                                .font(.system(size: 16))
                                .foregroundColor(syncService.isAdvertising ? .green : Color(white: 0.4))
                            
                            if syncService.isConnected && syncService.connectedReceivers.count > 0 {
                                Text("\(syncService.connectedReceivers.count)")
                                    .font(.system(size: 10, weight: .bold))
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                // Parameters button for current shader (second slot)
                Button(action: {
                    if selectedShader != nil {
                        showingParametersView = true
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .fill(selectedShader != nil ? Color(white: 0.1) : Color(white: 0.05))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(white: 0.2), lineWidth: 1)
                            )
                            .cornerRadius(6)
                        
                        Image(systemName: "slider.horizontal.3")
                            .font(.system(size: 16))
                            .foregroundColor(selectedShader != nil ? Color(white: 0.6) : Color(white: 0.3))
                    }
                }
                .disabled(selectedShader == nil)
                
                // View mode toggle button (Preview/Grid) (third slot)
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        viewMode = viewMode == .preview ? .grid : .preview
                    }
                }) {
                    ZStack {
                        Rectangle()
                            .fill(Color(white: 0.1))
                            .aspectRatio(1, contentMode: .fit)
                            .overlay(
                                RoundedRectangle(cornerRadius: 6)
                                    .stroke(Color(white: 0.2), lineWidth: 1)
                            )
                            .cornerRadius(6)
                        
                        Image(systemName: viewMode == .grid ? "rectangle.center.inset.filled" : "square.grid.3x3.fill")
                            .font(.system(size: 16))
                            .foregroundColor(viewMode == .grid ? .blue : Color(white: 0.4))
                    }
                }
                
                // Remaining 3 empty slots
                ForEach(0..<3, id: \.self) { _ in
                    emptySlotButton
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 12)
            
            Divider()
                .background(Color(white: 0.2))
            
            // Shader grid
            ScrollView {
                if showingFavorites && displayedShaders.isEmpty {
                    // No favorites message
                    VStack(spacing: 8) {
                        Image(systemName: "heart.slash")
                            .font(.title)
                            .foregroundColor(Color(white: 0.3))
                        Text("No favorites yet")
                            .font(.caption)
                            .foregroundColor(Color(white: 0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else if displayedShaders.isEmpty {
                    // No shaders found
                    VStack(spacing: 8) {
                        Image(systemName: "magnifyingglass")
                            .font(.title)
                            .foregroundColor(Color(white: 0.3))
                        Text("No shaders found")
                            .font(.caption)
                            .foregroundColor(Color(white: 0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 40)
                } else {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(displayedShaders) { shader in
                            ShaderGridItem(
                                shader: shader,
                                isSelected: selectedShader?.id == shader.id,
                                onSelect: {
                                    selectedShader = shader
                                    shader.incrementViewCount()
                                },
                                onToggleFavorite: {
                                    shader.isFavorite.toggle()
                                    try? modelContext.save()
                                },
                                onParameters: {
                                    selectedShader = shader
                                    showingParametersView = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.top, 8)
                }
            }
        }
        .background(Color(white: 0.05))
    }
    
    // Empty slot button
    private var emptySlotButton: some View {
        Rectangle()
            .fill(Color(white: 0.1))
            .aspectRatio(1, contentMode: .fit)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(white: 0.2), lineWidth: 1)
            )
            .cornerRadius(6)
    }
}

// MARK: - Shader Grid Item with animated thumbnail

struct ShaderGridItem: View {
    let shader: ShaderEntity
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    let onParameters: () -> Void
    
    var body: some View {
        VStack(spacing: 4) {
            // Animated shader thumbnail - with saved parameter values
            // Use parametersHash as id to force refresh when parameters change
            ShaderThumbnailView(shaderCode: shader.fragmentCode, savedParameters: shader.parameters)
                .id(shader.parametersHash)
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
            
            // Buttons row: Heart and Parameters
            HStack(spacing: 4) {
                // Favorite button (heart)
                Button(action: onToggleFavorite) {
                    Image(systemName: shader.isFavorite ? "heart.fill" : "heart")
                        .font(.caption2)
                        .foregroundColor(shader.isFavorite ? .white : Color(white: 0.4))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color(white: 0.12))
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Parameters button
                Button(action: onParameters) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.caption2)
                        .foregroundColor(Color(white: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color(white: 0.12))
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(4)
        .background(isSelected ? Color(white: 0.15) : Color(white: 0.08))
        .cornerRadius(8)
        .onTapGesture {
            onSelect()
        }
    }
}

// MARK: - Shader Thumbnail View (small animated preview @ 30fps with shared resources)

struct ShaderThumbnailView: View {
    let shaderCode: String
    var savedParameters: [ShaderParameterEntity]? = nil
    
    var body: some View {
        ThumbnailMetalView(shaderCode: shaderCode, savedParameters: savedParameters)
    }
}

// MARK: - Optimized Thumbnail Metal View (30fps, shared resources)

struct ThumbnailMetalView: UIViewRepresentable {
    let shaderCode: String
    var savedParameters: [ShaderParameterEntity]? = nil
    
    // Convert saved parameters to dictionary for coordinator
    private var savedParameterValues: [String: Float] {
        guard let params = savedParameters else { return [:] }
        return params.reduce(into: [:]) { $0[$1.name] = $1.floatValue }
    }
    
    func makeUIView(context: Context) -> MTKView {
        let mtkView = MTKView()
        mtkView.delegate = context.coordinator
        
        // OPTYMALIZACJA: 30fps zamiast 60fps dla miniaturek
        mtkView.preferredFramesPerSecond = 30
        mtkView.enableSetNeedsDisplay = false
        mtkView.isPaused = false
        mtkView.framebufferOnly = false
        
        // OPTYMALIZACJA: Użyj współdzielonego device (SharedMetalResources - poza MainActor)
        if let sharedDevice = SharedMetalResources.device {
            mtkView.device = sharedDevice
            context.coordinator.setupMetal(shaderCode: shaderCode, savedValues: savedParameterValues)
        }
        
        return mtkView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        context.coordinator.updateShader(shaderCode, savedValues: savedParameterValues)
    }
    
    func makeCoordinator() -> ThumbnailCoordinator {
        ThumbnailCoordinator(shaderCode: shaderCode, savedValues: savedParameterValues)
    }
    
    class ThumbnailCoordinator: NSObject, MTKViewDelegate {
        var pipelineState: MTLRenderPipelineState?
        var startTime: Date = Date()
        var currentShaderCode: String
        var parameterNames: [String] = []
        var parameterDefaults: [String: Float] = [:]
        var savedParameterValues: [String: Float] = [:]
        
        private var clearObserver: NSObjectProtocol?
        
        init(shaderCode: String, savedValues: [String: Float] = [:]) {
            self.currentShaderCode = shaderCode
            self.savedParameterValues = savedValues
            super.init()
            
            // Używamy ResourceNotifications - poza MainActor
            clearObserver = NotificationCenter.default.addObserver(
                forName: ResourceNotifications.clearThumbnails,
                object: nil,
                queue: .main
            ) { [weak self] _ in
                self?.clearResources()
            }
        }
        
        deinit {
            if let observer = clearObserver {
                NotificationCenter.default.removeObserver(observer)
            }
        }
        
        func clearResources() {
            pipelineState = nil
            parameterNames = []
            parameterDefaults = [:]
            savedParameterValues = [:]
        }
        
        func setupMetal(shaderCode: String, savedValues: [String: Float] = [:]) {
            self.currentShaderCode = shaderCode
            self.savedParameterValues = savedValues
            createPipelineState(shaderCode: shaderCode)
        }
        
        func updateShader(_ shaderCode: String, savedValues: [String: Float] = [:]) {
            let codeChanged = shaderCode != currentShaderCode
            let valuesChanged = savedValues != savedParameterValues
            guard codeChanged || valuesChanged else { return }
            
            savedParameterValues = savedValues
            
            if codeChanged {
                currentShaderCode = shaderCode
                createPipelineState(shaderCode: shaderCode)
            }
        }
        
        func createPipelineState(shaderCode: String) {
            // Używamy SharedMetalResources (całkowicie poza MainActor)
            guard let device = SharedMetalResources.device else { return }
            
            // OPTYMALIZACJA: Pobierz cache'owane parametry (thread-safe)
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
            
            // OPTYMALIZACJA: Sprawdź cache pipeline'ów (thread-safe)
            if let cachedPipeline = SharedMetalResources.getCachedPipeline(for: shaderCode) {
                self.pipelineState = cachedPipeline
                return
            }
            
            // Parsuj parametry do budowy shadera
            let parsedParams = ShaderParameterParser.parseParameters(from: shaderCode)
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
                self.pipelineState = newPipeline
                
                // Cache'uj pipeline (thread-safe)
                SharedMetalResources.setCachedPipeline(newPipeline, for: shaderCode)
            } catch {
                print("❌ [ShaderListView] SHADER COMPILATION FAILED!")
                print("❌ Error: \(error.localizedDescription)")
                print("❌ ===== FULL GENERATED SHADER =====")
                let lines = fullShader.components(separatedBy: "\n")
                for (index, line) in lines.enumerated() {
                    print("\(String(format: "%3d", index + 1)): \(line)")
                }
                print("❌ ===== END OF SHADER =====")
                createFallbackPipeline()
            }
        }
        
        func createFallbackPipeline() {
            guard let device = SharedMetalResources.device else { return }
            
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
            // OPTYMALIZACJA: Używaj współdzielonej kolejki komend (SharedMetalResources - nonisolated)
            guard let drawable = view.currentDrawable,
                  let descriptor = view.currentRenderPassDescriptor,
                  let commandQueue = SharedMetalResources.commandQueue,
                  let commandBuffer = commandQueue.makeCommandBuffer(),
                  let encoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor),
                  let pipelineState = pipelineState else {
                return
            }
            
            let elapsed = Date().timeIntervalSince(startTime)
            var time = Float(elapsed)
            
            encoder.setRenderPipelineState(pipelineState)
            encoder.setFragmentBytes(&time, length: MemoryLayout<Float>.size, index: 0)
            
            // Użyj zapisanych wartości parametrów, a jeśli nie ma - domyślnych
            if !parameterNames.isEmpty {
                var paramValues: [Float] = parameterNames.map { name in
                    // Najpierw sprawdź zapisane wartości, potem domyślne
                    savedParameterValues[name] ?? parameterDefaults[name] ?? 0.5
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

#Preview {
    ShaderListView(
        shaders: [],
        selectedShader: .constant(nil),
        selectedCategory: .constant(.all),
        searchText: .constant(""),
        isCustomizing: .constant(false),
        showingNewShaderSheet: .constant(false),
        showingParametersView: .constant(false),
        viewMode: .constant(.preview),
        syncService: ShaderSyncService()
    )
    .modelContainer(for: ShaderEntity.self, inMemory: true)
}
