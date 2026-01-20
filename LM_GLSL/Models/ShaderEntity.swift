//
//  ShaderEntity.swift
//  LM_GLSL
//
//  SwiftData model for shader storage
//

import Foundation
import SwiftData

/// Główny model shadera w SwiftData
@Model
final class ShaderEntity {
    // MARK: - Identyfikacja
    var id: UUID = UUID()  // CloudKit requires default values
    var name: String = ""
    var shaderDescription: String = ""
    
    // MARK: - Kod shadera
    var fragmentCode: String = ""
    var vertexCode: String?
    
    // MARK: - Kategoryzacja
    var categoryRawValue: String = "Basic"
    var tagsJSON: String = "[]"  // CloudKit: stored as JSON String
    
    // Computed property for easy access
    var tags: [String] {
        get {
            guard let data = tagsJSON.data(using: .utf8),
                  let arr = try? JSONDecoder().decode([String].self, from: data) else {
                return []
            }
            return arr
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                tagsJSON = json
            }
        }
    }
    
    // MARK: - Metadane
    var author: String = "Built-in"
    var version: String = "1.0"
    var dateCreated: Date = Date()
    var dateModified: Date = Date()
    
    // MARK: - Flagi
    var isBuiltIn: Bool = false
    var isFavorite: Bool = false
    var isPublic: Bool = false
    
    // MARK: - Statystyki
    var viewCount: Int = 0
    var rating: Double = 0.0
    var ratingCount: Int = 0
    
    // MARK: - Parametry (jako JSON)
    var parametersJSON: Data?
    
    // MARK: - Automation (jako JSON)
    var automationData: Data?
    
    // MARK: - Thumbnail
    var thumbnailData: Data?
    var thumbnailColorHex: String = "#808080"
    
    // MARK: - Relacje
    @Relationship(deleteRule: .cascade, inverse: \ShaderParameterEntity.shader)
    var parameters: [ShaderParameterEntity]?
    
    // MARK: - Computed Properties
    
    var category: ShaderCategory {
        get { ShaderCategory(rawValue: categoryRawValue) ?? .basic }
        set { categoryRawValue = newValue.rawValue }
    }
    
    // MARK: - Initialization
    
    init(
        id: UUID = UUID(),
        name: String,
        fragmentCode: String,
        vertexCode: String? = nil,
        category: ShaderCategory = .basic,
        tags: [String] = [],
        author: String = "Built-in",
        version: String = "1.0",
        isBuiltIn: Bool = false,
        isFavorite: Bool = false,
        isPublic: Bool = false,
        shaderDescription: String = "",
        thumbnailColorHex: String = "#808080"
    ) {
        self.id = id
        self.name = name
        self.fragmentCode = fragmentCode
        self.vertexCode = vertexCode
        self.categoryRawValue = category.rawValue
        // Encode tags as JSON
        if let data = try? JSONEncoder().encode(tags),
           let json = String(data: data, encoding: .utf8) {
            self.tagsJSON = json
        } else {
            self.tagsJSON = "[]"
        }
        self.author = author
        self.version = version
        self.dateCreated = Date()
        self.dateModified = Date()
        self.isBuiltIn = isBuiltIn
        self.isFavorite = isFavorite
        self.isPublic = isPublic
        self.shaderDescription = shaderDescription
        self.viewCount = 0
        self.rating = 0.0
        self.ratingCount = 0
        self.thumbnailColorHex = thumbnailColorHex
    }
    
    // MARK: - Methods
    
    func incrementViewCount() {
        viewCount += 1
    }
    
    func addRating(_ value: Double) {
        let totalRating = rating * Double(ratingCount) + value
        ratingCount += 1
        rating = totalRating / Double(ratingCount)
    }
    
    func updateModifiedDate() {
        dateModified = Date()
    }
}

// MARK: - Parameter Entity

/// Model parametru shadera w SwiftData
@Model
final class ShaderParameterEntity {
    var id: UUID = UUID()  // CloudKit requires default values
    var name: String = ""
    var displayName: String = ""
    var parameterType: String = "float" // "float", "color", "int", "bool", "vec2", "vec3", "vec4"
    
    // Wartości dla float/int
    var floatValue: Float = 0.5
    var minValue: Float = 0.0
    var maxValue: Float = 1.0
    var defaultValue: Float = 0.5
    var step: Float = 0.01
    
    // Wartości dla color (jako hex)
    var colorValueHex: String?
    
    // Wartości dla vector - stored as JSON String for CloudKit
    var vectorValuesJSON: String?
    
    var vectorValues: [Float]? {
        get {
            guard let json = vectorValuesJSON,
                  let data = json.data(using: .utf8),
                  let arr = try? JSONDecoder().decode([Float].self, from: data) else {
                return nil
            }
            return arr
        }
        set {
            if let newValue = newValue,
               let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                vectorValuesJSON = json
            } else {
                vectorValuesJSON = nil
            }
        }
    }
    
    // Wartość bool
    var boolValue: Bool = false
    
    // Relacja do shadera
    var shader: ShaderEntity?
    
    init(
        id: UUID = UUID(),
        name: String,
        displayName: String? = nil,
        parameterType: String = "float",
        floatValue: Float = 0.5,
        minValue: Float = 0.0,
        maxValue: Float = 1.0,
        defaultValue: Float = 0.5,
        step: Float = 0.01
    ) {
        self.id = id
        self.name = name
        self.displayName = displayName ?? name.capitalized
        self.parameterType = parameterType
        self.floatValue = floatValue
        self.minValue = minValue
        self.maxValue = maxValue
        self.defaultValue = defaultValue
        self.step = step
        self.boolValue = false
    }
}

// MARK: - Tag Entity (dla przyszłego rozwoju)

@Model
final class TagEntity {
    var id: UUID = UUID()  // CloudKit requires default values
    var name: String = ""
    var colorHex: String = "#808080"
    var usageCount: Int = 0
    
    init(id: UUID = UUID(), name: String, colorHex: String = "#808080") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.usageCount = 0
    }
}
