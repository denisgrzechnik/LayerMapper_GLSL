//
//  SharedFolderSync.swift
//  LM_GLSL
//
//  Shared folder synchronization using App Groups
//  Both LM_GLSL and LayerMapperLaser can read/write to shared UserDefaults
//
//  Created: January 2026
//

import Foundation
import SwiftData

/// Keys for shared UserDefaults in App Group
struct SharedFolderKeys {
    static let appGroupId = "group.com.mobile.layermapper.glsl"
    
    // Folder data keys
    static let customFolders = "shared.shader.customFolders"           // [String] - folder names
    static let folderAssignments = "shared.shader.folderAssignments"   // [String: [String]] - shaderName -> [folderNames]
    static let folderContents = "shared.shader.folderContents"         // [String: [SyncedShaderData]] - folder -> full shader data
    static let lastModified = "shared.shader.lastModified"             // Date - last modification timestamp
    static let modifiedBy = "shared.shader.modifiedBy"                 // String - app that last modified ("GLSL" or "MApp")
}

// MARK: - Synced Shader Data Structures

/// Full shader data for synchronization (includes code and parameters)
struct SyncedShaderData: Codable, Identifiable, Hashable {
    let id: UUID
    let name: String
    let fragmentCode: String
    let vertexCode: String?
    let category: String
    let parameters: [SyncedShaderParameter]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: SyncedShaderData, rhs: SyncedShaderData) -> Bool {
        lhs.id == rhs.id
    }
}

/// Shader parameter for synchronization
struct SyncedShaderParameter: Codable {
    let name: String
    let displayName: String
    let type: String
    let minValue: Float
    let maxValue: Float
    let defaultValue: Float
    let currentValue: Float  // Actual value set in LM_GLSL
}

/// Service for syncing SwiftData folders with shared App Group storage
class SharedFolderSyncService: ObservableObject {
    
    static let shared = SharedFolderSyncService()
    
    /// Shared UserDefaults for App Group
    private let sharedDefaults: UserDefaults?
    
    /// Published state
    @Published var lastSyncDate: Date?
    @Published var lastSyncSource: String?
    
    /// Notification observer for external changes
    private var observer: NSObjectProtocol?
    
