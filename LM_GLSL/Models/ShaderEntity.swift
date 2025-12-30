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
    @Attribute(.unique) var id: UUID
    var name: String
    var shaderDescription: String
    
    // MARK: - Kod shadera
    var fragmentCode: String
    var vertexCode: String?
    
    // MARK: - Kategoryzacja
    var categoryRawValue: String
    var tags: [String]
    
    // MARK: - Metadane
    var author: String
    var version: String
    var dateCreated: Date
    var dateModified: Date
    
    // MARK: - Flagi
    var isBuiltIn: Bool
    var isFavorite: Bool
    var isPublic: Bool
    
    // MARK: - Statystyki
    var viewCount: Int
    var rating: Double
    var ratingCount: Int
    
    // MARK: - Parametry (jako JSON)
    var parametersJSON: Data?
    
    // MARK: - Thumbnail
    var thumbnailData: Data?
    var thumbnailColorHex: String
    
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
        self.tags = tags
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
    @Attribute(.unique) var id: UUID
    var name: String
    var displayName: String
    var parameterType: String // "float", "color", "int", "bool", "vec2", "vec3", "vec4"
    
    // Wartości dla float/int
    var floatValue: Float
    var minValue: Float
    var maxValue: Float
    var defaultValue: Float
    var step: Float
    
    // Wartości dla color (jako hex)
    var colorValueHex: String?
    
    // Wartości dla vector
    var vectorValues: [Float]?
    
    // Wartość bool
    var boolValue: Bool
    
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
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var usageCount: Int
    
    init(id: UUID = UUID(), name: String, colorHex: String = "#808080") {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.usageCount = 0
    }
}
