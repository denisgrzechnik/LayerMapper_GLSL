//
//  ICloudFolderSync.swift
//  LM_GLSL
//
//  Syncs folders between devices using iCloud Key-Value Store (NSUbiquitousKeyValueStore)
//  This is simpler and more reliable than CloudKit+SwiftData for small data like folder metadata.
//

import Foundation
import SwiftUI
import SwiftData

/// Synchronizes shader folders across devices using iCloud Key-Value Store
/// Limited to 1MB total, but folders are small so this is plenty
class ICloudFolderSync: ObservableObject {
    
    static let shared = ICloudFolderSync()
    
    private let kvStore = NSUbiquitousKeyValueStore.default
    private let foldersKey = "syncedFolders_v1"
    
    @Published var lastSyncDate: Date?
    @Published var syncStatus: SyncStatus = .idle
    
    private var syncTimer: Timer?
    private weak var modelContext: ModelContext?
    
    enum SyncStatus {
        case idle
        case syncing
        case success
        case error(String)
    }
    
    // MARK: - Folder Data for Sync
    
    struct SyncedFolder: Codable, Identifiable {
        var id: UUID
        var name: String
        var colorHex: String
        var iconName: String
        var order: Int
        var dateCreated: Date
        var dateModified: Date
        // Shader IDs as strings for sync - shaders matched by NAME on other devices
        var shaderNames: [String]
    }
    
    private init() {}
    
    // MARK: - Start Sync
    
    func startSync(context: ModelContext) {
        self.modelContext = context
        
        // Register for iCloud KVS change notifications
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(iCloudKVSDidChange(_:)),
            name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
            object: kvStore
        )
        
        // Synchronize with iCloud
        let synced = kvStore.synchronize()
        print("☁️ iCloud KVS: Initial sync \(synced ? "triggered" : "failed")")
        
        // Import any existing data from iCloud (async on main actor)
        Task { @MainActor in
            self.importFromiCloud(context: context)
        }
        
        // Start periodic export
        startPeriodicExport()
        
