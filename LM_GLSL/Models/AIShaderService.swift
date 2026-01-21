//
//  AIShaderService.swift
//  LM_GLSL
//
//  Service for AI-powered shader code generation
//

import Foundation

// MARK: - AI Provider Enum

enum AIProvider: String, CaseIterable, Identifiable {
    case openAI = "OpenAI"
    case groq = "Groq"
    case gemini = "Google Gemini"
    case deepseek = "DeepSeek"
    case mistral = "Mistral AI"
    case together = "Together AI"
    case fireworks = "Fireworks AI"
    case ollama = "Ollama (Local)"
    
    var id: String { rawValue }
    
    var modelName: String {
        switch self {
        case .openAI: return "gpt-4o-mini"
        case .groq: return "llama-3.3-70b-versatile"
        case .gemini: return "gemini-2.0-flash-lite"
        case .deepseek: return "deepseek-chat"
        case .mistral: return "codestral-latest"
        case .together: return "meta-llama/Llama-3.3-70B-Instruct-Turbo"
        case .fireworks: return "accounts/fireworks/models/llama-v3p1-70b-instruct"
        case .ollama: return "codellama"
        }
    }
    
    var baseURL: String {
        switch self {
        case .openAI: return "https://api.openai.com/v1/chat/completions"
        case .groq: return "https://api.groq.com/openai/v1/chat/completions"
        case .gemini: return "https://generativelanguage.googleapis.com/v1beta/openai/chat/completions"
        case .deepseek: return "https://api.deepseek.com/chat/completions"
        case .mistral: return "https://api.mistral.ai/v1/chat/completions"
        case .together: return "https://api.together.xyz/v1/chat/completions"
        case .fireworks: return "https://api.fireworks.ai/inference/v1/chat/completions"
        case .ollama: return "http://localhost:11434/api/generate"
        }
    }
    
    var requiresAPIKey: Bool {
        switch self {
        case .openAI, .groq, .gemini, .deepseek, .mistral, .together, .fireworks: return true
        case .ollama: return false
        }
    }
    
    var apiKeyName: String {
        switch self {
        case .openAI: return "OPENAI_API_KEY"
        case .groq: return "GROQ_API_KEY"
        case .gemini: return "GEMINI_API_KEY"
        case .deepseek: return "DEEPSEEK_API_KEY"
        case .mistral: return "MISTRAL_API_KEY"
        case .together: return "TOGETHER_API_KEY"
        case .fireworks: return "FIREWORKS_API_KEY"
        case .ollama: return ""
        }
    }
}

// MARK: - Chat Message for Context

struct ChatMessage: Codable {
    let role: String  // "system", "user", "assistant"
    let content: String
}

// MARK: - AI Shader Service

@MainActor
class AIShaderService: ObservableObject {
    static let shared = AIShaderService()
    
    @Published var isGenerating = false
    @Published var errorMessage: String?
    @Published var conversationHistory: [ChatMessage] = []
    
    // Store API keys in UserDefaults (for demo - use Keychain in production!)
    private let userDefaults = UserDefaults.standard
    
