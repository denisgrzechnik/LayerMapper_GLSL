//
//  CloudKitShaderService.swift
//  LM_GLSL
//
//  CloudKit service for sharing shaders publicly
//  Uses iCloud.com.mobile.layermapper.glsl container
//

import Foundation
import CloudKit
import SwiftUI

/// Service for publishing and fetching shared shaders via CloudKit
@MainActor
class CloudKitShaderService: ObservableObject {
    
    static let shared = CloudKitShaderService()
    
    // CloudKit container and database
    private let container = CKContainer(identifier: "iCloud.com.mobile.layermapper.glsl")
    private var publicDatabase: CKDatabase { container.publicCloudDatabase }
    
    // Record type name (must match CloudKit Dashboard)
    private let recordType = "SharedShader"
    
    // Published state
    @Published var sharedShaders: [SharedShader] = []
    @Published var isLoading: Bool = false
    @Published var error: String?
    @Published var userRecordID: CKRecord.ID?
    
    // MARK: - Shared Shader Model
    
    struct SharedShader: Identifiable, Equatable {
        let id: CKRecord.ID
        var name: String
        var fragmentCode: String
        var category: String
        var author: String  // User Record ID
        var authorName: String
        var shaderDescription: String
        var dateCreated: Date
        var likes: Int
        var downloadCount: Int
        var version: String
        var isPublic: Bool
        var thumbnailURL: URL?
        
        // For Equatable
        static func == (lhs: SharedShader, rhs: SharedShader) -> Bool {
            lhs.id == rhs.id
        }
    }
    
    private init() {
        // Fetch user record ID on init
        Task {
            await fetchUserRecordID()
        }
    }
    
    // MARK: - User Identity
    
    func fetchUserRecordID() async {
        do {
            let recordID = try await container.userRecordID()
            self.userRecordID = recordID
            print("☁️ CloudKit: User Record ID: \(recordID.recordName)")
        } catch {
            print("⚠️ CloudKit: Could not get user record ID: \(error)")
        }
    }
    
    // MARK: - Publish Shader
    
    /// Publish a shader to the public CloudKit database
    func publishShader(
        name: String,
        fragmentCode: String,
        category: String,
        authorName: String,
        description: String,
        thumbnailData: Data? = nil
    ) async throws -> CKRecord.ID {
        
        guard let userID = userRecordID else {
            throw CloudKitError.notAuthenticated
        }
        
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Create new record
        let record = CKRecord(recordType: recordType)
        
        // Set fields
        record["name"] = name
        record["fragmentCode"] = fragmentCode
        record["category"] = category
        record["author"] = userID.recordName
        record["authorName"] = authorName
        record["shaderDescription"] = description
        record["dateCreated"] = Date()
        record["likes"] = 0
        record["downloadCount"] = 0
        record["version"] = "1.0"
        record["isPublic"] = 1  // INT64 as bool
        
        // Handle thumbnail if provided
        if let thumbnailData = thumbnailData {
            let tempURL = FileManager.default.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension("jpg")
            try thumbnailData.write(to: tempURL)
            record["thumbnail"] = CKAsset(fileURL: tempURL)
        }
        
        // Save to CloudKit
        do {
            let savedRecord = try await publicDatabase.save(record)
            print("☁️ CloudKit: Published shader '\(name)' with ID: \(savedRecord.recordID)")
            
            // Refresh list
            await fetchPublicShaders()
            
            return savedRecord.recordID
        } catch {
            self.error = error.localizedDescription
            print("❌ CloudKit publish error: \(error)")
            throw error
        }
    }
    
    // MARK: - Fetch Public Shaders
    
    /// Fetch all public shaders from CloudKit
    func fetchPublicShaders(category: String? = nil, sortBy: SortOption = .newest) async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // Build predicate
        var predicates: [NSPredicate] = [
            NSPredicate(format: "isPublic == %d", 1)
        ]
        
        if let category = category, category != "All" {
            predicates.append(NSPredicate(format: "category == %@", category))
        }
        
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
        
