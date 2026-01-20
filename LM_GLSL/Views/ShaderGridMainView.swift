//
//  ShaderGridMainView.swift
//  LM_GLSL
//
//  Grid view displaying shaders in a larger grid layout
//

import SwiftUI
import SwiftData

struct ShaderGridMainView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    @Query(sort: \ShaderFolder.order) private var folders: [ShaderFolder]
    
    let shaders: [ShaderEntity]
    @Binding var selectedShader: ShaderEntity?
    @Binding var showingParametersView: Bool
    @Binding var viewMode: ViewMode
    
    // Filtering by folder or category
    var selectedFolder: ShaderFolder?
    var selectedCategory: ShaderCategory?
    
    // Community shaders mode
    @Binding var showingCommunityShaders: Bool
    
    // Community shaders state
    @State private var communityShaders: [SharedShaderInfo] = []
    @State private var isLoadingCommunity: Bool = false
    @State private var communityError: String?
    
    // Detect orientation
    @State private var isLandscape: Bool = UIDevice.current.orientation.isLandscape
    
    // Grid columns based on orientation: 6 for landscape, 4 for portrait
    private var columns: [GridItem] {
        let count = isLandscape ? 6 : 4
        return Array(repeating: GridItem(.flexible(), spacing: 8), count: count)
    }
    
    private var filteredShaders: [ShaderEntity] {
        var result = shaders
        
        // Filter by folder if selected
        if let folder = selectedFolder {
            result = result.filter { folder.containsShader($0.id) }
        }
        
        // Filter by category if selected
        if let category = selectedCategory, category != .all {
            result = result.filter { $0.category == category }
        }
        
        return result
    }
    
    var body: some View {
        GeometryReader { geometry in
            let isCurrentlyLandscape = geometry.size.width > geometry.size.height
            
            VStack(spacing: 0) {
                if showingCommunityShaders {
                    // Community shaders view
                    communityGridContent
                } else {
                    // User's local shaders view
                    userShadersGridContent
                }
            }
            .background(Color.black)
            .gesture(
                DragGesture(minimumDistance: 50, coordinateSpace: .local)
                    .onEnded { value in
                        // Swipe right to switch to Preview view (only in landscape)
                        if value.translation.width > 100 && abs(value.translation.height) < abs(value.translation.width) {
                            withAnimation(.easeInOut(duration: 0.3)) {
                                viewMode = .preview
                            }
                        }
                    }
            )
            .onAppear {
                isLandscape = isCurrentlyLandscape
            }
            .onChange(of: isCurrentlyLandscape) { _, newValue in
                isLandscape = newValue
            }
            .onChange(of: showingCommunityShaders) { _, newValue in
                if newValue {
                    loadCommunityShaders()
                }
            }
        }
    }
    
    // MARK: - User Shaders Grid
    
    private var userShadersGridContent: some View {
        Group {
            if filteredShaders.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "square.grid.3x3.slash")
                        .font(.system(size: 48))
                        .foregroundColor(Color(white: 0.3))
                    
                    Text("No shaders in this selection")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.4))
                    
                    Text("Select a different folder or category")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(filteredShaders) { shader in
                            GridShaderItem(
                                shader: shader,
                                folders: folders,
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
                                },
                                onAddToFolder: { folder in
                                    folder.addShader(shader.id)
                                    try? modelContext.save()
                                    // Export to App Groups for MApp sync
                                    SharedFolderSyncService.shared.exportFolders(folders: folders, shaders: shaders)
                                    // Sync to iCloud
                                    ICloudFolderSync.shared.exportToiCloud(context: modelContext)
                                    
                                    // If adding to "Public" folder, publish to CloudKit
                                    if folder.name.lowercased() == "public" {
                                        publishShaderToCommunity(shader)
                                    }
                                },
                                onRemoveFromFolder: { folder in
                                    folder.removeShader(shader.id)
                                    try? modelContext.save()
                                    // Export to App Groups for MApp sync
                                    SharedFolderSyncService.shared.exportFolders(folders: folders, shaders: shaders)
                                    // Sync to iCloud
                                    ICloudFolderSync.shared.exportToiCloud(context: modelContext)
                                }
                            )
                        }
                    }
                    .padding(8)
                }
            }
        }
    }
    
    // MARK: - Community Shaders Grid
    
    private var communityGridContent: some View {
        Group {
            if isLoadingCommunity {
                VStack(spacing: 12) {
                    ProgressView()
                        .scaleEffect(1.5)
                    Text("Loading community shaders...")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.5))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if let error = communityError {
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 48))
                        .foregroundColor(.orange)
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Color(white: 0.5))
                        .multilineTextAlignment(.center)
                    Button("Retry") {
                        loadCommunityShaders()
                    }
                    .buttonStyle(.bordered)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if communityShaders.isEmpty {
                VStack(spacing: 12) {
                    Image(systemName: "globe")
                        .font(.system(size: 48))
                        .foregroundColor(Color(white: 0.3))
                    Text("No community shaders yet")
                        .font(.headline)
                        .foregroundColor(Color(white: 0.4))
                    Text("Be the first to share!")
                        .font(.caption)
                        .foregroundColor(Color(white: 0.3))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 8) {
                        ForEach(communityShaders) { shaderInfo in
                            CommunityShaderItem(
                                shaderInfo: shaderInfo,
                                onDownload: { downloadCommunityShader(shaderInfo) }
                            )
                        }
                    }
                    .padding(8)
                }
            }
        }
    }
    
    // MARK: - Community Functions
    
    private func loadCommunityShaders() {
        isLoadingCommunity = true
        communityError = nil
        
        Task {
            do {
                let shaders = try await CloudKitShaderService.shared.fetchPublicShadersArray()
                await MainActor.run {
                    self.communityShaders = shaders
                    self.isLoadingCommunity = false
                }
            } catch {
                await MainActor.run {
                    self.communityError = "Failed to load: \(error.localizedDescription)"
                    self.isLoadingCommunity = false
                }
            }
        }
    }
    
    private func downloadCommunityShader(_ shaderInfo: SharedShaderInfo) {
        Task {
            do {
                let newShader = try await CloudKitShaderService.shared.downloadShaderAsEntity(shaderInfo)
                await MainActor.run {
                    modelContext.insert(newShader)
                    try? modelContext.save()
                    selectedShader = newShader
                    showingCommunityShaders = false
                }
            } catch {
                print("Failed to download shader: \(error)")
            }
        }
    }
    
    private func publishShaderToCommunity(_ shader: ShaderEntity) {
        Task {
            do {
                try await CloudKitShaderService.shared.publishShaderEntity(shader, authorName: "User")
                print("Shader published to community: \(shader.name)")
            } catch {
                print("Failed to publish shader: \(error)")
            }
        }
    }
}

