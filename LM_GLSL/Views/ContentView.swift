//
//  ContentView.swift
//  LM_GLSL
//
//  Main view with shader preview (80%) and shader list (20%)
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShaderEntity.name) private var allShaders: [ShaderEntity]
    
    @State private var selectedShader: ShaderEntity?
    @State private var selectedCategory: ShaderCategory = .all
    @State private var searchText: String = ""
    @State private var isCustomizing: Bool = false
    @State private var showingNewShaderSheet: Bool = false
    @State private var showingCodeEditor: Bool = false
    @State private var showingParametersView: Bool = false
    @State private var isFullscreen: Bool = false
    @State private var parametersNeedRefresh: Bool = false
    
    // Shader Sync Service
    @StateObject private var syncService = ShaderSyncService()
    
    private var filteredShaders: [ShaderEntity] {
        var result = allShaders
        
        // Filter by category
        if selectedCategory != .all {
            result = result.filter { $0.category == selectedCategory }
        }
        
        // Filter by search text
        if !searchText.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchText) ||
                $0.shaderDescription.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        ZStack {
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    // Left side - Shader Preview (80%)
                    ShaderPreviewView(
                        shader: selectedShader,
                        isFullscreen: $isFullscreen,
                        syncService: syncService,
                        refreshTrigger: $parametersNeedRefresh
                    )
                    .frame(width: geometry.size.width * 0.8)
                    
                    Divider()
                    
                    // Right side - Shader List or Customization Panel (20%)
                    Group {
                        if isCustomizing, let shader = selectedShader {
                            ShaderCustomizeView(
                                shader: shader,
                                isCustomizing: $isCustomizing,
                                showingCodeEditor: $showingCodeEditor
                            )
                        } else {
                            ShaderListView(
                                shaders: filteredShaders,
                                selectedShader: $selectedShader,
                                selectedCategory: $selectedCategory,
                                searchText: $searchText,
                                isCustomizing: $isCustomizing,
                                showingNewShaderSheet: $showingNewShaderSheet,
                                showingParametersView: $showingParametersView,
                                syncService: syncService
                            )
                        }
                    }
                    .frame(width: geometry.size.width * 0.2)
                }
            }
            
            // Fullscreen overlay on top of everything
            if isFullscreen {
                FullscreenShaderOverlayTopLevel(
                    shader: selectedShader,
                    isPresented: $isFullscreen
                )
                .transition(.scale(scale: 0.1).combined(with: .opacity))
                .zIndex(999)
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showingNewShaderSheet) {
            NewShaderView { newShader in
                modelContext.insert(newShader)
                try? modelContext.save()
                selectedShader = newShader
            }
        }
        .sheet(isPresented: $showingCodeEditor) {
            if let shader = selectedShader {
                ShaderCodeEditorView(shader: shader) {
                    try? modelContext.save()
                }
            }
        }
        .fullScreenCover(isPresented: $showingParametersView, onDismiss: {
            // Force refresh shader parameters after editing
            parametersNeedRefresh = true
        }) {
            if let shader = selectedShader {
                ShaderParametersView(shader: shader)
            }
        }
        .onAppear {
            // Select first shader if none selected
            if selectedShader == nil {
                selectedShader = allShaders.first
            }
            // Note: Sync service is NOT started automatically
            // User must tap broadcast button to start
        }
        .onChange(of: selectedShader) { oldValue, newValue in
            // Broadcast shader change
            broadcastCurrentShader()
        }
        .onChange(of: syncService.isAdvertising) { oldValue, newValue in
            // When broadcasting starts, also start parameter streaming
            if newValue {
                syncService.startParameterStreaming()
            } else {
                syncService.stopParameterStreaming()
            }
        }
    }
    
    // MARK: - Shader Sync
    
    private func broadcastCurrentShader() {
        guard let shader = selectedShader else { return }
        
        // Convert parameters from ShaderParameterEntity to SyncShaderParameter
        let syncParams = (shader.parameters ?? []).map { param in
            SyncShaderParameter(
                id: param.id,
                name: param.name,
                displayName: param.displayName,
                type: param.parameterType == "bool" ? "toggle" : "slider",
                minValue: param.minValue,
                maxValue: param.maxValue,
                currentValue: param.floatValue
            )
        }
        
        syncService.broadcastShader(
            shaderId: shader.id,
            shaderName: shader.name,
            shaderCategory: shader.category.rawValue,
            fragmentCode: shader.fragmentCode,
            vertexCode: shader.vertexCode,
            parameters: syncParams
        )
    }
}

// MARK: - Fullscreen Shader Overlay (Top Level)

struct FullscreenShaderOverlayTopLevel: View {
    let shader: ShaderEntity?
    @Binding var isPresented: Bool
    
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 0
    @State private var showControls: Bool = false
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            if let shader = shader {
                MetalShaderView(
                    shaderCode: shader.fragmentCode,
                    isPlaying: $isPlaying,
                    currentTime: $currentTime
                )
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
                                .font(.title)
                                .foregroundColor(.white.opacity(0.8))
                        }
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
        .contentShape(Rectangle())
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.25)) {
                showControls.toggle()
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ShaderEntity.self, ShaderParameterEntity.self], inMemory: true)
}
