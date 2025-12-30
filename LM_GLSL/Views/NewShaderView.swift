//
//  NewShaderView.swift
//  LM_GLSL
//
//  View for creating new shaders
//

import SwiftUI
import SwiftData

struct NewShaderView: View {
    @Environment(\.dismiss) private var dismiss
    
    let onCreate: (ShaderEntity) -> Void
    
    @State private var name: String = ""
    @State private var category: ShaderCategory = .custom
    @State private var description: String = ""
    @State private var code: String = defaultShaderCode
    @State private var selectedTemplate: ShaderTemplate = .blank
    
    enum ShaderTemplate: String, CaseIterable {
        case blank = "Blank"
        case gradient = "Gradient"
        case circle = "Circle"
        case waves = "Waves"
        case noise = "Noise"
        
        var code: String {
            switch self {
            case .blank:
                return "// Your shader code here\nfloat3 col = float3(uv.x, uv.y, 0.5);\nreturn float4(col, 1.0);"
            case .gradient:
                return "float3 col = mix(float3(0.2, 0.4, 0.8), float3(0.8, 0.2, 0.4), uv.y);\nreturn float4(col, 1.0);"
            case .circle:
                return "float2 p = uv * 2.0 - 1.0;\nfloat d = length(p);\nfloat circle = smoothstep(0.5, 0.48, d);\nfloat3 col = float3(circle) * float3(0.2, 0.6, 1.0);\nreturn float4(col, 1.0);"
            case .waves:
                return "float2 p = uv;\nfloat wave = sin(p.x * 10.0 + iTime * 2.0) * 0.1;\nfloat d = abs(p.y - 0.5 - wave);\nfloat line = smoothstep(0.02, 0.0, d);\nfloat3 col = float3(line) * float3(0.0, 1.0, 0.5);\nreturn float4(col, 1.0);"
            case .noise:
                return "float2 p = uv * 10.0;\nfloat n = fract(sin(dot(floor(p), float2(12.9898, 78.233))) * 43758.5453);\nfloat3 col = float3(n);\nreturn float4(col, 1.0);"
            }
        }
    }
    
    static let defaultShaderCode = """
    // Your shader code here
    float3 col = float3(uv.x, uv.y, 0.5);
    return float4(col, 1.0);
    """
    
    var body: some View {
        NavigationStack {
            Form {
                // Basic info section
                Section("Shader Info") {
                    TextField("Name", text: $name)
                    
                    Picker("Category", selection: $category) {
                        ForEach(ShaderCategory.allCases.filter { $0 != .all }) { cat in
                            Label(cat.rawValue, systemImage: cat.icon)
                                .tag(cat)
                        }
                    }
                    
                    TextField("Description (optional)", text: $description, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                // Template section
                Section("Start From Template") {
                    Picker("Template", selection: $selectedTemplate) {
                        ForEach(ShaderTemplate.allCases, id: \.self) { template in
                            Text(template.rawValue).tag(template)
                        }
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: selectedTemplate) { _, newValue in
                        code = newValue.code
                    }
                }
                
                // Code section
                Section("Shader Code") {
                    TextEditor(text: $code)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 200)
                        .scrollContentBackground(.hidden)
                        .background(Color.black.opacity(0.1))
                        .cornerRadius(8)
                }
                
                // Preview section
                Section("Preview") {
                    MetalShaderView(
                        shaderCode: code,
                        isPlaying: .constant(true),
                        currentTime: .constant(0)
                    )
                    .frame(height: 200)
                    .cornerRadius(12)
                }
                
                // Help section
                Section("Available Variables") {
                    VStack(alignment: .leading, spacing: 8) {
                        HelpRow(variable: "uv", description: "UV coordinates (0 to 1)")
                        HelpRow(variable: "iTime", description: "Time in seconds")
                        HelpRow(variable: "float2, float3, float4", description: "Vector types")
                    }
                    .font(.caption)
                }
            }
            .navigationTitle("New Shader")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Create") {
                        createShader()
                    }
                    .disabled(name.isEmpty)
                    .fontWeight(.semibold)
                }
            }
        }
        .preferredColorScheme(.dark)
    }
    
    private func createShader() {
        let shader = ShaderEntity(
            name: name,
            fragmentCode: code,
            category: category,
            author: "User",
            isBuiltIn: false,
            shaderDescription: description
        )
        
        onCreate(shader)
        dismiss()
    }
}

struct HelpRow: View {
    let variable: String
    let description: String
    
    var body: some View {
        HStack {
            Text(variable)
                .font(.system(.caption, design: .monospaced))
                .foregroundColor(.blue)
            
            Text("–")
                .foregroundColor(.gray)
            
            Text(description)
                .foregroundColor(.gray)
        }
    }
}

#Preview {
    NewShaderView { _ in }
}