// MARK: - Grid Shader Item

struct GridShaderItem: View {
    let shader: ShaderEntity
    let folders: [ShaderFolder]
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    let onParameters: () -> Void
    let onAddToFolder: (ShaderFolder) -> Void
    let onRemoveFromFolder: (ShaderFolder) -> Void
    
    @State private var showingFolderMenu: Bool = false
    @State private var showingPublishSheet: Bool = false
    
    var body: some View {
        VStack(spacing: 4) {
            // Animated shader thumbnail
            ShaderThumbnailView(shaderCode: shader.fragmentCode)
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .cornerRadius(6)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? Color.white : Color.clear, lineWidth: 2)
                )
                .shadow(color: isSelected ? .white.opacity(0.3) : .clear, radius: 6)
            
            // Buttons row: Heart, Parameters, Folder
            HStack(spacing: 3) {
                // Favorite button (heart)
                Button(action: onToggleFavorite) {
                    Image(systemName: shader.isFavorite ? "heart.fill" : "heart")
                        .font(.system(size: 9))
                        .foregroundColor(shader.isFavorite ? .red : Color(white: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color(white: 0.15))
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Parameters button
                Button(action: onParameters) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.system(size: 9))
                        .foregroundColor(Color(white: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color(white: 0.15))
                        .cornerRadius(4)
                }
                .buttonStyle(PlainButtonStyle())
                
                // Folder button with menu
                Menu {
                    ForEach(folders) { folder in
                        let isInFolder = folder.containsShader(shader.id)
                        Button(action: {
                            if isInFolder {
                                onRemoveFromFolder(folder)
                            } else {
                                onAddToFolder(folder)
                            }
                        }) {
                            Label(
                                folder.name,
                                systemImage: isInFolder ? "checkmark.circle.fill" : "circle"
                            )
                        }
                    }
                    
                    if folders.isEmpty {
                        Text("No folders")
                            .foregroundColor(.gray)
                    }
                } label: {
                    Image(systemName: folderIconForShader)
                        .font(.system(size: 9))
                        .foregroundColor(shaderIsInAnyFolder ? .blue : Color(white: 0.5))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                        .background(Color(white: 0.15))
                        .cornerRadius(4)
                }
            }
        }
        .padding(4)
        .background(isSelected ? Color(white: 0.18) : Color(white: 0.1))
        .cornerRadius(8)
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            Button(action: onToggleFavorite) {
                Label(shader.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                      systemImage: shader.isFavorite ? "heart.slash" : "heart")
            }
            
