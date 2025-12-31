//
//  ShaderCustomizeView.swift
//  LM_GLSL
//
//  Panel for customizing shader parameters
//

import SwiftUI
import SwiftData

struct ShaderCustomizeView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var shader: ShaderEntity
    @Binding var isCustomizing: Bool
    @Binding var showingCodeEditor: Bool
    
    @State private var editedCode: String = ""
    @State private var showingSaveAlert: Bool = false
    @State private var showingFullParameters: Bool = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Button {
                    isCustomizing = false
                } label: {
                    Image(systemName: "chevron.left")
                    Text("Back")
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("Customize")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Spacer()
                
                // Placeholder for alignment
                Text("Back")
                    .opacity(0)
            }
            .padding()
            .background(Color.black.opacity(0.3))
            
            ScrollView {
                VStack(spacing: 20) {
                    // Shader info section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Shader Info")
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        VStack(spacing: 8) {
                            InfoEditRow(label: "Name", value: $shader.name)
                            
                            HStack {
                                Text("Category")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Spacer()
                                
                                Picker("", selection: Binding(
                                    get: { shader.category },
                                    set: { shader.categoryRawValue = $0.rawValue }
                                )) {
                                    ForEach(ShaderCategory.allCases.filter { $0 != .all }) { category in
                                        Text(category.rawValue).tag(category)
                                    }
                                }
                                .pickerStyle(.menu)
                                .tint(.blue)
                            }
                            
                            InfoEditRow(label: "Author", value: $shader.author)
                            InfoEditRow(label: "Description", value: $shader.shaderDescription, isMultiline: true)
                        }
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(12)
                    }
                    
                    // Parameters section
                    if let parameters = shader.parameters, !parameters.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            HStack {
                                Text("Parameters")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                
                                Spacer()
                                
                                Button {
                                    showingFullParameters = true
                                } label: {
                                    Label("Full View", systemImage: "arrow.up.left.and.arrow.down.right")
                                        .font(.caption)
                                }
                                .buttonStyle(.bordered)
                                .tint(Color(hex: "FE144D"))
                            }
                            
                            VStack(spacing: 12) {
                                ForEach(parameters) { param in
                                    ParameterSlider(parameter: param)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.05))
                            .cornerRadius(12)
                        }
                    }
                    
                    // Code section
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Text("Shader Code")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Spacer()
                            
                            Button {
                                showingCodeEditor = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                                    .font(.caption)
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        // Code preview
                        ScrollView(.horizontal, showsIndicators: false) {
                            Text(shader.fragmentCode)
                                .font(.system(.caption, design: .monospaced))
                                .foregroundColor(.green)
                                .padding()
                        }
                        .frame(height: 150)
                        .background(Color.black)
                        .cornerRadius(8)
                    }
                    
                    // Actions section
                    VStack(spacing: 12) {
                        // Favorite toggle
                        Button {
                            shader.isFavorite.toggle()
                            try? modelContext.save()
                        } label: {
                            HStack {
                                Image(systemName: shader.isFavorite ? "heart.fill" : "heart")
                                Text(shader.isFavorite ? "Remove from Favorites" : "Add to Favorites")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        .tint(shader.isFavorite ? .red : .gray)
                        
                        // Duplicate button
                        Button {
                            duplicateShader()
                        } label: {
                            HStack {
                                Image(systemName: "doc.on.doc")
                                Text("Duplicate Shader")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        // Export button
                        Button {
                            exportShader()
                        } label: {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("Export Shader")
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(.bordered)
                        
                        // Delete button (only for custom shaders)
                        if !shader.isBuiltIn {
                            Button(role: .destructive) {
                                showingSaveAlert = true
                            } label: {
                                HStack {
                                    Image(systemName: "trash")
                                    Text("Delete Shader")
                                }
                                .frame(maxWidth: .infinity)
                            }
                            .buttonStyle(.bordered)
                            .tint(.red)
                        }
                    }
                }
                .padding()
            }
        }
        .background(Color(white: 0.1))
        .alert("Delete Shader", isPresented: $showingSaveAlert) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteShader()
            }
        } message: {
            Text("Are you sure you want to delete this shader? This action cannot be undone.")
        }
        .fullScreenCover(isPresented: $showingFullParameters) {
            ShaderParametersView(shader: shader)
        }
    }
    
    // MARK: - Actions
    
    private func duplicateShader() {
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
    }
    
    private func deleteShader() {
        modelContext.delete(shader)
        try? modelContext.save()
        isCustomizing = false
    }
    
    private func exportShader() {
        // Export functionality - could use ShareSheet
        let exportData = """
        {
            "name": "\(shader.name)",
            "category": "\(shader.category.rawValue)",
            "author": "\(shader.author)",
            "code": "\(shader.fragmentCode.replacingOccurrences(of: "\"", with: "\\\"").replacingOccurrences(of: "\n", with: "\\n"))"
        }
        """
        
        UIPasteboard.general.string = exportData
    }
}

// MARK: - Info Edit Row

struct InfoEditRow: View {
    let label: String
    @Binding var value: String
    var isMultiline: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            
            if isMultiline {
                TextEditor(text: $value)
                    .font(.body)
                    .frame(height: 80)
                    .scrollContentBackground(.hidden)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
            } else {
                TextField(label, text: $value)
                    .textFieldStyle(.plain)
                    .padding(8)
                    .background(Color.white.opacity(0.1))
                    .cornerRadius(6)
            }
        }
    }
}

// MARK: - Parameter Slider

struct ParameterSlider: View {
    @Bindable var parameter: ShaderParameterEntity
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(parameter.displayName)
                    .font(.subheadline)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.2f", parameter.floatValue))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 12) {
                Text(String(format: "%.1f", parameter.minValue))
                    .font(.caption2)
                    .foregroundColor(.gray)
                
                Slider(
                    value: $parameter.floatValue,
                    in: parameter.minValue...parameter.maxValue,
                    step: parameter.step
                )
                .tint(.blue)
                
                Text(String(format: "%.1f", parameter.maxValue))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            
            // Reset button
            Button {
                parameter.floatValue = parameter.defaultValue
            } label: {
                Text("Reset to default")
                    .font(.caption)
            }
            .buttonStyle(.plain)
            .foregroundColor(.blue)
        }
    }
}

#Preview {
    ShaderCustomizeView(
        shader: ShaderEntity(name: "Test", fragmentCode: "return float4(1.0);"),
        isCustomizing: .constant(true),
        showingCodeEditor: .constant(false)
    )
    .modelContainer(for: ShaderEntity.self, inMemory: true)
}
