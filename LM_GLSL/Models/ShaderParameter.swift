//
//  ShaderParameter.swift
//  LM_GLSL
//
//  Model for shader parameters that can be controlled via sliders and toggles
//

import Foundation
import SwiftUI

// MARK: - Parameter Type

enum ShaderParameterType: String, Codable {
    case slider
    case toggle
}

// MARK: - Shader Parameter Model

struct ShaderParameter: Identifiable, Equatable, Codable {
    let id: UUID
    let name: String           // Variable name in shader (e.g., "speed")
    let displayName: String    // User-friendly name (e.g., "Prędkość")
    let type: ShaderParameterType
    let minValue: Float
    let maxValue: Float
    let defaultValue: Float
    var currentValue: Float
    
    // Slider initializer
    init(name: String, displayName: String, minValue: Float = 0.0, maxValue: Float = 1.0, defaultValue: Float = 0.5) {
        self.id = UUID()
        self.name = name
        self.displayName = displayName
        self.type = .slider
        self.minValue = minValue
        self.maxValue = maxValue
        self.defaultValue = defaultValue
        self.currentValue = defaultValue
    }
    
    // Toggle initializer
    init(name: String, displayName: String, defaultOn: Bool) {
        self.id = UUID()
        self.name = name
        self.displayName = displayName
        self.type = .toggle
        self.minValue = 0.0
        self.maxValue = 1.0
        self.defaultValue = defaultOn ? 1.0 : 0.0
        self.currentValue = defaultOn ? 1.0 : 0.0
    }
    
    var isOn: Bool {
        get { currentValue > 0.5 }
        set { currentValue = newValue ? 1.0 : 0.0 }
    }
    
    static func == (lhs: ShaderParameter, rhs: ShaderParameter) -> Bool {
        lhs.id == rhs.id && lhs.currentValue == rhs.currentValue
    }
}

// MARK: - Parameter Parser

class ShaderParameterParser {
    
    /// Parse shader code and extract parameter definitions
    /// Slider format: // @param variableName "Display Name" range(min, max) default(value)
    /// Toggle format: // @toggle variableName "Display Name" default(true/false)
    static func parseParameters(from code: String) -> [ShaderParameter] {
        var parameters: [ShaderParameter] = []
        
        let lines = code.components(separatedBy: "\n")
        
        // Regex pattern for slider: // @param name "displayName" range(min, max) default(value)
        let sliderPattern = #"//\s*@param\s+(\w+)\s+"([^"]+)"\s+range\(([^,]+),\s*([^)]+)\)\s+default\(([^)]+)\)"#
        
        // Regex pattern for toggle: // @toggle name "displayName" default(true/false/0/1)
        let togglePattern = #"//\s*@toggle\s+(\w+)\s+"([^"]+)"\s+default\(([^)]+)\)"#
        
        let sliderRegex = try? NSRegularExpression(pattern: sliderPattern, options: [])
        let toggleRegex = try? NSRegularExpression(pattern: togglePattern, options: [])
        
        for line in lines {
            let range = NSRange(line.startIndex..., in: line)
            
            // Try slider pattern
            if let regex = sliderRegex,
               let match = regex.firstMatch(in: line, options: [], range: range) {
                if let nameRange = Range(match.range(at: 1), in: line),
                   let displayRange = Range(match.range(at: 2), in: line),
                   let minRange = Range(match.range(at: 3), in: line),
                   let maxRange = Range(match.range(at: 4), in: line),
                   let defaultRange = Range(match.range(at: 5), in: line) {
                    
                    let name = String(line[nameRange])
                    let displayName = String(line[displayRange])
                    let minValue = Float(line[minRange].trimmingCharacters(in: .whitespaces)) ?? 0.0
                    let maxValue = Float(line[maxRange].trimmingCharacters(in: .whitespaces)) ?? 1.0
                    let defaultValue = Float(line[defaultRange].trimmingCharacters(in: .whitespaces)) ?? 0.5
                    
                    let param = ShaderParameter(
                        name: name,
                        displayName: displayName,
                        minValue: minValue,
                        maxValue: maxValue,
                        defaultValue: defaultValue
                    )
                    parameters.append(param)
                }
            }
            
            // Try toggle pattern
            if let regex = toggleRegex,
               let match = regex.firstMatch(in: line, options: [], range: range) {
                if let nameRange = Range(match.range(at: 1), in: line),
                   let displayRange = Range(match.range(at: 2), in: line),
                   let defaultRange = Range(match.range(at: 3), in: line) {
                    
                    let name = String(line[nameRange])
                    let displayName = String(line[displayRange])
                    let defaultStr = String(line[defaultRange]).trimmingCharacters(in: .whitespaces).lowercased()
                    let defaultOn = defaultStr == "true" || defaultStr == "1"
                    
                    let param = ShaderParameter(
                        name: name,
                        displayName: displayName,
                        defaultOn: defaultOn
                    )
                    parameters.append(param)
                }
            }
        }
        
        return parameters
    }
    
    /// Generate Metal uniform declarations from parameters
    static func generateUniformStruct(from parameters: [ShaderParameter]) -> String {
        guard !parameters.isEmpty else { return "" }
        
        var uniforms = "struct ShaderParams {\n"
        for param in parameters {
            uniforms += "    float \(param.name);\n"
        }
        uniforms += "};\n"
        
        return uniforms
    }
    
    /// Check if code has any parameters defined
    static func hasParameters(_ code: String) -> Bool {
        return code.contains("@param") || code.contains("@toggle")
    }
}

// MARK: - Parameters View Model

@MainActor
class ShaderParametersViewModel: ObservableObject {
    @Published var parameters: [ShaderParameter] = []
    
    func updateFromCode(_ code: String) {
        let newParams = ShaderParameterParser.parseParameters(from: code)
        
        // Preserve current values for existing parameters
        var updatedParams: [ShaderParameter] = []
        for newParam in newParams {
            if let existing = parameters.first(where: { $0.name == newParam.name }) {
                var updated = newParam
                updated.currentValue = existing.currentValue
                updatedParams.append(updated)
            } else {
                updatedParams.append(newParam)
            }
        }
        
        parameters = updatedParams
    }
    
    func resetToDefaults() {
        parameters = parameters.map { param in
            var updated = param
            updated.currentValue = param.defaultValue
            return updated
        }
    }
    
    func getParameterValues() -> [String: Float] {
        var values: [String: Float] = [:]
        for param in parameters {
            values[param.name] = param.currentValue
        }
        return values
    }
    
    func updateParameter(id: UUID, value: Float) {
        if let index = parameters.firstIndex(where: { $0.id == id }) {
            parameters[index].currentValue = value
        }
    }
}