        // Build query with sort
        let query = CKQuery(recordType: recordType, predicate: compoundPredicate)
        
        switch sortBy {
        case .newest:
            query.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        case .popular:
            query.sortDescriptors = [NSSortDescriptor(key: "likes", ascending: false)]
        case .name:
            query.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        }
        
        do {
            let (results, _) = try await publicDatabase.records(matching: query)
            
            var shaders: [SharedShader] = []
            
            for (_, result) in results {
                if case .success(let record) = result {
                    if let shader = parseShaderRecord(record) {
                        shaders.append(shader)
                    }
                }
            }
            
            self.sharedShaders = shaders
            print("☁️ CloudKit: Fetched \(shaders.count) public shaders")
            
        } catch {
            self.error = error.localizedDescription
            print("❌ CloudKit fetch error: \(error)")
        }
    }
    
    // MARK: - Search Shaders
    
    /// Search shaders by name
    func searchShaders(query searchText: String) async {
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        // CloudKit uses BEGINSWITH for text search with Searchable index
        let predicate = NSPredicate(format: "self contains %@ AND isPublic == %d", searchText, 1)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        
        do {
            let (results, _) = try await publicDatabase.records(matching: query)
            
            var shaders: [SharedShader] = []
            
            for (_, result) in results {
                if case .success(let record) = result {
                    if let shader = parseShaderRecord(record) {
                        shaders.append(shader)
                    }
                }
            }
            
            self.sharedShaders = shaders
            print("☁️ CloudKit: Found \(shaders.count) shaders matching '\(searchText)'")
            
        } catch {
            self.error = error.localizedDescription
            print("❌ CloudKit search error: \(error)")
        }
    }
    
    // MARK: - Like Shader
    
    /// Increment likes count for a shader
    func likeShader(_ shader: SharedShader) async {
        do {
            let record = try await publicDatabase.record(for: shader.id)
            let currentLikes = record["likes"] as? Int ?? 0
            record["likes"] = currentLikes + 1
            
            try await publicDatabase.save(record)
            
            // Update local state
            if let index = sharedShaders.firstIndex(where: { $0.id == shader.id }) {
                sharedShaders[index].likes = currentLikes + 1
            }
            
            print("☁️ CloudKit: Liked shader '\(shader.name)' (now \(currentLikes + 1) likes)")
            
        } catch {
            print("❌ CloudKit like error: \(error)")
        }
    }
    
    // MARK: - Download Shader
    
    /// Get shader code and increment download count
    func downloadShader(_ shader: SharedShader) async -> String? {
        do {
            let record = try await publicDatabase.record(for: shader.id)
            
            // Increment download count
            let currentDownloads = record["downloadCount"] as? Int ?? 0
            record["downloadCount"] = currentDownloads + 1
            try await publicDatabase.save(record)
            
            // Update local state
            if let index = sharedShaders.firstIndex(where: { $0.id == shader.id }) {
                sharedShaders[index].downloadCount = currentDownloads + 1
            }
            
            print("☁️ CloudKit: Downloaded shader '\(shader.name)' (\(currentDownloads + 1) downloads)")
            
            return record["fragmentCode"] as? String
            
        } catch {
            print("❌ CloudKit download error: \(error)")
            return nil
        }
    }
    
    // MARK: - Delete Shader (own shaders only)
    
    /// Delete a shader (only works for shaders created by current user)
    func deleteShader(_ shader: SharedShader) async throws {
        guard let userID = userRecordID else {
            throw CloudKitError.notAuthenticated
        }
        
        // Verify ownership
        guard shader.author == userID.recordName else {
            throw CloudKitError.notAuthorized
        }
        
        try await publicDatabase.deleteRecord(withID: shader.id)
        
        // Remove from local state
        sharedShaders.removeAll { $0.id == shader.id }
        
        print("☁️ CloudKit: Deleted shader '\(shader.name)'")
    }
    
    // MARK: - Fetch My Shaders
    
    /// Fetch shaders published by current user
    func fetchMyShaders() async {
        guard let userID = userRecordID else {
            print("⚠️ CloudKit: Not authenticated")
            return
        }
        
        isLoading = true
        error = nil
        
        defer { isLoading = false }
        
        let predicate = NSPredicate(format: "author == %@", userID.recordName)
        let query = CKQuery(recordType: recordType, predicate: predicate)
        query.sortDescriptors = [NSSortDescriptor(key: "dateCreated", ascending: false)]
        
        do {
            let (results, _) = try await publicDatabase.records(matching: query)
            
            var shaders: [SharedShader] = []
            
            for (_, result) in results {
                if case .success(let record) = result {
                    if let shader = parseShaderRecord(record) {
                        shaders.append(shader)
                    }
                }
            }
            
            self.sharedShaders = shaders
            print("☁️ CloudKit: Fetched \(shaders.count) of my shaders")
            
        } catch {
            self.error = error.localizedDescription
            print("❌ CloudKit fetch my shaders error: \(error)")
        }
    }
    
    // MARK: - Helper Methods
    
    private func parseShaderRecord(_ record: CKRecord) -> SharedShader? {
        guard let name = record["name"] as? String,
              let fragmentCode = record["fragmentCode"] as? String else {
            return nil
        }
        
        var thumbnailURL: URL?
        if let asset = record["thumbnail"] as? CKAsset {
            thumbnailURL = asset.fileURL
        }
        
        return SharedShader(
            id: record.recordID,
            name: name,
            fragmentCode: fragmentCode,
            category: record["category"] as? String ?? "Basic",
            author: record["author"] as? String ?? "",
            authorName: record["authorName"] as? String ?? "Anonymous",
            shaderDescription: record["shaderDescription"] as? String ?? "",
            dateCreated: record["dateCreated"] as? Date ?? Date(),
            likes: record["likes"] as? Int ?? 0,
            downloadCount: record["downloadCount"] as? Int ?? 0,
            version: record["version"] as? String ?? "1.0",
            isPublic: (record["isPublic"] as? Int ?? 1) == 1,
            thumbnailURL: thumbnailURL
        )
    }
    
    // MARK: - Enums
    
    enum SortOption {
        case newest
        case popular
        case name
    }
    
    enum CloudKitError: LocalizedError {
        case notAuthenticated
        case notAuthorized
        case recordNotFound
        
        var errorDescription: String? {
            switch self {
            case .notAuthenticated:
                return "Not signed in to iCloud"
            case .notAuthorized:
                return "You can only modify your own shaders"
            case .recordNotFound:
                return "Shader not found"
            }
        }
    }
    
    // MARK: - Convenience Methods for ShaderGridMainView
    
    /// Fetch public shaders and return as array (for async/await usage)
    func fetchPublicShadersArray() async throws -> [SharedShader] {
        await fetchPublicShaders(category: nil, sortBy: .newest)
        return sharedShaders
    }
    
    /// Download shader and create ShaderEntity
    func downloadShaderAsEntity(_ shader: SharedShader) async throws -> ShaderEntity {
        // Get the code (also increments download count)
        _ = await downloadShader(shader)
        
        // Create local ShaderEntity
        let category = ShaderCategory(rawValue: shader.category) ?? .basic
        
        let newShader = ShaderEntity(
            name: shader.name,
            fragmentCode: shader.fragmentCode,
            category: category,
            isBuiltIn: false
        )
        newShader.shaderDescription = shader.shaderDescription + "\n\n[Downloaded from Community - by \(shader.authorName)]"
        
        return newShader
    }
    
    /// Publish ShaderEntity to community
    func publishShaderEntity(_ shader: ShaderEntity, authorName: String) async throws {
        _ = try await publishShader(
            name: shader.name,
            fragmentCode: shader.fragmentCode,
            category: shader.category.rawValue,
            authorName: authorName,
            description: shader.shaderDescription
        )
    }
}

// MARK: - Type Alias for convenience
typealias SharedShaderInfo = CloudKitShaderService.SharedShader
