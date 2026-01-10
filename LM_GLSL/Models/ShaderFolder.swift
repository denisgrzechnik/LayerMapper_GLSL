//
//  ShaderFolder.swift
//  LM_GLSL
//
//  Model for user-created shader folders
//

import Foundation
import SwiftData

/// Model foldera shaderów w SwiftData
@Model
final class ShaderFolder {
    @Attribute(.unique) var id: UUID
    var name: String
    var colorHex: String
    var iconName: String
    var dateCreated: Date
    var dateModified: Date
    var order: Int
    
    // Lista ID shaderów w folderze
    var shaderIds: [UUID]
    
    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#808080",
        iconName: String = "folder.fill",
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.iconName = iconName
        self.dateCreated = Date()
        self.dateModified = Date()
        self.order = order
        self.shaderIds = []
    }
    
    func addShader(_ shaderId: UUID) {
        if !shaderIds.contains(shaderId) {
            shaderIds.append(shaderId)
            dateModified = Date()
        }
    }
    
    func removeShader(_ shaderId: UUID) {
        shaderIds.removeAll { $0 == shaderId }
        dateModified = Date()
    }
    
    func containsShader(_ shaderId: UUID) -> Bool {
        shaderIds.contains(shaderId)
    }
    
    var shaderCount: Int {
        shaderIds.count
    }
}