    private let systemPrompt = """
    You are a Metal shader code generator. Generate ONLY the shader body code (no function declaration).
    
    Available variables:
    - uv: float2 - UV coordinates (0 to 1)
    - iTime: float - Time in seconds
    - iResolution: float2 - Resolution
    
    Available functions: sin, cos, tan, abs, floor, fract, mod, pow, sqrt, length, distance, dot, cross, normalize, mix, smoothstep, clamp, min, max
    
    PARAMETER SLIDERS:
    When user asks to add a slider/parameter for controlling a numeric value, use this format at the TOP of the shader:
    // @param variableName "Display Name" range(min, max) default(value)
    
    TOGGLE BUTTONS:
    When user asks for a toggle/switch/on-off control, use this format:
    // @toggle variableName "Display Name" default(true/false)
    
    Example parameters:
    // @param speed "Speed" range(0.0, 5.0) default(1.0)
    // @param intensity "Intensity" range(0.0, 2.0) default(1.0)
    // @toggle invert "Invert Colors" default(false)
    // @toggle animate "Animation" default(true)
    
    Using toggle in code (it's a float: 0.0 = off, 1.0 = on):
    float3 col = mix(originalColor, invertedColor, invert);
    // or with condition:
    if (animate > 0.5) { /* animated code */ }
    
    Rules:
    1. Return ONLY the shader code body, nothing else
    2. Must end with: return float4(col, 1.0); where col is float3
    3. Use Metal Shading Language syntax (float2, float3, float4)
    4. Keep code concise and efficient
    5. No markdown formatting, no code blocks
    6. When user asks to modify the shader, keep the existing logic and only change what they ask for
    7. When user asks for slider - use @param, for toggle/switch - use @toggle
    8. Parameter names should be short, lowercase, no spaces (e.g., speed, scale, invert)
    9. Display names can have spaces and be descriptive (e.g., "Zoom Speed", "Invert Colors")
    
    Example with both slider and toggle:
    // @param pulseSpeed "Pulse Speed" range(0.1, 5.0) default(1.0)
    // @toggle showRing "Show Ring" default(true)
    float2 p = uv * 2.0 - 1.0;
    float d = length(p);
    float pulse = sin(iTime * pulseSpeed) * 0.5 + 0.5;
    float circle = smoothstep(0.5 + pulse * 0.2, 0.48 + pulse * 0.2, d);
    float ring = smoothstep(0.48, 0.46, d) * smoothstep(0.3, 0.32, d);
    float shape = mix(circle, ring, showRing);
    float3 col = float3(shape) * float3(0.2, 0.6, 1.0);
    return float4(col, 1.0);
    """
    
    private init() {}
    
    // MARK: - Conversation Management
    
    /// Clear conversation history to start fresh
    func clearConversation() {
        conversationHistory.removeAll()
    }
    
    /// Initialize conversation with existing shader code as context
    /// This allows AI to modify the shader instead of creating from scratch
    func initializeWithShaderContext(_ shaderCode: String) {
        // Clear previous conversation
        conversationHistory.removeAll()
        
        // Add the current shader as assistant's previous response
        // This makes AI think it generated this shader and can now modify it
        let initialUserMessage = ChatMessage(
            role: "user",
            content: "Generate a Metal shader"
        )
        let shaderAsResponse = ChatMessage(
            role: "assistant",
            content: shaderCode
        )
        
        conversationHistory = [initialUserMessage, shaderAsResponse]
    }
    
    /// Check if we have an ongoing conversation
    var hasConversationContext: Bool {
        !conversationHistory.isEmpty
    }
    
    // MARK: - API Key Management
    
    func getAPIKey(for provider: AIProvider) -> String? {
        userDefaults.string(forKey: provider.apiKeyName)
    }
    
    func setAPIKey(_ key: String, for provider: AIProvider) {
        userDefaults.set(key, forKey: provider.apiKeyName)
    }
    
    // MARK: - Shader Generation
    
