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
    @Query(sort: \ShaderFolder.order) private var allFolders: [ShaderFolder]
    
    // Store Manager for IAP
    @StateObject private var store = StoreManager.shared
    @State private var showPurchaseView = false
    
    @State private var selectedShader: ShaderEntity?
    @State private var selectedCategory: ShaderCategory = .all
    @State private var searchText: String = ""
    @State private var isCustomizing: Bool = false
    @State private var showingNewShaderSheet: Bool = false
    @State private var showingCodeEditor: Bool = false
    @State private var showingParametersView: Bool = false
    @State private var isFullscreen: Bool = false

    
    // View mode: Preview or Grid
    @State private var viewMode: ViewMode = .grid
    
    // Grid view specific states
    @State private var selectedFolder: ShaderFolder?
    @State private var selectedGridCategory: ShaderCategory?
    @State private var gridSearchText: String = ""
    
    // Community shaders mode
    @State private var showingCommunityShaders: Bool = false
    
    // Portrait bottom panel height (user draggable)
    @State private var bottomPanelHeight: CGFloat = 170
    @GestureState private var dragOffset: CGFloat = 0
    
    // Shader Sync Service
    @StateObject private var syncService = ShaderSyncService()
    
    // Shared parameter view model - single instance for both Preview and Parameters views
    @StateObject private var parametersVM = ShaderParametersViewModel()
    
    // Shared automation manager - NOT @StateObject since it's not ObservableObject
    // This persists across all views so automation continues in Grid mode
    @State private var automationManager = ParameterAutomationManager()
    
    // Timer for parameter sync (60fps)
    private let parameterSyncTimer = Timer.publish(every: 1.0/60.0, on: .main, in: .common).autoconnect()
    @State private var shaderStartTime: Date = Date()
    
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
                let isLandscape = geometry.size.width > geometry.size.height
                
                // In portrait mode, force grid view
                let effectiveViewMode: ViewMode = isLandscape ? viewMode : .grid
                
                if effectiveViewMode == .preview {
                    // Preview mode - always horizontal layout
                    HStack(spacing: 0) {
                        // Left side - Shader Preview (80%)
                        ShaderPreviewView(
                            shader: selectedShader,
                            isFullscreen: $isFullscreen,
                            showingParametersView: $showingParametersView,
                            viewMode: $viewMode,
                            syncService: syncService,
                            parametersVM: parametersVM,
                            automationManager: automationManager
                        )
                        .frame(width: geometry.size.width * 0.8)
                        
                        Divider()
                        
                        // Right side - Shader List or Customization Panel (20%)
                        Group {
                            if isCustomizing, let shader = selectedShader {
                                ShaderCustomizeView(
                                    shader: shader,
                                    parametersVM: parametersVM,
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
                                    viewMode: $viewMode,
                                    syncService: syncService
                                )
                            }
                        }
                        .frame(width: geometry.size.width * 0.2)
                    }
                } else {
                    // Grid mode - layout depends on orientation
                    if isLandscape {
                        // Landscape: panel on the right
                        HStack(spacing: 0) {
                            ShaderGridMainView(
                                shaders: allShaders,
                                selectedShader: $selectedShader,
                                showingParametersView: $showingParametersView,
                                viewMode: $viewMode,
                                selectedFolder: selectedFolder,
                                selectedCategory: selectedGridCategory,
                                searchText: gridSearchText,
                                showingCommunityShaders: $showingCommunityShaders
                            )
                            .frame(width: geometry.size.width * 0.8)
                            
                            Divider()
                            
                            FolderCategoryPanel(
                                selectedFolder: $selectedFolder,
                                selectedCategory: $selectedGridCategory,
                                showingNewShaderSheet: $showingNewShaderSheet,
                                viewMode: $viewMode,
                                showingParametersView: $showingParametersView,
                                selectedShader: selectedShader,
                                syncService: syncService,
                                showingCommunityShaders: $showingCommunityShaders,
                                automationManager: automationManager,
                                parametersVM: parametersVM,
                                searchText: $gridSearchText
                            )
                            .frame(width: geometry.size.width * 0.2)
                        }
                    } else {
                        // Portrait: user-draggable panel on the bottom
                        let minPanelHeight: CGFloat = 120
                        let maxPanelHeight: CGFloat = geometry.size.height * 0.7
                        let currentPanelHeight = min(max(bottomPanelHeight - dragOffset, minPanelHeight), maxPanelHeight)
                        
                        VStack(spacing: 0) {
                            ShaderGridMainView(
                                shaders: allShaders,
                                selectedShader: $selectedShader,
                                showingParametersView: $showingParametersView,
                                viewMode: $viewMode,
                                selectedFolder: selectedFolder,
                                selectedCategory: selectedGridCategory,
                                searchText: gridSearchText,
                                showingCommunityShaders: $showingCommunityShaders
                            )
                            
                            // Drag handle
                            VStack(spacing: 0) {
                                Capsule()
                                    .fill(Color(white: 0.5))
                                    .frame(width: 40, height: 5)
                                    .padding(.vertical, 8)
                                    .frame(maxWidth: .infinity)
                                    .background(Color(white: 0.08))
                                    .contentShape(Rectangle())
                                
                                Divider()
                            }
                            .gesture(
                                DragGesture()
                                    .updating($dragOffset) { value, state, _ in
                                        state = value.translation.height
                                    }
                                    .onEnded { value in
                                        let newHeight = bottomPanelHeight - value.translation.height
                                        bottomPanelHeight = min(max(newHeight, minPanelHeight), maxPanelHeight)
                                    }
                            )
                            
                            // Compact horizontal panel: buttons left, folders/categories right
                            PortraitBottomPanel(
                                selectedFolder: $selectedFolder,
                                selectedCategory: $selectedGridCategory,
                                showingNewShaderSheet: $showingNewShaderSheet,
                                viewMode: $viewMode,
                                showingParametersView: $showingParametersView,
                                selectedShader: selectedShader,
                                syncService: syncService,
                                showingCommunityShaders: $showingCommunityShaders,
                                automationManager: automationManager,
                                parametersVM: parametersVM
                            )
                            .frame(height: currentPanelHeight)
                        }
                    }
                }
            }
            
            // Fullscreen overlay on top of everything
            if isFullscreen {
                FullscreenShaderOverlayTopLevel(
                    shader: selectedShader,
                    isPresented: $isFullscreen,
                    parametersVM: parametersVM
                )
                .transition(.scale(scale: 0.1).combined(with: .opacity))
                .zIndex(999)
            }
            
            // License banner at bottom - only show if NO access at all
            if !store.hasFullAccess {
                VStack {
                    Spacer()
                    licenseBanner
                }
            }
        }
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPurchaseView) {
            PurchaseView()
        }
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
        .fullScreenCover(isPresented: $showingParametersView) {
            if let shader = selectedShader {
                ShaderParametersView(shader: shader, parametersVM: parametersVM, automationManager: automationManager)
            }
        }
        .onAppear {
            // Select first shader if none selected
            if selectedShader == nil {
                selectedShader = allShaders.first
            }
            // Load parameters for initial shader
            if let shader = selectedShader {
                loadParametersForShader(shader)
            }
            // Export folders to App Groups for MApp sync
            exportFoldersToAppGroups()
            // Note: Sync service is NOT started automatically
            // User must tap broadcast button to start
        }
        .onReceive(NotificationCenter.default.publisher(for: .shaderSyncFoldersRequested)) { _ in
            // MApp requested folders - send current folder list via MultipeerConnectivity
            broadcastFolders()
        }
        .onReceive(NotificationCenter.default.publisher(for: .sharedFoldersDidChange)) { _ in
            // MApp modified folders in App Groups - import changes
            importFoldersFromAppGroups()
        }
        .onChange(of: allFolders) { _, _ in
            // When folders change, export to App Groups
            exportFoldersToAppGroups()
        }
        .onChange(of: selectedShader) { oldValue, newValue in
            // Load parameters for new shader (important for portrait mode)
            if let shader = newValue {
                loadParametersForShader(shader)
            }
            // Broadcast shader change
            broadcastCurrentShader()
        }
        .onChange(of: syncService.isAdvertising) { oldValue, newValue in
            // When broadcasting starts, also start parameter streaming
            if newValue {
                // Resume timer if it was paused
                ResourceManager.shared.resumeParameterTimer()
                broadcastCurrentShader()  // Broadcast current shader first
                syncService.startParameterStreaming()
            } else {
                // OPTYMALIZACJA: Zatrzymaj timer gdy broadcast się kończy
                ResourceManager.shared.pauseParameterTimer()
                syncService.stopParameterStreaming()
            }
        }
        .onChange(of: syncService.isConnected) { oldValue, newValue in
            // OPTYMALIZACJA: Kontroluj timer na podstawie stanu połączenia
            if newValue && syncService.isAdvertising {
                // Połączono - wznów timer
                ResourceManager.shared.resumeParameterTimer()
            } else if !newValue {
                // Rozłączono - zatrzymaj timer (oszczędność CPU)
                ResourceManager.shared.pauseParameterTimer()
            }
        }
        .onReceive(parameterSyncTimer) { _ in
            // OPTYMALIZACJA: Szybkie sprawdzenie - skip jeśli timer jest wyłączony
            guard ResourceManager.shared.isParameterTimerActive else { return }
            
            // Sprawdź warunki broadcast + połączenie
            guard syncService.isAdvertising, syncService.isConnected else { return }
            
            // Build parameter values from parametersVM
            var paramValues: [String: Float] = [:]
            for param in parametersVM.parameters {
                paramValues[param.name] = param.currentValue
            }
            
            // Calculate elapsed time since shader started
            let elapsed = Date().timeIntervalSince(shaderStartTime)
            
            // Update sync service with current parameters
            syncService.updateParameters(paramValues, time: elapsed)
        }
        .onChange(of: selectedShader?.id) { _, _ in
            // Reset shader start time when shader changes
            shaderStartTime = Date()
        }
        .onChange(of: store.hasCompletedInitialCheck) { oldValue, completed in
            if completed {
                checkLicenseStatus()
            }
        }
    }
    
    // MARK: - License Banner
    
    private var licenseBanner: some View {
        Button(action: {
            showPurchaseView = true
        }) {
            HStack(spacing: 12) {
                Image(systemName: "lock.fill")
                    .font(.system(size: 16))
                
                Text("Purchase license to unlock full access")
                    .font(.system(size: 14, weight: .medium))
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.system(size: 12))
            }
            .foregroundColor(.white)
            .padding()
            .background(Color.orange)
            .padding(.horizontal)
        }
    }
    
    // MARK: - License Check
    
    private func checkLicenseStatus() {
        // Only show purchase screen if user has NO access after verification
        if !store.hasFullAccess {
            showPurchaseView = true
        }
    }
    
    // MARK: - Load Parameters for Shader
    
    private func loadParametersForShader(_ shader: ShaderEntity) {
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
        
        // Load and play automation from shader data - TYLKO jeśli nie jest zablokowane
        if !ResourceManager.shared.isAutomationBlocked {
            automationManager.loadAndPlay(from: shader.automationData)
            
            // Load automation presets for this shader
            automationManager.importPresetsFromData(shader.automationPresetsData)
        } else {
            // Jeśli zablokowane - wyczyść bieżącą automatyzację
            automationManager.clearAllTracks()
        }
        
        // Setup automation callback to update parameters during playback
        automationManager.onParameterUpdate = { [weak parametersVM] name, value in
            guard let vm = parametersVM else { return }
            if let index = vm.parameters.firstIndex(where: { $0.name == name }) {
                vm.parameters[index].currentValue = value
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
    
    /// Broadcast folders and shader-folder assignments to connected MApp receivers
    private func broadcastFolders() {
        // Convert ShaderFolder to SyncShaderFolder
        let syncFolders = allFolders.map { folder in
            SyncShaderFolder(
                id: folder.id,
                name: folder.name,
                colorHex: folder.colorHex,
                iconName: folder.iconName,
                order: folder.order
            )
        }
        
        // Build shader-folder assignments (shaderName -> [folderNames])
        var assignments: [SyncFolderAssignment] = []
        for shader in allShaders {
            // Find which folders contain this shader
            let containingFolders = allFolders.filter { $0.containsShader(shader.id) }
            if !containingFolders.isEmpty {
                let folderNames = containingFolders.map { $0.name }
                assignments.append(SyncFolderAssignment(
                    shaderName: shader.name,
                    folderNames: folderNames
                ))
            }
        }
        
        // Broadcast to all connected receivers
        syncService.broadcastFolders(folders: syncFolders, assignments: assignments)
    }
    
    // MARK: - App Groups Sync
    
    /// Export folders to App Groups shared storage (for MApp to read)
    private func exportFoldersToAppGroups() {
        SharedFolderSyncService.shared.exportFolders(folders: allFolders, shaders: allShaders)
    }
    
    /// Import folders from App Groups if MApp made changes
    private func importFoldersFromAppGroups() {
        SharedFolderSyncService.shared.importFolders(
            modelContext: modelContext,
            existingFolders: allFolders,
            shaders: allShaders
        )
    }
}

// MARK: - Fullscreen Shader Overlay (Top Level)

struct FullscreenShaderOverlayTopLevel: View {
    let shader: ShaderEntity?
    @Binding var isPresented: Bool
    @ObservedObject var parametersVM: ShaderParametersViewModel
    
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
                    currentTime: $currentTime,
                    parametersVM: parametersVM
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
        .onTapGesture(count: 2) {
            // Double tap to close fullscreen
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
    ContentView()
        .modelContainer(for: [ShaderEntity.self, ShaderParameterEntity.self, ShaderFolder.self], inMemory: true)
}
