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
    @StateObject private var parametersVM = ShaderParametersViewModel()
    
    let onCreate: (ShaderEntity) -> Void
    
    @State private var name: String = ""
    @State private var category: ShaderCategory = .custom
    @State private var description: String = ""
    @State private var code: String = defaultShaderCode
    
    // AI Generation
    @State private var aiPrompt: String = ""
    @State private var selectedProvider: AIProvider = .groq
    @State private var showAPIKeySheet = false
    
    static let defaultShaderCode = """
    // Your shader code here
    float3 col = float3(uv.x, uv.y, 0.5);
    return float4(col, 1.0);
    """
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Preview section - full width with only horizontal margins
                    MetalShaderView(
                        shaderCode: code,
                        isPlaying: .constant(true),
                        currentTime: .constant(0),
                        parameters: parametersVM.parameters
                    )
                    .frame(height: 200)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    
                    // Parameter controls (sliders and toggles)
                    if !parametersVM.parameters.isEmpty {
                        VStack(spacing: 1) {
                            ForEach($parametersVM.parameters) { $param in
                                ParameterControlRow(parameter: $param)
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                    }
                    
                    // Form sections
                    VStack(spacing: 16) {
                        // AI Generation Section
                        FormSection(title: "AI Shader Generator", icon: "sparkles", contextActive: aiService.hasConversationContext) {
                            VStack(alignment: .leading, spacing: 12) {
                                // Provider picker + conversation status
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
                                    
                                    // Conversation indicator
                                    if aiService.hasConversationContext {
                                        Button {
                                            aiService.clearConversation()
                                        } label: {
                                            HStack(spacing: 4) {
                                                Image(systemName: "bubble.left.and.bubble.right.fill")
                                                    .font(.caption)
                                                Text("\(aiService.conversationHistory.count / 2)")
                                                    .font(.caption)
                                                Image(systemName: "xmark.circle.fill")
                                                    .font(.caption)
                                            }
                                            .foregroundColor(.blue)
                                        }
                                    }
                                    
                                    if selectedProvider.requiresAPIKey {
                                        Button {
                                            showAPIKeySheet = true
                                        } label: {
                                            Image(systemName: hasAPIKey ? "key.fill" : "key")
                                                .foregroundColor(hasAPIKey ? .green : .orange)
                                        }
                                    }
                                }
                                
                                // Prompt input with context hint
                                TextField(promptPlaceholder, text: $aiPrompt, axis: .vertical)
                                    .lineLimit(2...4)
                                    .padding(8)
                                    .background(Color.black.opacity(0.2))
                                
                                // Generate button
                                HStack(spacing: 10) {
                                    Button {
                                        generateWithAI()
                                    } label: {
                                        HStack {
                                            if aiService.isGenerating {
                                                ProgressView()
                                                    .scaleEffect(0.8)
                                                    .tint(.white)
                                            } else {
                                                Image(systemName: aiService.hasConversationContext ? "arrow.triangle.2.circlepath" : "sparkles")
                                            }
                                            Text(generateButtonText)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 10)
                                        .background(Color(red: 254/255, green: 20/255, blue: 77/255))
                                        .foregroundColor(.white)
                                    }
                                    .disabled(aiPrompt.isEmpty || aiService.isGenerating || (selectedProvider.requiresAPIKey && !hasAPIKey))
                                    .opacity((aiPrompt.isEmpty || aiService.isGenerating || (selectedProvider.requiresAPIKey && !hasAPIKey)) ? 0.5 : 1)
                                    
                                    // New conversation button (only show when there's context)
                                    if aiService.hasConversationContext {
                                        Button {
                                            aiService.clearConversation()
                                            code = Self.defaultShaderCode
                                        } label: {
                                            Image(systemName: "plus.circle")
                                                .padding(.vertical, 10)
                                                .padding(.horizontal, 12)
                                                .background(Color.gray.opacity(0.3))
                                        }
                                    }
                                }
                                
                                // Error message
                                if let error = aiService.errorMessage {
                                    Text(error)
                                        .font(.caption)
                                        .foregroundColor(.red)
                                }
                                
                                // Footer
                                Text(aiFooterText)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        // Code section
                        FormSection(title: "Shader Code", icon: "chevron.left.forwardslash.chevron.right") {
                            TextEditor(text: $code)
                                .font(.system(.body, design: .monospaced))
                                .frame(minHeight: 200)
                                .scrollContentBackground(.hidden)
                                .background(Color.black.opacity(0.2))
                        }
                        
                        // Shader Info section
                        FormSection(title: "Shader Info", icon: "info.circle") {
                            VStack(spacing: 12) {
                                HStack {
                                    Text("Name")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                TextField("Shader name", text: $name)
                                    .padding(8)
                                    .background(Color.black.opacity(0.2))
                                
                                HStack {
                                    Text("Category")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Picker("", selection: $category) {
                                        ForEach(ShaderCategory.allCases.filter { $0 != .all }) { cat in
                                            Label(cat.rawValue, systemImage: cat.icon)
                                                .tag(cat)
                                        }
                                    }
                                    .pickerStyle(.menu)
                                }
                                
                                HStack {
                                    Text("Description")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                TextField("Optional description", text: $description, axis: .vertical)
                                    .lineLimit(2...4)
                                    .padding(8)
                                    .background(Color.black.opacity(0.2))
                            }
                        }
                        
                        // Help section
                        FormSection(title: "Variables & Parameters", icon: "questionmark.circle") {
                            VStack(alignment: .leading, spacing: 12) {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Built-in Variables")
                                        .font(.caption.bold())
                                        .foregroundColor(.secondary)
                                    HelpRow(variable: "uv", description: "UV coordinates (0 to 1)")
                                    HelpRow(variable: "iTime", description: "Time in seconds")
                                }
                                
                                Divider()
                                
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("Custom Slider Parameters")
                                        .font(.caption.bold())
                                        .foregroundColor(.secondary)
                                    Text("Ask AI to add sliders, e.g.:")
                                        .font(.caption)
                                        .foregroundColor(.gray)
                                    Text("\"dodaj slider do kontroli prędkości\"")
                                        .font(.caption.italic())
                                        .foregroundColor(.gray)
                                    Text("\"add slider for zoom scale\"")
                                        .font(.caption.italic())
                                        .foregroundColor(.gray)
                                }
                            }
                            .font(.caption)
                        }
                    }
                    .padding(.horizontal, 10)
                    .padding(.top, 16)
                    .padding(.bottom, 30)
                }
            }
            .background(Color(UIColor.systemBackground))
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
        if aiService.hasConversationContext {
            return "💬 Kontekst aktywny - możesz modyfikować shader słowami jak 'wolniej', 'zmień kolor na czerwony' itp."
        }
        switch selectedProvider {
        case .openAI:
            return "GPT-4o-mini: ~$0.15/1M tokenów. Wymaga klucza API z platform.openai.com"
        case .groq:
            return "Darmowe 6000 req/dzień. Zarejestruj się na console.groq.com"
        case .ollama:
            return "Lokalnie na Mac. Zainstaluj: brew install ollama && ollama pull codellama"
        }
    }
    
    private var promptPlaceholder: String {
        if aiService.hasConversationContext {
            return "Modyfikuj: 'wolniej', 'zmień kolor', 'dodaj blur'..."
        }
        return "Opisz shader, np. 'kolorowa spirala z neonowym efektem'"
    }
    
    private var generateButtonText: String {
        if aiService.isGenerating {
            return "Generuję..."
        }
        return aiService.hasConversationContext ? "Modyfikuj" : "Generuj z AI"
    }
    
    // MARK: - AI Generation
    
    private func generateWithAI() {
        let promptForName = aiPrompt // Save before clearing
        Task {
            // Pass current code for context when modifying
            let currentCode = aiService.hasConversationContext ? code : nil
            if let generatedCode = await aiService.generateShader(prompt: aiPrompt, currentCode: currentCode, provider: selectedProvider) {
                code = generatedCode
                
                // Update parameters from new code
                parametersVM.updateFromCode(generatedCode)
                
                // Auto-fill name if empty (only on first generation)
                if name.isEmpty && !aiService.hasConversationContext {
                    let trimmed = promptForName.prefix(30).trimmingCharacters(in: .whitespaces)
                    name = trimmed + (promptForName.count > 30 ? "..." : "")
                }
                
                aiPrompt = "" // Clear prompt after successful generation
            }
        }
    }
    
    private func createShader() {
        // Clear conversation when creating shader
        aiService.clearConversation()
        
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

// MARK: - Parameter Control Row (Slider or Toggle)

struct ParameterControlRow: View {
    @Binding var parameter: ShaderParameter
    
    var body: some View {
        Group {
            switch parameter.type {
            case .slider:
                ParameterSliderRow(parameter: $parameter)
            case .toggle:
                ParameterToggleRow(parameter: $parameter)
            }
        }
    }
}

// MARK: - Parameter Slider Row

struct ParameterSliderRow: View {
    @Binding var parameter: ShaderParameter
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(parameter.displayName)
                    .font(.caption)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.2f", parameter.currentValue))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.gray)
            }
            
            Slider(
                value: $parameter.currentValue,
                in: parameter.minValue...parameter.maxValue
            )
            .tint(Color(red: 254/255, green: 20/255, blue: 77/255))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }
}

// MARK: - Parameter Toggle Row

struct ParameterToggleRow: View {
    @Binding var parameter: ShaderParameter
    
    var body: some View {
        HStack {
            Text(parameter.displayName)
                .font(.caption)
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { parameter.currentValue > 0.5 },
                set: { parameter.currentValue = $0 ? 1.0 : 0.0 }
            ))
            .tint(Color(red: 254/255, green: 20/255, blue: 77/255))
            .labelsHidden()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
    }
}

// MARK: - Custom Form Section (Sharp Corners)

struct FormSection<Content: View>: View {
    let title: String
    let icon: String
    var contextActive: Bool = false
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Label(title, systemImage: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
                
                if contextActive {
                    Text("• Kontekst aktywny")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            .padding(.horizontal, 12)
            .padding(.bottom, 8)
            
            // Content with sharp corners
            VStack(alignment: .leading, spacing: 0) {
                content
                    .padding(12)
            }
            .background(Color(UIColor.secondarySystemBackground))
        }
    }
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