    /// Generate shader with conversation context
    /// - Parameters:
    ///   - prompt: User's request
    ///   - currentCode: Current shader code (for context when modifying)
    ///   - provider: AI provider to use
    /// - Returns: Generated shader code or nil on error
    func generateShader(prompt: String, currentCode: String? = nil, provider: AIProvider) async -> String? {
        isGenerating = true
        errorMessage = nil
        
        defer { isGenerating = false }
        
        // Check API key
        if provider.requiresAPIKey {
            guard let apiKey = getAPIKey(for: provider), !apiKey.isEmpty else {
                errorMessage = "Brak klucza API dla \(provider.rawValue). Ustaw go w ustawieniach."
                return nil
            }
        }
        
        // Build user message with context
        var userMessage = prompt
        if let code = currentCode, hasConversationContext {
            userMessage = "Current shader code:\n```\n\(code)\n```\n\nModification request: \(prompt)"
        } else if !hasConversationContext {
            userMessage = "Generate Metal shader code for: \(prompt)"
        }
        
        do {
            switch provider {
            case .ollama:
                let result = try await generateWithOllama(prompt: userMessage)
                if let code = result {
                    // Add to conversation history
                    conversationHistory.append(ChatMessage(role: "user", content: userMessage))
                    conversationHistory.append(ChatMessage(role: "assistant", content: code))
                }
                return result
            case .openAI, .groq, .gemini, .deepseek, .mistral, .together, .fireworks:
                let result = try await generateWithOpenAICompatible(prompt: userMessage, provider: provider)
                if let code = result {
                    // Add to conversation history
                    conversationHistory.append(ChatMessage(role: "user", content: userMessage))
                    conversationHistory.append(ChatMessage(role: "assistant", content: code))
                }
                return result
            }
        } catch {
            errorMessage = "Błąd: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - OpenAI Compatible API (OpenAI, Groq, Gemini, DeepSeek, Mistral, Together, Fireworks)
    
    private func generateWithOpenAICompatible(prompt: String, provider: AIProvider) async throws -> String? {
        guard let apiKey = getAPIKey(for: provider) else { return nil }
        guard let url = URL(string: provider.baseURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        // Build messages array with conversation history
        var messages: [[String: String]] = [
            ["role": "system", "content": systemPrompt]
        ]
        
        // Add conversation history
        for message in conversationHistory {
            messages.append(["role": message.role, "content": message.content])
        }
        
        // Add current prompt
        messages.append(["role": "user", "content": prompt])
        
        let body: [String: Any] = [
            "model": provider.modelName,
            "messages": messages,
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
                // OpenAI/Groq format: {"error": {"message": "..."}}
                if let error = errorJson["error"] as? [String: Any],
                   let message = error["message"] as? String {
                    throw AIServiceError.apiError(message)
                }
                // Google format might be different - log it
                print("API Error Response: \(errorJson)")
            }
            throw AIServiceError.httpError(httpResponse.statusCode)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any] else {
            // Debug: print raw response for troubleshooting
            if let rawString = String(data: data, encoding: .utf8) {
                print("AI Response Debug: \(rawString.prefix(500))")
            }
            throw AIServiceError.parseError
        }
        
        // Handle different content formats (standard string or array of parts for thinking models)
        let content: String
        if let textContent = message["content"] as? String {
            content = textContent
        } else if let contentParts = message["content"] as? [[String: Any]] {
            // For thinking models that return array of content parts
            content = contentParts.compactMap { part -> String? in
                if part["type"] as? String == "text" {
                    return part["text"] as? String
                }
                return nil
            }.joined(separator: "\n")
        } else {
            throw AIServiceError.parseError
        }
        
        return cleanShaderCode(content)
    }
    
    // MARK: - Ollama Local API
    
    private func generateWithOllama(prompt: String) async throws -> String? {
        guard let url = URL(string: AIProvider.ollama.baseURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120 // Ollama może być wolniejsze
        
        // Build context from conversation history
        var fullPrompt = systemPrompt + "\n\n"
        for message in conversationHistory {
            let roleLabel = message.role == "user" ? "User" : "Assistant"
            fullPrompt += "\(roleLabel): \(message.content)\n\n"
        }
        fullPrompt += "User: \(prompt)"
        
        let body: [String: Any] = [
            "model": AIProvider.ollama.modelName,
            "prompt": fullPrompt,
            "stream": false
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw AIServiceError.ollamaNotRunning
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let content = json["response"] as? String else {
            throw AIServiceError.parseError
        }
        
        return cleanShaderCode(content)
    }
    
    // MARK: - Helper
    
    private func cleanShaderCode(_ code: String) -> String {
        var cleaned = code
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present
        if cleaned.hasPrefix("```") {
            let lines = cleaned.components(separatedBy: "\n")
            let filteredLines = lines.filter { !$0.hasPrefix("```") }
            cleaned = filteredLines.joined(separator: "\n")
        }
        
        // Remove "metal" or "glsl" language identifier
        cleaned = cleaned
            .replacingOccurrences(of: "metal\n", with: "")
            .replacingOccurrences(of: "glsl\n", with: "")
            .trimmingCharacters(in: .whitespacesAndNewlines)
        
        return cleaned
    }
}

// MARK: - Errors

enum AIServiceError: LocalizedError {
    case invalidResponse
    case httpError(Int)
    case apiError(String)
    case parseError
    case ollamaNotRunning
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse:
            return "Nieprawidłowa odpowiedź z serwera"
        case .httpError(let code):
            return "Błąd HTTP: \(code)"
        case .apiError(let message):
            return message
        case .parseError:
            return "Nie udało się przetworzyć odpowiedzi"
        case .ollamaNotRunning:
            return "Ollama nie działa. Uruchom: 'ollama serve' w terminalu"
        }
    }
}
