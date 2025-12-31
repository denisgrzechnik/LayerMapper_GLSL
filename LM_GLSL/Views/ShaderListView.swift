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
            
            // 6 empty slots - 2 rows x 3 columns
            LazyVGrid(columns: slotColumns, spacing: 6) {
                ForEach(0..<6, id: \.self) { _ in
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
                                    isCustomizing = true
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
            // Animated shader thumbnail
            ShaderThumbnailView(shaderCode: shader.fragmentCode)
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

// MARK: - Shader Thumbnail View (small animated preview)

struct ShaderThumbnailView: View {
    let shaderCode: String
    
    @State private var isPlaying: Bool = true
    @State private var currentTime: Double = 0
    
    var body: some View {
        MetalShaderView(
            shaderCode: shaderCode,
            isPlaying: $isPlaying,
            currentTime: $currentTime
        )
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
