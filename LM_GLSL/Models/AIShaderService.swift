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
    case ollama = "Ollama (Local)"
    
    var id: String { rawValue }
    
    var modelName: String {
        switch self {
        case .openAI: return "gpt-4o-mini"
        case .groq: return "llama-3.3-70b-versatile"
        case .ollama: return "codellama"
        }
    }
    
    var baseURL: String {
        switch self {
        case .openAI: return "https://api.openai.com/v1/chat/completions"
        case .groq: return "https://api.groq.com/openai/v1/chat/completions"
        case .ollama: return "http://localhost:11434/api/generate"
        }
    }
    
    var requiresAPIKey: Bool {
        switch self {
        case .openAI, .groq: return true
        case .ollama: return false
        }
    }
    
    var apiKeyName: String {
        switch self {
        case .openAI: return "OPENAI_API_KEY"
        case .groq: return "GROQ_API_KEY"
        case .ollama: return ""
        }
    }
}

// MARK: - AI Shader Service

@MainActor
class AIShaderService: ObservableObject {
    static let shared = AIShaderService()
    
    @Published var isGenerating = false
    @Published var errorMessage: String?
    
    // Store API keys in UserDefaults (for demo - use Keychain in production!)
    private let userDefaults = UserDefaults.standard
    
    private init() {}
    
    // MARK: - API Key Management
    
    func getAPIKey(for provider: AIProvider) -> String? {
        userDefaults.string(forKey: provider.apiKeyName)
    }
    
    func setAPIKey(_ key: String, for provider: AIProvider) {
        userDefaults.set(key, forKey: provider.apiKeyName)
    }
    
    // MARK: - Shader Generation
    
    func generateShader(prompt: String, provider: AIProvider) async -> String? {
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
        
        let systemPrompt = """
        You are a Metal shader code generator. Generate ONLY the shader body code (no function declaration).
        
        Available variables:
        - uv: float2 - UV coordinates (0 to 1)
        - iTime: float - Time in seconds
        - iResolution: float2 - Resolution
        
        Available functions: sin, cos, tan, abs, floor, fract, mod, pow, sqrt, length, distance, dot, cross, normalize, mix, smoothstep, clamp, min, max
        
        Rules:
        1. Return ONLY the shader code body, nothing else
        2. Must end with: return float4(col, 1.0); where col is float3
        3. Use Metal Shading Language syntax (float2, float3, float4)
        4. Keep code concise and efficient
        5. No comments unless essential
        6. No markdown formatting, no code blocks
        
        Example output for "blue gradient":
        float3 col = mix(float3(0.0, 0.0, 0.2), float3(0.0, 0.5, 1.0), uv.y);
        return float4(col, 1.0);
        """
        
        do {
            switch provider {
            case .ollama:
                return try await generateWithOllama(prompt: prompt, systemPrompt: systemPrompt)
            case .openAI, .groq:
                return try await generateWithOpenAICompatible(prompt: prompt, systemPrompt: systemPrompt, provider: provider)
            }
        } catch {
            errorMessage = "Błąd: \(error.localizedDescription)"
            return nil
        }
    }
    
    // MARK: - OpenAI Compatible API (OpenAI, Groq)
    
    private func generateWithOpenAICompatible(prompt: String, systemPrompt: String, provider: AIProvider) async throws -> String? {
        guard let apiKey = getAPIKey(for: provider) else { return nil }
        guard let url = URL(string: provider.baseURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.timeoutInterval = 60
        
        let body: [String: Any] = [
            "model": provider.modelName,
            "messages": [
                ["role": "system", "content": systemPrompt],
                ["role": "user", "content": "Generate Metal shader code for: \(prompt)"]
            ],
            "max_tokens": 1000,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIServiceError.invalidResponse
        }
        
        if httpResponse.statusCode != 200 {
            if let errorJson = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let error = errorJson["error"] as? [String: Any],
               let message = error["message"] as? String {
                throw AIServiceError.apiError(message)
            }
            throw AIServiceError.httpError(httpResponse.statusCode)
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw AIServiceError.parseError
        }
        
        return cleanShaderCode(content)
    }
    
    // MARK: - Ollama Local API
    
    private func generateWithOllama(prompt: String, systemPrompt: String) async throws -> String? {
        guard let url = URL(string: AIProvider.ollama.baseURL) else { return nil }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 120 // Ollama może być wolniejsze
        
        let body: [String: Any] = [
            "model": AIProvider.ollama.modelName,
            "prompt": "\(systemPrompt)\n\nUser request: \(prompt)",
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
