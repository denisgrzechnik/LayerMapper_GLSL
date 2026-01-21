//
//  PortraitBottomPanel.swift
//  LM_GLSL
//
//  Compact horizontal panel for portrait mode - buttons left (1/3), folders/categories right (2/3)
//

import SwiftUI
import SwiftData

struct PortraitBottomPanel: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShaderFolder.order) private var folders: [ShaderFolder]
    
    @Binding var selectedFolder: ShaderFolder?
    @Binding var selectedCategory: ShaderCategory?
    @Binding var showingNewShaderSheet: Bool
    @Binding var viewMode: ViewMode
    @Binding var showingParametersView: Bool
    var selectedShader: ShaderEntity?
    
    @ObservedObject var syncService: ShaderSyncService
    
    // Community shaders mode
    @Binding var showingCommunityShaders: Bool
    
    // Automation manager for release resources button
    var automationManager: ParameterAutomationManager?
    
    // Parameters VM for resetting to defaults
    var parametersVM: ShaderParametersViewModel?
    
    @State private var selectedTab: PanelTab = .folder
    @State private var showingNewFolderSheet: Bool = false
    @State private var newFolderName: String = ""
    
    enum PanelTab: String, CaseIterable {
        case folder = "Folder"
        case category = "Category"
        
        var icon: String {
            switch self {
            case .folder: return "folder.fill"
            case .category: return "square.grid.2x2.fill"
            }
        }
    }
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side: Function buttons (1/3 width)
                functionButtonsCompact
                    .frame(width: geometry.size.width / 3)
                
                Divider()
                
                // Right side: Folders/Categories list (2/3 width)
                foldersPanel
                    .frame(width: geometry.size.width * 2 / 3)
            }
        }
        .background(Color(white: 0.05))
        .sheet(isPresented: $showingNewFolderSheet) {
            newFolderSheet
        }
    }
    
    // MARK: - Folders Panel (right side)
    
    private var foldersPanel: some View {
        VStack(spacing: 6) {
            // Top row: + button, Folder tab, Category tab (square buttons matching left side)
            HStack(spacing: 6) {
                // Add folder button
                Button(action: {
                    if selectedTab == .folder {
                        showingNewFolderSheet = true
                    }
                }) {
                    Image(systemName: "plus")
                        .font(.system(size: 14))
                        .foregroundColor(Color(white: 0.6))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(Color(white: 0.12))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color(white: 0.2), lineWidth: 0.5)
                        )
                }
                
                // Folder tab
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .folder
                        selectedCategory = nil
                    }
                }) {
                    Image(systemName: "folder.fill")
                        .font(.system(size: 14))
                        .foregroundColor(selectedTab == .folder ? .white : Color(white: 0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(selectedTab == .folder ? Color(white: 0.25) : Color(white: 0.12))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(selectedTab == .folder ? Color.white.opacity(0.3) : Color(white: 0.2), lineWidth: selectedTab == .folder ? 1 : 0.5)
                        )
                }
                
                // Category tab
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedTab = .category
                        selectedFolder = nil
                    }
                }) {
                    Image(systemName: "square.grid.2x2.fill")
                        .font(.system(size: 14))
                        .foregroundColor(selectedTab == .category ? .white : Color(white: 0.5))
                        .frame(maxWidth: .infinity)
                        .frame(height: 36)
                        .background(selectedTab == .category ? Color(white: 0.25) : Color(white: 0.12))
                        .cornerRadius(6)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(selectedTab == .category ? Color.white.opacity(0.3) : Color(white: 0.2), lineWidth: selectedTab == .category ? 1 : 0.5)
                        )
                }
            }
            .padding(.horizontal, 8)
            .padding(.top, 8)
            
            // Folders/Categories list
            ScrollView {
                VStack(spacing: 4) {
                    if selectedTab == .folder {
                        // All shaders option
                        folderRow(name: "All Shaders", icon: "square.grid.2x2.fill", count: nil, isSelected: selectedFolder == nil) {
                            selectedFolder = nil
                        }
                        
                        ForEach(folders) { folder in
                            folderRow(name: folder.name, icon: folder.iconName, count: folder.shaderCount, isSelected: selectedFolder?.id == folder.id) {
                                selectedFolder = folder
                            }
                        }
                    } else {
                        ForEach(ShaderCategory.allCases) { category in
                            categoryRow(category: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding(.horizontal, 8)
                .padding(.bottom, 8)
            }
        }
    }
    
    // MARK: - Folder Row
    
    private func folderRow(name: String, icon: String, count: Int?, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : Color(white: 0.5))
                    .frame(width: 20)
                
                Text(name)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? .white : Color(white: 0.7))
                    .lineLimit(1)
                
                Spacer()
                
                if let count = count {
                    Text("\(count)")
                        .font(.system(size: 11))
                        .foregroundColor(Color(white: 0.5))
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color(white: 0.15))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? Color(white: 0.2) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Category Row
    
    private func categoryRow(category: ShaderCategory, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 12))
                    .foregroundColor(isSelected ? .white : category.color)
                    .frame(width: 20)
                
                Text(category.rawValue)
                    .font(.system(size: 13))
                    .foregroundColor(isSelected ? .white : Color(white: 0.7))
                    .lineLimit(1)
                
                Spacer()
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 8)
            .background(isSelected ? Color(white: 0.2) : Color.clear)
            .cornerRadius(6)
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    // MARK: - Compact Function Buttons (left side)
    
    private var functionButtonsCompact: some View {
        VStack(spacing: 6) {
            // Row 1: Favorites, Add Shader
            HStack(spacing: 6) {
                compactButton(icon: "heart", color: Color(white: 0.5)) { }
                compactButton(icon: "plus", color: Color(white: 0.5)) {
                    showingNewShaderSheet = true
                }
            }
            
            // Row 2: Broadcast, Parameters
            HStack(spacing: 6) {
                compactButton(
                    icon: syncService.isAdvertising ? "antenna.radiowaves.left.and.right" : "antenna.radiowaves.left.and.right.slash",
                    color: syncService.isAdvertising ? .green : Color(white: 0.5),
                    isActive: syncService.isAdvertising
                ) {
                    if syncService.isAdvertising {
                        syncService.stop()
                    } else {
                        syncService.start()
                    }
                }
                
                compactButton(icon: "slider.horizontal.3", color: selectedShader != nil ? Color(white: 0.5) : Color(white: 0.3)) {
                    if selectedShader != nil {
                        showingParametersView = true
                    }
                }
            }
            
            // Row 3: Community toggle, Release Resources
            HStack(spacing: 6) {
                // Community toggle button
                Button(action: {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        showingCommunityShaders.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "globe")
                            .font(.system(size: 12))
                        if showingCommunityShaders {
                            Text("ON")
                                .font(.system(size: 8, weight: .bold))
                        }
                    }
                    .foregroundColor(showingCommunityShaders ? .white : .purple)
                    .frame(maxWidth: .infinity)
                    .frame(height: 36)
                    .background(showingCommunityShaders ? Color.purple.opacity(0.4) : Color.purple.opacity(0.15))
                    .cornerRadius(6)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(showingCommunityShaders ? Color.purple : Color.purple.opacity(0.4), lineWidth: showingCommunityShaders ? 1.5 : 0.5)
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // Release Resources button
                releaseResourcesButton
            }
        }
        .padding(8)
    }
    
    private func compactButton(icon: String, color: Color, isActive: Bool = false, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: icon)
                .font(.system(size: 14))
                .foregroundColor(color)
                .frame(maxWidth: .infinity)
                .frame(height: 36)
                .background(isActive ? color.opacity(0.2) : Color(white: 0.12))
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isActive ? color : Color(white: 0.2), lineWidth: isActive ? 1.5 : 0.5)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    private var emptySlot: some View {
        Rectangle()
            .fill(Color(white: 0.08))
            .frame(height: 36)
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(Color(white: 0.15), lineWidth: 0.5)
            )
    }
    
    // MARK: - Release Resources Button
    
    /// Sprawdza czy są aktywne zasoby do zwolnienia (lub automatyzacja nie jest zablokowana)
    private var hasActiveResources: Bool {
        // Jeśli automatyzacja jest zablokowana, przycisk jest nieaktywny (już zwolniono)
        if ResourceManager.shared.isAutomationBlocked {
            return false
        }
        
        let hasAutomation = automationManager?.isPlaying == true || automationManager?.hasAnyRecording == true
        let hasCachedPipelines = ResourceManager.shared.cachedPipelineCount > 0
        return hasAutomation || hasCachedPipelines
    }
    
    private var releaseResourcesButton: some View {
        Button(action: releaseResources) {
            HStack(spacing: 4) {
                Image(systemName: hasActiveResources ? "bolt.slash.fill" : "bolt.slash")
                    .font(.system(size: 12))
                if hasActiveResources {
                    Text("FREE")
                        .font(.system(size: 8, weight: .bold))
                }
            }
            .foregroundColor(hasActiveResources ? .orange : Color(white: 0.4))
            .frame(maxWidth: .infinity)
            .frame(height: 36)
            .background(hasActiveResources ? Color.orange.opacity(0.2) : Color(white: 0.08))
            .cornerRadius(6)
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(hasActiveResources ? Color.orange : Color(white: 0.15), lineWidth: hasActiveResources ? 1.5 : 0.5)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
    
    /// Zwalnia zasoby: czyści automatyzacje, cache GPU i resetuje parametry
    private func releaseResources() {
        // 1. WYCZYŚĆ automatyzacje (nie tylko zatrzymaj - usuń nagrania)
        automationManager?.clearAllTracks()
        
        // 2. Resetuj parametry do wartości domyślnych
        parametersVM?.resetToDefaults()
        
        // 3. Zwolnij zasoby GPU (pipeline cache, thumbnails, timer)
        ResourceManager.shared.releaseAllResources()
        
        // Haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
        
        print("🔋 All resources released: automation cleared, GPU cache cleared, parameters reset")
    }
    
    // MARK: - New Folder Sheet
    
    private var newFolderSheet: some View {
        NavigationStack {
            Form {
                Section("Folder Name") {
                    TextField("Enter folder name", text: $newFolderName)
                }
            }
            .navigationTitle("New Folder")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        newFolderName = ""
                        showingNewFolderSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        createFolder()
                    }
                    .disabled(newFolderName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
    
    private func createFolder() {
        let trimmedName = newFolderName.trimmingCharacters(in: .whitespaces)
        guard !trimmedName.isEmpty else { return }
        
        let folder = ShaderFolder(
            name: trimmedName,
            order: folders.count
        )
        modelContext.insert(folder)
        try? modelContext.save()
        
        // Sync to iCloud for cross-device sync
        ICloudFolderSync.shared.exportToiCloud(context: modelContext)
        
        newFolderName = ""
        showingNewFolderSheet = false
    }
}

#Preview {
    PortraitBottomPanel(
        selectedFolder: .constant(nil),
        selectedCategory: .constant(nil),
        showingNewShaderSheet: .constant(false),
        viewMode: .constant(.grid),
        showingParametersView: .constant(false),
        selectedShader: nil,
        syncService: ShaderSyncService(),
        showingCommunityShaders: .constant(false),
        automationManager: nil,
        parametersVM: nil
    )
    .frame(height: 140)
    .modelContainer(for: [ShaderFolder.self], inMemory: true)
}
