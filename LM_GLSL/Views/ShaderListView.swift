//
//  ShaderListView.swift
//  LM_GLSL
//
//  List of available shaders with category filtering (SwiftData version)
//

import SwiftUI
import SwiftData

struct ShaderListView: View {
    @Environment(\.modelContext) private var modelContext
    
    let shaders: [ShaderEntity]
    @Binding var selectedShader: ShaderEntity?
    @Binding var selectedCategory: ShaderCategory
    @Binding var searchText: String
    @Binding var isCustomizing: Bool
    @Binding var showingNewShaderSheet: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                HStack {
                    Text("Shaders")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("(\(shaders.count))")
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Button {
                        showingNewShaderSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundColor(.blue)
                    }
                }
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Search", text: $searchText)
                        .textFieldStyle(.plain)
                        .foregroundColor(.white)
                    
                    if !searchText.isEmpty {
                        Button {
                            searchText = ""
                        } label: {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(8)
                .background(Color.white.opacity(0.1))
                .cornerRadius(8)
                
                // Category filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(ShaderCategory.allCases) { category in
                            CategoryChip(
                                category: category,
                                isSelected: selectedCategory == category
                            ) {
                                selectedCategory = category
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            // Shader list
            if shaders.isEmpty {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text("No shaders found")
                        .foregroundColor(.gray)
                    
                    if !searchText.isEmpty {
                        Button("Clear Search") {
                            searchText = ""
                        }
                        .buttonStyle(.bordered)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(shaders) { shader in
                            ShaderListItem(
                                shader: shader,
                                isSelected: selectedShader?.id == shader.id,
                                onSelect: {
                                    selectedShader = shader
                                    shader.incrementViewCount()
                                },
                                onCustomize: {
                                    selectedShader = shader
                                    isCustomizing = true
                                },
                                onToggleFavorite: {
                                    shader.isFavorite.toggle()
                                    try? modelContext.save()
                                },
                                onDuplicate: {
                                    duplicateShader(shader)
                                },
                                onDelete: {
                                    deleteShader(shader)
                                }
                            )
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color(white: 0.1))
    }
    
    // MARK: - Actions
    
    private func duplicateShader(_ shader: ShaderEntity) {
        let duplicate = ShaderEntity(
            name: "\(shader.name) Copy",
            fragmentCode: shader.fragmentCode,
            vertexCode: shader.vertexCode,
            category: shader.category,
            tags: shader.tags,
            author: "User",
            isBuiltIn: false,
            shaderDescription: shader.shaderDescription,
            thumbnailColorHex: shader.thumbnailColorHex
        )
        
        modelContext.insert(duplicate)
        try? modelContext.save()
        selectedShader = duplicate
    }
    
    private func deleteShader(_ shader: ShaderEntity) {
        guard !shader.isBuiltIn else { return }
        
        if selectedShader?.id == shader.id {
            selectedShader = nil
        }
        
        modelContext.delete(shader)
        try? modelContext.save()
    }
}

// MARK: - Category Chip

struct CategoryChip: View {
    let category: ShaderCategory
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                Image(systemName: category.icon)
                    .font(.caption)
                
                if isSelected || category == .all {
                    Text(category.rawValue)
                        .font(.caption)
                }
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(isSelected ? category.color : Color.white.opacity(0.1))
            .foregroundColor(isSelected ? .white : .gray)
            .cornerRadius(16)
        }
    }
}

// MARK: - Shader List Item

struct ShaderListItem: View {
    let shader: ShaderEntity
    let isSelected: Bool
    let onSelect: () -> Void
    let onCustomize: () -> Void
    let onToggleFavorite: () -> Void
    let onDuplicate: () -> Void
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Thumbnail
            RoundedRectangle(cornerRadius: 8)
                .fill(Color(hex: shader.thumbnailColorHex) ?? .gray)
                .frame(width: 50, height: 50)
                .overlay(
                    Image(systemName: shader.category.icon)
                        .foregroundColor(.white.opacity(0.5))
                )
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(shader.name)
                        .font(.subheadline.weight(.medium))
                        .foregroundColor(.white)
                        .lineLimit(1)
                    
                    if shader.isFavorite {
                        Image(systemName: "heart.fill")
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    if !shader.isBuiltIn {
                        Image(systemName: "pencil.circle.fill")
                            .font(.caption)
                            .foregroundColor(.orange)
                    }
                }
                
                HStack(spacing: 8) {
                    Text(shader.category.rawValue)
                        .font(.caption)
                        .foregroundColor(.gray)
                    
                    if shader.viewCount > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "eye")
                            Text("\(shader.viewCount)")
                        }
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.7))
                    }
                }
            }
            
            Spacer()
            
            // Customize button
            Button {
                onCustomize()
            } label: {
                Image(systemName: "slider.horizontal.3")
                    .foregroundColor(.blue)
            }
        }
        .padding(10)
        .background(isSelected ? Color.blue.opacity(0.3) : Color.white.opacity(0.05))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
        .onTapGesture {
            onSelect()
        }
        .contextMenu {
            Button {
                onToggleFavorite()
            } label: {
                Label(
                    shader.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                    systemImage: shader.isFavorite ? "heart.slash" : "heart"
                )
            }
            
            Button {
                onDuplicate()
            } label: {
                Label("Duplicate", systemImage: "doc.on.doc")
            }
            
            Button {
                onCustomize()
            } label: {
                Label("Customize", systemImage: "slider.horizontal.3")
            }
            
            if !shader.isBuiltIn {
                Divider()
                
                Button(role: .destructive) {
                    onDelete()
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
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
        showingNewShaderSheet: .constant(false)
    )
    .modelContainer(for: ShaderEntity.self, inMemory: true)
}
