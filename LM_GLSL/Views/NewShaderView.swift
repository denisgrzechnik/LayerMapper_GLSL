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
    @StateObject private var aiService = AIShaderService.shared
    
    let onCreate: (ShaderEntity) -> Void
    
    @State private var name: String = ""
    @State private var category: ShaderCategory = .custom
    @State private var description: String = ""
    @State private var code: String = defaultShaderCode
    @State private var selectedTemplate: ShaderTemplate = .blank
    
    // AI Generation
    @State private var aiPrompt: String = ""
    @State private var selectedProvider: AIProvider = .openAI
    @State private var showAPIKeySheet = false
    
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
                
                // AI Generation Section
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        // Provider picker
                        HStack {
                            Text("Provider:")
                                .foregroundColor(.secondary)
                            Picker("", selection: $selectedProvider) {
                                ForEach(AIProvider.allCases) { provider in
                                    Text(provider.rawValue).tag(provider)
                                }
                            }
                            .pickerStyle(.menu)
                            
                            Spacer()
                            
                            if selectedProvider.requiresAPIKey {
                                Button {
                                    showAPIKeySheet = true
                                } label: {
                                    Image(systemName: hasAPIKey ? "key.fill" : "key")
                                        .foregroundColor(hasAPIKey ? .green : .orange)
                                }
                            }
                        }
                        
                        // Prompt input
                        TextField("Opisz shader, np. 'kolorowa spirala z neonowym efektem'", text: $aiPrompt, axis: .vertical)
                            .lineLimit(2...4)
                            .textFieldStyle(.roundedBorder)
                        
                        // Generate button
                        Button {
                            generateWithAI()
                        } label: {
                            HStack {
                                if aiService.isGenerating {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                        .tint(.white)
                                } else {
                                    Image(systemName: "sparkles")
                                }
                                Text(aiService.isGenerating ? "Generuję..." : "Generuj z AI")
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(Color(red: 254/255, green: 20/255, blue: 77/255)) // #FE144D
                        .disabled(aiPrompt.isEmpty || aiService.isGenerating || (selectedProvider.requiresAPIKey && !hasAPIKey))
                        
                        // Error message
                        if let error = aiService.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(.red)
                        }
                    }
                } header: {
                    Label("AI Shader Generator", systemImage: "sparkles")
                } footer: {
                    Text(aiFooterText)
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
            .sheet(isPresented: $showAPIKeySheet) {
                APIKeySettingsSheet(provider: selectedProvider)
            }
        }
        .preferredColorScheme(.dark)
    }
    
    // MARK: - Computed Properties
    
    private var hasAPIKey: Bool {
        guard let key = aiService.getAPIKey(for: selectedProvider) else { return false }
        return !key.isEmpty
    }
    
    private var aiFooterText: String {
        switch selectedProvider {
        case .openAI:
            return "GPT-4o-mini: ~$0.15/1M tokenów. Wymaga klucza API z platform.openai.com"
        case .groq:
            return "Darmowe 6000 req/dzień. Zarejestruj się na console.groq.com"
        case .ollama:
            return "Lokalnie na Mac. Zainstaluj: brew install ollama && ollama pull codellama"
        }
    }
    
    // MARK: - AI Generation
    
    private func generateWithAI() {
        Task {
            if let generatedCode = await aiService.generateShader(prompt: aiPrompt, provider: selectedProvider) {
                code = generatedCode
                selectedTemplate = .blank // Reset template selection
                
                // Auto-fill name if empty
                if name.isEmpty {
                    name = aiPrompt.prefix(30).trimmingCharacters(in: .whitespaces)
                    if aiPrompt.count > 30 {
                        name += "..."
                    }
                }
            }
        }
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

// MARK: - API Key Settings Sheet

struct APIKeySettingsSheet: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var aiService = AIShaderService.shared
    
    let provider: AIProvider
    
    @State private var apiKey: String = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    SecureField("API Key", text: $apiKey)
                        .textContentType(.password)
                        .autocorrectionDisabled()
                } header: {
                    Text("Klucz API dla \(provider.rawValue)")
                } footer: {
                    Text(footerText)
                }
                
                Section {
                    Link(destination: providerURL) {
                        HStack {
                            Text("Uzyskaj klucz API")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
            }
            .navigationTitle("Ustawienia API")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Anuluj") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Zapisz") {
                        aiService.setAPIKey(apiKey, for: provider)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                apiKey = aiService.getAPIKey(for: provider) ?? ""
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }
    
    private var footerText: String {
        switch provider {
        case .openAI:
            return "Znajdziesz go na platform.openai.com/api-keys"
        case .groq:
            return "Znajdziesz go na console.groq.com/keys"
        case .ollama:
            return "Ollama nie wymaga klucza API"
        }
    }
    
    private var providerURL: URL {
        switch provider {
        case .openAI:
            return URL(string: "https://platform.openai.com/api-keys")!
        case .groq:
            return URL(string: "https://console.groq.com/keys")!
        case .ollama:
            return URL(string: "https://ollama.ai")!
        }
    }
}