        print("☁️ iCloud KVS: Folder sync STARTED")
    }
    
    func stopSync() {
        syncTimer?.invalidate()
        syncTimer = nil
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - iCloud Change Notification
    
    @objc private func iCloudKVSDidChange(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let reason = userInfo[NSUbiquitousKeyValueStoreChangeReasonKey] as? Int else {
            return
        }
        
        let changedKeys = userInfo[NSUbiquitousKeyValueStoreChangedKeysKey] as? [String] ?? []
        
        switch reason {
        case NSUbiquitousKeyValueStoreServerChange:
            print("☁️ iCloud KVS: Server change detected - keys: \(changedKeys)")
            if changedKeys.contains(foldersKey) {
                Task { @MainActor in
                    if let context = self.modelContext {
                        self.importFromiCloud(context: context)
                    }
                }
            }
        case NSUbiquitousKeyValueStoreInitialSyncChange:
            print("☁️ iCloud KVS: Initial sync completed")
            Task { @MainActor in
                if let context = self.modelContext {
                    self.importFromiCloud(context: context)
                }
            }
        case NSUbiquitousKeyValueStoreQuotaViolationChange:
            print("⚠️ iCloud KVS: Quota exceeded!")
            syncStatus = .error("iCloud quota exceeded")
        case NSUbiquitousKeyValueStoreAccountChange:
            print("☁️ iCloud KVS: Account changed")
        default:
            print("☁️ iCloud KVS: Unknown change reason: \(reason)")
        }
    }
    
    // MARK: - Export to iCloud
    
    @MainActor
    func exportToiCloud(context: ModelContext) {
        syncStatus = .syncing
        
        do {
            let descriptor = FetchDescriptor<ShaderFolder>(sortBy: [SortDescriptor(\.order)])
            let folders = try context.fetch(descriptor)
            
            let shaderDescriptor = FetchDescriptor<ShaderEntity>()
            let allShaders = try context.fetch(shaderDescriptor)
            // ID to Name mapping - IDs are unique so no duplicates possible
            var shaderIdToName: [UUID: String] = [:]
            for shader in allShaders {
                shaderIdToName[shader.id] = shader.name
            }
            
            // Convert to sync format
            let syncedFolders = folders.map { folder -> SyncedFolder in
                let shaderNames = folder.shaderIds.compactMap { shaderIdToName[$0] }
                return SyncedFolder(
                    id: folder.id,
                    name: folder.name,
                    colorHex: folder.colorHex,
                    iconName: folder.iconName,
                    order: folder.order,
                    dateCreated: folder.dateCreated,
                    dateModified: folder.dateModified,
                    shaderNames: shaderNames
                )
            }
            
            // Encode and save to iCloud KVS
            let data = try JSONEncoder().encode(syncedFolders)
            kvStore.set(data, forKey: foldersKey)
            kvStore.synchronize()
            
            lastSyncDate = Date()
            syncStatus = .success
            
            print("☁️ iCloud KVS: Exported \(folders.count) folders (\(data.count) bytes)")
            
        } catch {
            syncStatus = .error(error.localizedDescription)
            print("❌ iCloud KVS export error: \(error)")
        }
    }
    
    // MARK: - Import from iCloud
    
    @MainActor
    func importFromiCloud(context: ModelContext) {
        syncStatus = .syncing
        
        guard let data = kvStore.data(forKey: foldersKey) else {
            print("☁️ iCloud KVS: No folder data in iCloud")
            syncStatus = .idle
            return
        }
        
        do {
            let syncedFolders = try JSONDecoder().decode([SyncedFolder].self, from: data)
            print("☁️ iCloud KVS: Found \(syncedFolders.count) folders in iCloud")
            
            // Fetch existing local folders
            let descriptor = FetchDescriptor<ShaderFolder>()
            let localFolders = try context.fetch(descriptor)
            let localFolderIds = Set(localFolders.map { $0.id })
            
            // Fetch all shaders to map names to IDs (handle duplicates by using first match)
            let shaderDescriptor = FetchDescriptor<ShaderEntity>()
            let allShaders = try context.fetch(shaderDescriptor)
            // Use reduce to handle duplicate names - first shader with name wins
            var shaderNameToId: [String: UUID] = [:]
            for shader in allShaders {
                if shaderNameToId[shader.name] == nil {
                    shaderNameToId[shader.name] = shader.id
                }
            }
            
            var importedCount = 0
            var updatedCount = 0
            
            for syncedFolder in syncedFolders {
                if localFolderIds.contains(syncedFolder.id) {
                    // Folder exists - check if remote is newer
                    if let localFolder = localFolders.first(where: { $0.id == syncedFolder.id }) {
                        if syncedFolder.dateModified > localFolder.dateModified {
                            // Update local folder with remote data
                            localFolder.name = syncedFolder.name
                            localFolder.colorHex = syncedFolder.colorHex
                            localFolder.iconName = syncedFolder.iconName
                            localFolder.order = syncedFolder.order
                            localFolder.dateModified = syncedFolder.dateModified
                            
                            // Map shader names to local IDs
                            let shaderIds = syncedFolder.shaderNames.compactMap { shaderNameToId[$0] }
                            localFolder.shaderIds = shaderIds
                            
                            updatedCount += 1
                        }
                    }
                } else {
                    // New folder from iCloud - create locally
                    let newFolder = ShaderFolder(
                        id: syncedFolder.id,
                        name: syncedFolder.name,
                        colorHex: syncedFolder.colorHex,
                        iconName: syncedFolder.iconName,
                        order: syncedFolder.order
                    )
                    
                    // Map shader names to local IDs
                    let shaderIds = syncedFolder.shaderNames.compactMap { shaderNameToId[$0] }
                    newFolder.shaderIds = shaderIds
                    
                    context.insert(newFolder)
                    importedCount += 1
                }
            }
            
            if importedCount > 0 || updatedCount > 0 {
                try context.save()
                print("☁️ iCloud KVS: Imported \(importedCount) new, updated \(updatedCount) folders")
            }
            
            lastSyncDate = Date()
            syncStatus = .success
            
        } catch {
            syncStatus = .error(error.localizedDescription)
            print("❌ iCloud KVS import error: \(error)")
        }
    }
    
    // MARK: - Periodic Export
    
    private func startPeriodicExport() {
        syncTimer?.invalidate()
        
        // Export every 30 seconds if there are changes
        syncTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] _ in
            guard let self = self, let context = self.modelContext else { return }
            Task { @MainActor in
                self.exportToiCloud(context: context)
            }
        }
    }
    
    // MARK: - Manual Sync
    
    @MainActor
    func syncNow(context: ModelContext) {
        exportToiCloud(context: context)
        kvStore.synchronize()
        
        // Schedule import after a brief delay to allow sync
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            Task { @MainActor in
                self.importFromiCloud(context: context)
            }
        }
    }
    
    // MARK: - Delete Folder
    
    @MainActor
    func deleteFolder(id: UUID, context: ModelContext) {
        // Delete locally
        let descriptor = FetchDescriptor<ShaderFolder>(predicate: #Predicate { $0.id == id })
        if let folders = try? context.fetch(descriptor), let folder = folders.first {
            context.delete(folder)
            try? context.save()
        }
        
        // Re-export to iCloud
        exportToiCloud(context: context)
    }
}
