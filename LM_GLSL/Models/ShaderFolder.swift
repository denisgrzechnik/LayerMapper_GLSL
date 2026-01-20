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
    var id: UUID = UUID()  // CloudKit requires default values
    var name: String = ""
    var colorHex: String = "#808080"
    var iconName: String = "folder.fill"
    var dateCreated: Date = Date()
    var dateModified: Date = Date()
    var order: Int = 0
    
    // Lista ID shaderów w folderze - przechowywana jako JSON String dla CloudKit
    var shaderIdsJSON: String = "[]"
    
    // Computed property dla łatwego dostępu
    var shaderIds: [UUID] {
        get {
            guard let data = shaderIdsJSON.data(using: .utf8),
                  let ids = try? JSONDecoder().decode([UUID].self, from: data) else {
                return []
            }
            return ids
        }
        set {
            if let data = try? JSONEncoder().encode(newValue),
               let json = String(data: data, encoding: .utf8) {
                shaderIdsJSON = json
            }
        }
    }
    
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
        self.shaderIdsJSON = "[]"
    }
    
    func addShader(_ shaderId: UUID) {
        var ids = shaderIds
        if !ids.contains(shaderId) {
            ids.append(shaderId)
            shaderIds = ids
            dateModified = Date()
        }
    }
    
    func removeShader(_ shaderId: UUID) {
        var ids = shaderIds
        ids.removeAll { $0 == shaderId }
        shaderIds = ids
        dateModified = Date()
    }
    
    func containsShader(_ shaderId: UUID) -> Bool {
        shaderIds.contains(shaderId)
    }
    
    var shaderCount: Int {
        shaderIds.count
    }
}