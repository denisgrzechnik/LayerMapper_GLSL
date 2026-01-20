//
//  LM_GLSLApp.swift
//  LM_GLSL
//
//  Main application entry point with SwiftData
//

import SwiftUI
import SwiftData
import CoreData
import CloudKit

@main
struct LM_GLSLApp: App {
    
    // MARK: - iCloud Key-Value Sync for Folders
    @StateObject private var iCloudFolderSync = ICloudFolderSync.shared
    
    // MARK: - SwiftData Container (ALL LOCAL - folders synced via iCloud KVS)
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ShaderEntity.self,
            ShaderParameterEntity.self,
            TagEntity.self,
            ShaderFolder.self
        ])
        
        // All data stored locally - folders synced separately via iCloud Key-Value Store
        let localConfig = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .none  // No CloudKit - use iCloud KVS instead
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [localConfig])
            print("💾 SwiftData: All data stored LOCALLY")
            print("☁️ Folders will sync via iCloud Key-Value Store")
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    /// Delete old local database files to allow CloudKit migration
    private static func deleteOldDatabase() {
        let fileManager = FileManager.default
        
        guard let appSupport = fileManager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
            return
        }
        
        // SwiftData stores files with .store extension - delete all variants
        let storeFiles = [
            "default.store", "default.store-shm", "default.store-wal",
            "LocalShaders.store", "LocalShaders.store-shm", "LocalShaders.store-wal",
            "CloudFolders.store", "CloudFolders.store-shm", "CloudFolders.store-wal"
        ]
        
        for file in storeFiles {
            let url = appSupport.appendingPathComponent(file)
            if fileManager.fileExists(atPath: url.path) {
                do {
                    try fileManager.removeItem(at: url)
                    print("🗑️ Deleted old database file: \(file)")
                } catch {
                    print("⚠️ Could not delete \(file): \(error)")
                }
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    loadBuiltInShadersIfNeeded()
                    setupICloudKVSSync()
                    logDatabaseStatus()
                }
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    // Refresh data when app comes to foreground
                    Task { @MainActor in
                        iCloudFolderSync.importFromiCloud(context: sharedModelContainer.mainContext)
                        logDatabaseStatus()
                        exportFoldersToAppGroups()
                    }
                }
                .environmentObject(iCloudFolderSync)
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Initial Setup
    
    @MainActor
    private func loadBuiltInShadersIfNeeded() {
        let context = sharedModelContainer.mainContext
        let loader = BuiltInShaderLoader(modelContext: context)
        loader.loadIfNeeded()
    }
    
    @MainActor
    private func logDatabaseStatus() {
        let context = sharedModelContainer.mainContext
        
        do {
            let folderDescriptor = FetchDescriptor<ShaderFolder>()
            let folders = try context.fetch(folderDescriptor)
            
            let shaderDescriptor = FetchDescriptor<ShaderEntity>()
            let shaders = try context.fetch(shaderDescriptor)
            
            print("📊 DATABASE STATUS:")
            print("   - Folders: \(folders.count)")
            for folder in folders {
                print("     • \(folder.name) (id: \(folder.id.uuidString.prefix(8))..., shaders: \(folder.shaderIds.count))")
            }
            print("   - Shaders: \(shaders.count)")
            print("   - Custom shaders: \(shaders.filter { !$0.isBuiltIn }.count)")
        } catch {
            print("❌ Database status error: \(error)")
        }
    }
    
    // MARK: - iCloud Key-Value Store Sync
    
    private func setupICloudKVSSync() {
        // Initialize iCloud KVS sync
        iCloudFolderSync.startSync(context: sharedModelContainer.mainContext)
        
        // Check iCloud account status
        checkiCloudStatus()
        
        // Export to App Groups for MApp
        Task { @MainActor in
            exportFoldersToAppGroups()
        }
    }
    
    private func checkiCloudStatus() {
        CKContainer.default().accountStatus { status, error in
            DispatchQueue.main.async {
                switch status {
                case .available:
                    print("☁️ iCloud: AVAILABLE - sync should work")
                case .noAccount:
                    print("⚠️ iCloud: NO ACCOUNT - user not signed in")
                case .restricted:
                    print("⚠️ iCloud: RESTRICTED")
                case .couldNotDetermine:
                    print("⚠️ iCloud: Could not determine status")
                case .temporarilyUnavailable:
                    print("⚠️ iCloud: Temporarily unavailable")
                @unknown default:
                    print("⚠️ iCloud: Unknown status")
                }
                if let error = error {
                    print("❌ iCloud error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    @MainActor
    private func exportFoldersToAppGroups() {
        let context = sharedModelContainer.mainContext
        
        do {
            let folderDescriptor = FetchDescriptor<ShaderFolder>(sortBy: [SortDescriptor(\.order)])
            let folders = try context.fetch(folderDescriptor)
            
            let shaderDescriptor = FetchDescriptor<ShaderEntity>(sortBy: [SortDescriptor(\.name)])
            let shaders = try context.fetch(shaderDescriptor)
            
            SharedFolderSyncService.shared.exportFolders(folders: folders, shaders: shaders)
            print("📱 App Groups: Exported \(folders.count) folders for MApp")
        } catch {
            print("⚠️ App Groups: Failed to export folders - \(error)")
        }
    }
}
