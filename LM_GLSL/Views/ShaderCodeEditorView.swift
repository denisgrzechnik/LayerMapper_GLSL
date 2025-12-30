//
//  ShaderCodeEditorView.swift
//  LM_GLSL
//
//  Code editor for shader fragment code
//

import SwiftUI
import SwiftData

struct ShaderCodeEditorView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var shader: ShaderEntity
    let onSave: () -> Void
    
    @State private var editedCode: String = ""
    @State private var showingError: Bool = false
    @State private var errorMessage: String = ""
    @State private var hasChanges: Bool = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Toolbar
                HStack {
                    // Shader name
                    Text(shader.name)
                        .font(.headline)
                    
                    Spacer()
                    
                    // Syntax help
                    Menu {
                        Button("iTime - Time in seconds") {}
                        Button("uv - UV coordinates (0-1)") {}
                        Button("float2, float3, float4") {}
                        Button("sin, cos, tan") {}
                        Button("length, distance, dot") {}
                        Button("mix, smoothstep, clamp") {}
                        Button("fract, floor, mod") {}
                    } label: {
                        Image(systemName: "questionmark.circle")
                    }
                }
                .padding()
                .background(Color.black.opacity(0.3))
                
                // Code editor
                CodeEditorView(code: $editedCode)
                    .onChange(of: editedCode) { _, newValue in
                        hasChanges = newValue != shader.fragmentCode
                    }
                
                // Error display
                if showingError {
                    HStack {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundColor(.yellow)
                        
                        Text(errorMessage)
                            .font(.caption)
                            .foregroundColor(.yellow)
                        
                        Spacer()
                        
                        Button {
                            showingError = false
                        } label: {
                            Image(systemName: "xmark")
                        }
                    }
                    .padding()
                    .background(Color.yellow.opacity(0.2))
                }
                
                // Bottom toolbar
                HStack {
                    Button("Reset") {
                        editedCode = shader.fragmentCode
                        hasChanges = false
                    }
                    .disabled(!hasChanges)
                    
                    Spacer()
                    
                    Button("Validate") {
                        validateCode()
                    }
                    .buttonStyle(.bordered)
                    
                    Button("Save") {
                        saveCode()
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(!hasChanges)
                }
                .padding()
                .background(Color.black.opacity(0.3))
            }
            .background(Color(white: 0.15))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        if hasChanges {
                            saveCode()
                        }
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            editedCode = shader.fragmentCode
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Actions
    
    private func validateCode() {
        // Basic validation - check for common errors
        let code = editedCode
        
        // Check for return statement
        if !code.contains("return") {
            showError("Missing return statement. Shader must return float4.")
            return
        }
        
        // Check for float4 return
        if !code.contains("float4") {
            showError("Shader must return float4 for color output.")
            return
        }
        
        // Check balanced braces
        let openBraces = code.filter { $0 == "{" }.count
        let closeBraces = code.filter { $0 == "}" }.count
        if openBraces != closeBraces {
            showError("Unbalanced braces: \(openBraces) open, \(closeBraces) close")
            return
        }
        
        // Check balanced parentheses
        let openParens = code.filter { $0 == "(" }.count
        let closeParens = code.filter { $0 == ")" }.count
        if openParens != closeParens {
            showError("Unbalanced parentheses: \(openParens) open, \(closeParens) close")
            return
        }
        
        showingError = false
    }
    
    private func showError(_ message: String) {
        errorMessage = message
        showingError = true
    }
    
    private func saveCode() {
        validateCode()
        
        if !showingError {
            shader.fragmentCode = editedCode
            shader.updateModifiedDate()
            onSave()
            hasChanges = false
        }
    }
}

// MARK: - Code Editor View

struct CodeEditorView: View {
    @Binding var code: String
    
    var body: some View {
        ScrollView {
            HStack(alignment: .top, spacing: 0) {
                // Line numbers
                VStack(alignment: .trailing, spacing: 0) {
                    ForEach(1...max(1, code.components(separatedBy: "\n").count), id: \.self) { lineNumber in
                        Text("\(lineNumber)")
                            .font(.system(.caption, design: .monospaced))
                            .foregroundColor(.gray.opacity(0.6))
                            .frame(height: 20)
                    }
                }
                .padding(.horizontal, 8)
                .background(Color.black.opacity(0.3))
                
                // Code editor
                TextEditor(text: $code)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green)
                    .scrollContentBackground(.hidden)
                    .background(Color.clear)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .background(Color.black)
    }
}

#Preview {
    ShaderCodeEditorView(
        shader: ShaderEntity(name: "Test", fragmentCode: "float2 p = uv;\nreturn float4(p.x, p.y, 0.5, 1.0);"),
        onSave: {}
    )
    .modelContainer(for: ShaderEntity.self, inMemory: true)
}
