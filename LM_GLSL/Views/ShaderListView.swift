//
//  ShaderListView.swift
//  LM_GLSL
//
//  List of available shaders - matching LayerMapperLaser style
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
    
    @State private var showingFavorites: Bool = false
    
    // Filtered shaders based on favorites
    private var displayedShaders: [ShaderEntity] {
        if showingFavorites {
            return shaders.filter { $0.isFavorite }
        }
        return shaders
    }
    
    var body: some View {
        VStack(spacing: 8) {
            // Header with title, favorites button and + Custom button
            HStack {
                Text("GLSL SHADERS")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Favorites toggle button
                Button(action: {
                    showingFavorites.toggle()
                }) {
                    Image(systemName: showingFavorites ? "heart.fill" : "heart")
                        .font(.caption)
                        .foregroundColor(showingFavorites ? .black : Color(white: 0.5))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(showingFavorites ? Color.white.opacity(0.9) : Color.clear)
                        .cornerRadius(4)
                }
                
                // Add Custom button
                Button(action: { showingNewShaderSheet = true }) {
                    HStack(spacing: 4) {
                        Image(systemName: "plus")
                            .font(.caption)
                        Text("Custom")
                            .font(.caption2)
                    }
                    .foregroundColor(Color(white: 0.6))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color(white: 0.15))
                    .cornerRadius(4)
                }
            }
            .padding(.horizontal, 12)
            .padding(.top, 12)
            
            // Shader list
            ScrollView {
                VStack(spacing: 6) {
                    if showingFavorites && displayedShaders.isEmpty {
                        // No favorites message
                        VStack(spacing: 8) {
                            Image(systemName: "heart.slash")
                                .font(.title)
                                .foregroundColor(Color(white: 0.3))
                            Text("No favorites yet")
                                .font(.caption)
                                .foregroundColor(Color(white: 0.4))
                            Text("Tap ♡ on any shader to add")
                                .font(.caption2)
                                .foregroundColor(Color(white: 0.3))
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
                        ForEach(displayedShaders) { shader in
                            ShaderPresetRow(
                                shader: shader,
                                isSelected: selectedShader?.id == shader.id,
                                onSelect: {
                                    selectedShader = shader
                                    shader.incrementViewCount()
                                },
                                onToggleFavorite: {
                                    shader.isFavorite.toggle()
                                    try? modelContext.save()
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .background(Color(white: 0.05))
    }
}

// MARK: - Shader Preset Row (matching MediaSourcePickerView style)

struct ShaderPresetRow: View {
    let shader: ShaderEntity
    let isSelected: Bool
    let onSelect: () -> Void
    let onToggleFavorite: () -> Void
    
    var body: some View {
        HStack(spacing: 10) {
            // Thumbnail square
            Rectangle()
                .fill(Color(hex: shader.thumbnailColorHex)?.opacity(0.3) ?? Color(white: 0.2))
                .frame(width: 28, height: 28)
            
            // Shader name
            Text(shader.name)
                .font(.caption)
                .foregroundColor(isSelected ? Color.white : Color(white: 0.6))
                .lineLimit(1)
            
            Spacer()
            
            // Favorite button (heart)
            Button(action: {
                onToggleFavorite()
            }) {
                Image(systemName: shader.isFavorite ? "heart.fill" : "heart")
                    .font(.caption)
                    .foregroundColor(shader.isFavorite ? .white : Color(white: 0.4))
            }
            .buttonStyle(PlainButtonStyle())
        }
        .padding(6)
        .background(isSelected ? Color(white: 0.15) : Color(white: 0.08))
        .onTapGesture {
            onSelect()
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
