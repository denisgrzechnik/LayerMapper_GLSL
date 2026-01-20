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
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShaderFolder.order) private var allFolders: [ShaderFolder]
    @StateObject private var aiService = AIShaderService.shared
    @StateObject private var parametersVM = ShaderParametersViewModel()
    
    let onCreate: (ShaderEntity) -> Void
    
    @State private var name: String = ""
    @State private var category: ShaderCategory = .custom
    @State private var description: String = ""
    @State private var code: String = defaultShaderCode
    @State private var selectedFolders: Set<UUID> = []
    @State private var showFolderPicker = false
    
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
                        parametersVM: parametersVM
                    )
                    .frame(height: 200)
                    .padding(.horizontal, 10)
                    .padding(.top, 10)
                    
                    // Parameter controls (sliders and toggles)
                    if !parametersVM.parameters.isEmpty {
                        VStack(spacing: 1) {
                            ForEach(parametersVM.parameters) { param in
                                ParameterControlRow(
                                    parameter: param,
                                    onUpdate: { newValue in
                                        parametersVM.updateParameter(id: param.id, value: newValue)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, 10)
                        .padding(.top, 8)
                    }
                    
                    // Form sections
                    VStack(spacing: 16) {
                        // AI Generation Section
                        FormSection(title: "AI Shader Generator", icon: "sparkles") {
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
                                
                                HStack(alignment: .top) {
                                    Text("Folders")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Button {
                                        showFolderPicker = true
                                    } label: {
                                        HStack {
                                            if selectedFolders.isEmpty {
                                                Text("None")
                                                    .foregroundColor(.secondary)
                                            } else {
                                                Text("\(selectedFolders.count) selected")
                                                    .foregroundColor(.primary)
                                            }
                                            Image(systemName: "chevron.up.chevron.down")
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                
                                // Display selected folders
                                if !selectedFolders.isEmpty {
                                    VStack(alignment: .leading, spacing: 4) {
                                        ForEach(allFolders.filter { selectedFolders.contains($0.id) }) { folder in
                                            HStack(spacing: 6) {
                                                Image(systemName: folder.iconName)
                                                    .font(.caption)
                                                    .foregroundColor(Color(hex: folder.colorHex))
                                                Text(folder.name)
                                                    .font(.caption)
                                                    .foregroundColor(.secondary)
                                            }
                                        }
                                    }
                                    .padding(8)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(Color.black.opacity(0.2))
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
                                    Text("\"add slider for speed control\"")
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
            .sheet(isPresented: $showFolderPicker) {
                FolderPickerSheet(selectedFolders: $selectedFolders)
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
            return "GPT-4o-mini: ~$0.15/1M tokens. Requires API key from platform.openai.com"
        case .groq:
            return "Free 6000 req/day. Sign up at console.groq.com"
        case .ollama:
            return "Local on Mac. Install: brew install ollama && ollama pull codellama"
        }
    }
    
    private var promptPlaceholder: String {
        if aiService.hasConversationContext {
            return "Modify: 'slower', 'change color', 'add blur'..."
        }
        return "Describe shader, e.g. 'colorful spiral with neon effect'"
    }
    
    private var generateButtonText: String {
        if aiService.isGenerating {
            return "Generating..."
        }
        return aiService.hasConversationContext ? "Modify" : "Generate with AI"
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
        
        // Add shader to selected folders
        if !selectedFolders.isEmpty {
            for folder in allFolders where selectedFolders.contains(folder.id) {
                folder.addShader(shader.id)
            }
            // Sync folders to iCloud after adding shader
            ICloudFolderSync.shared.exportToiCloud(context: modelContext)
        }
        
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
// OPTYMALIZACJA: NIE używa @Binding!

struct ParameterControlRow: View {
    let parameter: ShaderParameter  // NIE @Binding!
    var onUpdate: ((Float) -> Void)? = nil
    
    var body: some View {
        Group {
            switch parameter.type {
            case .slider:
                ParameterSliderRow(parameter: parameter, onUpdate: onUpdate)
            case .toggle:
                ParameterToggleRow(parameter: parameter, onUpdate: onUpdate)
            }
        }
    }
}

// MARK: - Parameter Slider Row (Optimized)

struct ParameterSliderRow: View {
    let parameter: ShaderParameter  // NIE @Binding!
    var onUpdate: ((Float) -> Void)? = nil
    
    @State private var value: Float = 0
    
    var body: some View {
        VStack(spacing: 4) {
            HStack {
                Text(parameter.displayName)
                    .font(.caption)
                    .foregroundColor(.white)
                
                Spacer()
                
                Text(String(format: "%.2f", value))
                    .font(.system(.caption, design: .monospaced))
                    .foregroundColor(.gray)
            }
            
            Slider(
                value: Binding(
                    get: { value },
                    set: { newValue in
                        value = newValue
                        onUpdate?(newValue)
                    }
                ),
                in: parameter.minValue...parameter.maxValue
            )
            .tint(Color(red: 254/255, green: 20/255, blue: 77/255))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear {
            value = parameter.currentValue
        }
    }
}

// MARK: - Parameter Toggle Row (Optimized)

struct ParameterToggleRow: View {
    let parameter: ShaderParameter  // NIE @Binding!
    var onUpdate: ((Float) -> Void)? = nil
    
    @State private var isOn: Bool = false
    
    var body: some View {
        HStack {
            Text(parameter.displayName)
                .font(.caption)
                .foregroundColor(.white)
            
            Spacer()
            
            Toggle("", isOn: Binding(
                get: { isOn },
                set: { newValue in
                    isOn = newValue
                    onUpdate?(newValue ? 1.0 : 0.0)
                }
            ))
            .tint(Color(red: 254/255, green: 20/255, blue: 77/255))
            .labelsHidden()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(Color(UIColor.secondarySystemBackground))
        .onAppear {
            isOn = parameter.currentValue > 0.5
        }
    }
}

// MARK: - Custom Form Section (Sharp Corners)

struct FormSection<Content: View>: View {
    let title: String
    let icon: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack {
                Label(title, systemImage: icon)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .textCase(.uppercase)
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
                    Text("API Key for \(provider.rawValue)")
                } footer: {
                    Text(footerText)
                }
                
                Section {
                    Link(destination: providerURL) {
                        HStack {
                            Text("Get API Key")
                            Spacer()
                            Image(systemName: "arrow.up.right.square")
                        }
                    }
                }
            }
            .navigationTitle("API Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
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
            return "You can find it at platform.openai.com/api-keys"
        case .groq:
            return "You can find it at console.groq.com/keys"
        case .ollama:
            return "Ollama doesn't require an API key"
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

// MARK: - Folder Picker Sheet

struct FolderPickerSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \ShaderFolder.order) private var folders: [ShaderFolder]
    
    @Binding var selectedFolders: Set<UUID>
    
    var body: some View {
        NavigationStack {
            List {
                // User folders
                ForEach(folders) { folder in
                    Button {
                        toggleFolder(folder.id)
                    } label: {
                        HStack {
                            Image(systemName: folder.iconName)
                                .foregroundColor(Color(hex: folder.colorHex))
                            Text(folder.name)
                                .foregroundColor(.primary)
                            Spacer()
                            if selectedFolders.contains(folder.id) {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Folders")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Clear All") {
                        selectedFolders.removeAll()
                    }
                    .disabled(selectedFolders.isEmpty)
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .preferredColorScheme(.dark)
    }
    
    private func toggleFolder(_ folderId: UUID) {
        if selectedFolders.contains(folderId) {
            selectedFolders.remove(folderId)
        } else {
            selectedFolders.insert(folderId)
        }
    }
}