    private init() {
        sharedDefaults = UserDefaults(suiteName: SharedFolderKeys.appGroupId)
        
        if sharedDefaults == nil {
            print("⚠️ SharedFolderSync: Failed to access App Group UserDefaults")
        } else {
            print("✅ SharedFolderSync: Connected to App Group: \(SharedFolderKeys.appGroupId)")
        }
        
        setupObserver()
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    // MARK: - Setup
    
    private func setupObserver() {
        // Observe for changes from MApp
        observer = NotificationCenter.default.addObserver(
            forName: UserDefaults.didChangeNotification,
            object: sharedDefaults,
            queue: .main
        ) { [weak self] _ in
            // Check if modification came from MApp
            if let source = self?.sharedDefaults?.string(forKey: SharedFolderKeys.modifiedBy),
               source == "MApp" {
                // Post notification to import changes
                NotificationCenter.default.post(name: .sharedFoldersDidChange, object: nil)
            }
        }
    }
    
    // MARK: - Export to Shared Storage
    
    /// Export SwiftData folders to shared App Group storage (with full shader data)
    func exportFolders(folders: [ShaderFolder], shaders: [ShaderEntity]) {
        guard let defaults = sharedDefaults else {
            print("❌ SharedFolderSync: Cannot export - App Group not available")
            return
        }
        
        // Convert folder names
        let folderNames = folders.map { $0.name }
        
        // Build shader-folder assignments (using shader name as key) - legacy
        var assignments: [String: [String]] = [:]
        for shader in shaders {
            let containingFolders = folders.filter { $0.containsShader(shader.id) }
            if !containingFolders.isEmpty {
                assignments[shader.name] = containingFolders.map { $0.name }
            }
        }
        
        // Build folder contents with FULL shader data (code + parameters)
        var folderContents: [String: [SyncedShaderData]] = [:]
        for folder in folders {
            var shadersInFolder: [SyncedShaderData] = []
            for shader in shaders {
                if folder.containsShader(shader.id) {
                    // Convert shader parameters (handle optional parameters array)
                    let syncedParams: [SyncedShaderParameter] = (shader.parameters ?? []).map { param in
                        SyncedShaderParameter(
                            name: param.name,
                            displayName: param.displayName,
                            type: param.parameterType,  // Use parameterType (String)
                            minValue: param.minValue,
                            maxValue: param.maxValue,
                            defaultValue: param.defaultValue,
                            currentValue: param.floatValue  // Current value set by user!
                        )
                    }
                    
                    let syncedShader = SyncedShaderData(
                        id: shader.id,
                        name: shader.name,
                        fragmentCode: shader.fragmentCode,
                        vertexCode: shader.vertexCode,
                        category: shader.category.rawValue,  // Convert ShaderCategory to String
                        parameters: syncedParams
                    )
                    shadersInFolder.append(syncedShader)
                }
            }
            folderContents[folder.name] = shadersInFolder
        }
        
        // Encode folder contents to JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        
        if let folderContentsData = try? encoder.encode(folderContents) {
            defaults.set(folderContentsData, forKey: SharedFolderKeys.folderContents)
        }
        
        // Save legacy keys too for backwards compatibility
        defaults.set(folderNames, forKey: SharedFolderKeys.customFolders)
        defaults.set(assignments, forKey: SharedFolderKeys.folderAssignments)
        defaults.set(Date(), forKey: SharedFolderKeys.lastModified)
        defaults.set("GLSL", forKey: SharedFolderKeys.modifiedBy)
        defaults.synchronize()
        
        lastSyncDate = Date()
        lastSyncSource = "GLSL"
        
        print("📁 SharedFolderSync: Exported \(folderNames.count) folders, \(assignments.count) shader assignments")
    }
    
    // MARK: - Import from Shared Storage
    
    /// Import folders from shared storage (creates new ShaderFolders if needed)
    func importFolders(modelContext: ModelContext, existingFolders: [ShaderFolder], shaders: [ShaderEntity]) {
        guard let defaults = sharedDefaults else {
            print("❌ SharedFolderSync: Cannot import - App Group not available")
            return
        }
        
        // Load folder names
        guard let folderNames = defaults.stringArray(forKey: SharedFolderKeys.customFolders) else {
            print("📁 SharedFolderSync: No folders to import")
            return
        }
        
        // Load assignments
        let assignmentsDict = defaults.dictionary(forKey: SharedFolderKeys.folderAssignments) as? [String: [String]] ?? [:]
        
        // Create missing folders
        var foldersByName: [String: ShaderFolder] = [:]
        for existing in existingFolders {
            foldersByName[existing.name] = existing
        }
        
        var newFoldersCreated = 0
        for folderName in folderNames {
            if foldersByName[folderName] == nil {
                let newFolder = ShaderFolder(name: folderName, order: existingFolders.count + newFoldersCreated)
                modelContext.insert(newFolder)
                foldersByName[folderName] = newFolder
                newFoldersCreated += 1
            }
        }
        
        // Update shader-folder assignments
        for (shaderName, folderNames) in assignmentsDict {
            // Find shader by name
            if let shader = shaders.first(where: { $0.name == shaderName }) {
                for folderName in folderNames {
                    if let folder = foldersByName[folderName] {
                        folder.addShader(shader.id)
                    }
                }
            }
        }
        
        // Save changes
        try? modelContext.save()
        
        lastSyncDate = defaults.object(forKey: SharedFolderKeys.lastModified) as? Date
        lastSyncSource = defaults.string(forKey: SharedFolderKeys.modifiedBy)
        
        print("📁 SharedFolderSync: Imported \(folderNames.count) folders (\(newFoldersCreated) new), processed \(assignmentsDict.count) shader assignments")
    }
    
    // MARK: - Read State
    
    /// Get last modification info
    func getLastModificationInfo() -> (date: Date?, source: String?) {
        guard let defaults = sharedDefaults else { return (nil, nil) }
        
        let date = defaults.object(forKey: SharedFolderKeys.lastModified) as? Date
        let source = defaults.string(forKey: SharedFolderKeys.modifiedBy)
        
        return (date, source)
    }
    
    /// Check if there are changes from MApp to import
    func hasChangesFromMApp() -> Bool {
        guard let defaults = sharedDefaults else { return false }
        
        let source = defaults.string(forKey: SharedFolderKeys.modifiedBy)
        return source == "MApp"
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let sharedFoldersDidChange = Notification.Name("sharedFoldersDidChange")
}