            Button(action: onParameters) {
                Label("Parameters", systemImage: "slider.horizontal.3")
            }
            
            Divider()
            
            Button(action: { showingPublishSheet = true }) {
                Label("Share to Community", systemImage: "globe")
            }
        }
        .sheet(isPresented: $showingPublishSheet) {
            PublishShaderView(shader: shader)
        }
    }
    
    private var shaderIsInAnyFolder: Bool {
        folders.contains { $0.containsShader(shader.id) }
    }
    
    private var folderIconForShader: String {
        shaderIsInAnyFolder ? "folder.fill" : "folder"
    }
}

#Preview {
    ShaderGridMainView(
        shaders: [],
        selectedShader: .constant(nil),
        showingParametersView: .constant(false),
        viewMode: .constant(.grid),
        showingCommunityShaders: .constant(false)
    )
    .modelContainer(for: [ShaderEntity.self, ShaderFolder.self], inMemory: true)
}

// MARK: - Community Shader Item

struct CommunityShaderItem: View {
    let shaderInfo: SharedShaderInfo
    let onDownload: () -> Void
    
    @State private var isDownloading = false
    
    var body: some View {
        VStack(spacing: 4) {
            // Shader thumbnail (using code preview)
            ShaderThumbnailView(shaderCode: shaderInfo.fragmentCode)
                .aspectRatio(1, contentMode: .fit)
                .clipped()
                .cornerRadius(6)
                .overlay(
                    // Community badge
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "globe")
                                .font(.system(size: 8))
                                .foregroundColor(.white)
                                .padding(4)
                                .background(Color.purple.opacity(0.8))
                                .cornerRadius(4)
                        }
                        Spacer()
                    }
                    .padding(4)
                )
            
            // Info row
            HStack(spacing: 4) {
                // Author
                Text(shaderInfo.authorName)
                    .font(.system(size: 7))
                    .foregroundColor(Color(white: 0.5))
                    .lineLimit(1)
                
                Spacer()
                
                // Likes
                HStack(spacing: 2) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 6))
                    Text("\(shaderInfo.likes)")
                        .font(.system(size: 7))
                }
                .foregroundColor(.red.opacity(0.7))
            }
            .padding(.horizontal, 2)
            
            // Download button
            Button(action: {
                isDownloading = true
                onDownload()
            }) {
                HStack(spacing: 4) {
                    if isDownloading {
                        ProgressView()
                            .scaleEffect(0.5)
                    } else {
                        Image(systemName: "arrow.down.circle")
                            .font(.system(size: 9))
                    }
                    Text("Download")
                        .font(.system(size: 8))
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
                .background(Color.purple.opacity(0.6))
                .cornerRadius(4)
            }
            .buttonStyle(PlainButtonStyle())
            .disabled(isDownloading)
        }
        .padding(4)
        .background(Color(white: 0.1))
        .cornerRadius(8)
    }
}
