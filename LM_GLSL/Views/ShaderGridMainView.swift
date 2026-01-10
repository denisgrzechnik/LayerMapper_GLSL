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
    
    // Filtering by folder or category
    var selectedFolder: ShaderFolder?
    var selectedCategory: ShaderCategory?
    
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
                // Shader grid (no header)
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
                                    },
                                    onRemoveFromFolder: { folder in
                                        folder.removeShader(shader.id)
                                        try? modelContext.save()
                                    }
                                )
                            }
                        }
                        .padding(8)
                    }
                }
            }
            .background(Color.black)
            .onAppear {
                isLandscape = isCurrentlyLandscape
            }
            .onChange(of: isCurrentlyLandscape) { _, newValue in
                isLandscape = newValue
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
        showingParametersView: .constant(false)
    )
    .modelContainer(for: [ShaderEntity.self, ShaderFolder.self], inMemory: true)
}
