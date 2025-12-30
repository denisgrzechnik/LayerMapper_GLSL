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
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left side - Shader Preview (80%)
                ShaderPreviewView(shader: selectedShader)
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
                            showingNewShaderSheet: $showingNewShaderSheet
                        )
                    }
                }
                .frame(width: geometry.size.width * 0.2)
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
        .onAppear {
            // Select first shader if none selected
            if selectedShader == nil {
                selectedShader = allShaders.first
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [ShaderEntity.self, ShaderParameterEntity.self], inMemory: true)
}
